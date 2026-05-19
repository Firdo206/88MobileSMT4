import 'package:flutter/material.dart';
import '../../services/refund_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefundPage extends StatefulWidget {
  final Map booking;

  const RefundPage({super.key, required this.booking});

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  final reasonController = TextEditingController();
  final bankController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();

  bool isLoading = false;

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color darkRed = Color(0xFF6B0000);
  static const Color lightRed = Color(0xFFCC2222);
  static const Color bgColor = Color(0xFFF7F3F0);

  @override
  void dispose() {
    reasonController.dispose();
    bankController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    super.dispose();
  }

  Future<void> submitRefund() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final data = await RefundService.submitRefund(
        bookingId: int.tryParse(widget.booking["id"].toString()) ?? 0,
        userId: userId,
        reason: reasonController.text,
        bankName: bankController.text,
        accountNumber: accountNumberController.text,
        accountName: accountNameController.text,
      );

      if (data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Refund berhasil diajukan"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw data["message"];
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryRed, size: 18),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: primaryRed, width: 1.8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        title: const Text(
          "Ajukan Refund",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [darkRed, lightRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryRed.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pengajuan Refund",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Isi data dengan lengkap dan benar",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Kebijakan Refund
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEDE8E4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: primaryRed,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Kebijakan Refund",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRuleRow(
                    icon: Icons.check_circle_rounded,
                    time: "> 24 jam sebelum berangkat",
                    percentage: "Refund 90%",
                    statusColor: const Color(0xFF16A34A),
                    rowBg: const Color(0xFFF0FDF4),
                  ),
                  const SizedBox(height: 10),
                  _buildRuleRow(
                    icon: Icons.timelapse_rounded,
                    time: "6 – 24 jam sebelum berangkat",
                    percentage: "Refund 70%",
                    statusColor: const Color(0xFFD97706),
                    rowBg: const Color(0xFFFFFBEB),
                  ),
                  const SizedBox(height: 10),
                  _buildRuleRow(
                    icon: Icons.cancel_rounded,
                    time: "< 6 jam sebelum berangkat",
                    percentage: "Tidak tersedia",
                    statusColor: const Color(0xFFDC2626),
                    rowBg: const Color(0xFFFEF2F2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Informasi Refund",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            inputField(
              label: "Alasan Refund",
              hint: "Tuliskan alasan pembatalan Anda...",
              controller: reasonController,
              icon: Icons.edit_note_rounded,
              maxLines: 3,
            ),
            inputField(
              label: "Nama Bank",
              hint: "Contoh: BCA, Mandiri, BRI",
              controller: bankController,
              icon: Icons.account_balance_rounded,
            ),
            inputField(
              label: "Nomor Rekening",
              hint: "Masukkan nomor rekening tujuan",
              controller: accountNumberController,
              icon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
            ),
            inputField(
              label: "Nama Pemilik Rekening",
              hint: "Sesuai nama di buku tabungan",
              controller: accountNameController,
              icon: Icons.person_rounded,
            ),

            const SizedBox(height: 12),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitRefund,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  disabledBackgroundColor: primaryRed.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: primaryRed.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Ajukan Refund",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow({
    required IconData icon,
    required String time,
    required String percentage,
    required Color statusColor,
    required Color rowBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}