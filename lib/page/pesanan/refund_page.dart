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

  // Palette Warna Custom (Biru Modern)
  final Color primaryBlue = const Color(0xFF1E88E5); // Biru bersih dan modern

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
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2), // Garis fokus biru
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Ajukan Refund", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Aturan Kebijakan Refund",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.amber.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRuleRow("> 24 jam sebelum berangkat", "Refund 90%", Colors.green.shade700),
                  const Divider(height: 16, thickness: 0.5, color: Colors.amber),
                  _buildRuleRow("6 - 24 jam sebelum berangkat", "Refund 70%", Colors.orange.shade700),
                  const Divider(height: 16, thickness: 0.5, color: Colors.amber),
                  _buildRuleRow("< 6 jam sebelum berangkat", "Tidak tersedia", Colors.red.shade700),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            const Text(
              "Informasi Refund",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            inputField(
              label: "Alasan Refund",
              hint: "Tuliskan alasan pembatalan Anda...",
              controller: reasonController,
              maxLines: 3,
            ),
            inputField(
              label: "Nama Bank", 
              hint: "Contoh: BCA, Mandiri, BRI",
              controller: bankController,
            ),
            inputField(
              label: "Nomor Rekening", 
              hint: "Masukkan nomor rekening tujuan",
              controller: accountNumberController,
              keyboardType: TextInputType.number,
            ),
            inputField(
              label: "Nama Pemilik Rekening", 
              hint: "Sesuai dengan nama di buku tabungan",
              controller: accountNameController,
            ),
            
            const SizedBox(height: 12),

            // Tombol kini berwarna Biru Modern dan tidak mengikuti tema default
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitRefund,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue, // Menggunakan warna biru
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                    : const Text(
                        "Ajukan Refund",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(String time, String percentage, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          time, 
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
        ),
        Text(
          percentage, 
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor),
        ),
      ],
    );
  }
}