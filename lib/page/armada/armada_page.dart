import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/rental_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_color.dart';
import 'dart:convert';
import '../navigation/main_page.dart';
import 'package:http/http.dart' as http;

class ArmadaPage extends StatefulWidget {
  const ArmadaPage({super.key});

  @override
  State<ArmadaPage> createState() => _ArmadaPageState();
}

class _ArmadaPageState extends State<ArmadaPage> {
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final contactNameController = TextEditingController();
  final phoneController = TextEditingController();
  final purposeController = TextEditingController();
  final passengerController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false;

  // ─── Branding warna Bus 88 ─────────────────────────────────
  static const Color kRed = Color(0xFFD32F2F);
  static const Color kRedLight = Color(0xFFFFEBEE);
  static const Color kRedDark = Color(0xFFB71C1C);
  static const Color kBg = Color(0xFFFFF8F8);
  static const Color kCard = Colors.white;
  static const Color kText = Color(0xFF1A1A1A);
  static const Color kTextMuted = Color(0xFF9E9E9E);
  static const Color kGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      contactNameController.text = prefs.getString("name") ?? "";
      phoneController.text = prefs.getString("phone") ?? "";
    });
  }

  Future pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kRed,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          startDate = picked;
        else
          endDate = picked;
      });
    }
  }

  Future<void> submit() async {
    if (startDate == null || endDate == null)
      return _show("Tanggal wajib diisi");
    if (pickupController.text.isEmpty ||
        destinationController.text.isEmpty ||
        contactNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        purposeController.text.isEmpty ||
        passengerController.text.isEmpty) {
      return _show("Semua field wajib diisi");
    }
    int passengerCount = int.tryParse(passengerController.text) ?? 0;
    if (passengerCount <= 0) return _show("Jumlah penumpang tidak valid");

    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("user_id") ?? 0;
      bool success = await RentalService.createRental(
        userId: userId,
        startDate: startDate.toString().substring(0, 10),
        endDate: endDate.toString().substring(0, 10),
        pickup: pickupController.text,
        destination: destinationController.text,
        contactName: contactNameController.text,
        phone: phoneController.text,
        busId: null, // ✅ selalu null, admin yang memilih
        purpose: purposeController.text,
        passengerCount: passengerCount,
      );
      if (success) {
        _show("Berhasil booking 🚀");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 2)),
        );
      } else {
        _show("Gagal booking ❌");
      }
    } catch (e) {
      _show("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── APP BAR ─────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 130,
                backgroundColor: kRed,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kRedDark, kRed],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -10,
                          left: 60,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 56,
                              bottom: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "88",
                                        style: TextStyle(
                                          color: kRed,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Bus 88",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Sewa Armada",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── INFO SEWA ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                          boxShadow: [
                            BoxShadow(
                              color: kRed.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: kRedLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: kRed,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Informasi Sewa",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: kText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _infoItem(
                              "Pengajuan direview admin dalam 1×24 jam",
                            ),
                            _infoItem("Harga disepakati setelah verifikasi"),
                            _infoItem("Pembayaran aman via Midtrans"),
                            _infoItem("Armada terawat & supir berpengalaman"),
                            // ✅ tambah info bahwa admin yang pilih bus
                            _infoItem("Armada dipilihkan oleh admin sesuai kebutuhan"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── FORM CARD ──────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: kRedLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.edit_note_rounded,
                                      color: kRed,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Form Permintaan Sewa",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: kText,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                            const Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Color(0xFFF5F5F5),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tanggal
                                  _formLabel(
                                    "Tanggal Mulai *",
                                    "Tanggal Selesai *",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _dateCard(
                                          "Tanggal Mulai",
                                          startDate,
                                          () => pickDate(true),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _dateCard(
                                          "Tanggal Selesai",
                                          endDate,
                                          () => pickDate(false),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  // Lokasi & Tujuan
                                  _formLabel(
                                    "Lokasi Penjemputan *",
                                    "Tujuan *",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _inputBox(
                                          controller: pickupController,
                                          hint: "Contoh: Hotel Grand, Jkt",
                                          icon: Icons.location_on_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _inputBox(
                                          controller: destinationController,
                                          hint: "Contoh: Bandung",
                                          icon: Icons.flag_outlined,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  // ✅ Bus dipilih admin — tampilkan sebagai info, bukan dropdown
                                  _singleLabel("Armada Bus"),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kRedLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFFCDD2),
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.directions_bus_outlined,
                                          color: kRed,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "Armada akan dipilihkan oleh admin",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: kRed,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.auto_awesome_outlined,
                                          color: kRed,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // Penumpang & Keperluan
                                  _formLabel(
                                    "Jumlah Penumpang",
                                    "Tujuan/Keperluan",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _inputBox(
                                          controller: passengerController,
                                          hint: "Perkiraan",
                                          icon: Icons.people_outline,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _inputBox(
                                          controller: purposeController,
                                          hint: "Wisata, Kantor, dll",
                                          icon: Icons.description_outlined,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  // Nama & Telepon
                                  _formLabel(
                                    "Nama Kontak *",
                                    "No. Telepon Kontak *",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _inputBox(
                                          controller: contactNameController,
                                          hint: "Nama lengkap",
                                          icon: Icons.person_outline,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _inputBox(
                                          controller: phoneController,
                                          hint: "08xxxxxxxxxx",
                                          icon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Submit
                                  GestureDetector(
                                    onTap: isLoading ? null : submit,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: double.infinity,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isLoading
                                              ? [
                                                  Colors.grey.shade400,
                                                  Colors.grey.shade500,
                                                ]
                                              : [kRed, kRedDark],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: isLoading
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: kRed.withOpacity(0.35),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.send_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Kirim Permintaan",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (isLoading) Container(color: Colors.black.withOpacity(0.15)),
        ],
      ),
    );
  }

  // ─── HELPER WIDGETS ─────────────────────────────────────────────────

  Widget _infoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: kGreen, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF424242),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formLabel(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _singleLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: kText,
      ),
    );
  }

  Widget _dateCard(String title, DateTime? date, VoidCallback onTap) {
    final bool hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: hasDate ? kRedLight : Colors.white,
          border: Border.all(
            color: hasDate ? kRed : const Color(0xFFE0E0E0),
            width: hasDate ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: hasDate ? kRed : kTextMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasDate ? date.toString().substring(0, 10) : "dd/mm/yyyy",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                  color: hasDate ? kRed : kTextMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 13, color: kText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
          prefixIcon: Icon(icon, size: 17, color: kTextMuted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kRed, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 4,
          ),
          isDense: true,
        ),
      ),
    );
  }
}