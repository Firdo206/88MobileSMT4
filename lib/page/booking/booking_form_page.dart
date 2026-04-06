import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../../models/promo_model.dart'; // 👈 TAMBAH
import 'booking_summary_page.dart';

class BookingFormPage extends StatefulWidget {
  final dynamic data;
  final Promo? promo; // 👈 TAMBAH

  const BookingFormPage({
    super.key,
    required this.data,
    this.promo, // 👈 TAMBAH
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  DateTime? selectedDate;
  final TextEditingController jumlahController = TextEditingController(text: "1");
  final TextEditingController catatanController = TextEditingController();

  /// FORMAT DATE
  String formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  /// PICK DATE
  Future pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B2E2E),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _increment() {
    int val = int.tryParse(jumlahController.text) ?? 1;
    if (val < 50) {
      setState(() => jumlahController.text = (val + 1).toString());
    }
  }

  void _decrement() {
    int val = int.tryParse(jumlahController.text) ?? 1;
    if (val > 1) {
      setState(() => jumlahController.text = (val - 1).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F0),

      body: CustomScrollView(
        slivers: [

          /// 🔥 SLIVER APP BAR
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF8B2E2E),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B1E1E), Color(0xFFB84545)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "PAKET WISATA",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Detail Perjalanan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Lengkapi data perjalanan anda",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔥 CARD TANGGAL
                  _sectionCard(
                    icon: Icons.calendar_month_rounded,
                    title: "Tanggal Keberangkatan",
                    required: true,
                    child: GestureDetector(
                      onTap: pickDate,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: selectedDate != null
                              ? const Color(0xFF8B2E2E).withOpacity(0.06)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedDate != null
                                ? const Color(0xFF8B2E2E).withOpacity(0.4)
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              color: selectedDate != null
                                  ? const Color(0xFF8B2E2E)
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? "Pilih tanggal keberangkatan"
                                  : formatDate(selectedDate!),
                              style: TextStyle(
                                color: selectedDate != null
                                    ? const Color(0xFF8B2E2E)
                                    : Colors.grey,
                                fontWeight: selectedDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 🔥 CARD JUMLAH PESERTA
                  _sectionCard(
                    icon: Icons.people_alt_rounded,
                    title: "Jumlah Peserta",
                    required: true,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _decrement,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B2E2E).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.remove_rounded,
                              color: Color(0xFF8B2E2E),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: jumlahController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B2E2E),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffix: Text(
                                "orang",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        GestureDetector(
                          onTap: _increment,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B2E2E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 🔥 CARD CATATAN
                  _sectionCard(
                    icon: Icons.edit_note_rounded,
                    title: "Alamat Penjemputan / Catatan",
                    required: false,
                    child: TextField(
                      controller: catatanController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Misal: Jemput di hotel Aston Seminyak",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B2E2E),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔥 BUTTON LANJUT
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B2E2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pilih tanggal dulu")),
                          );
                          return;
                        }

                        int jumlah = int.parse(jumlahController.text);
                        double harga = double.parse(widget.data['price_per_person'].toString());

                        // 👈 BERUBAH - hitung diskon jika ada promo
                        double discount = 0;
                        if (widget.promo != null) {
                          discount = widget.promo!.discountType == 'percent'
                              ? harga * (widget.promo!.discountValue / 100)
                              : widget.promo!.discountValue;
                        }
                        double hargaFinal = (harga - discount).clamp(0, double.infinity);
                        double total = jumlah * hargaFinal;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingSummaryPage(
                              data: widget.data,
                              date: selectedDate!,
                              jumlah: jumlah,
                              total: total,
                              notes: catatanController.text,
                              promo: widget.promo, // 👈 TAMBAH
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lanjutkan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 SECTION CARD HELPER
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required bool required,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
                  color: const Color(0xFF8B2E2E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF8B2E2E), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                const Text(
                  "*",
                  style: TextStyle(color: Color(0xFF8B2E2E), fontWeight: FontWeight.bold),
                ),
              ]
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}