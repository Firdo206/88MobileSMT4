import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_color.dart';
import '../../models/promo_model.dart'; 
import '../../services/booking_paket_service.dart';
import '../payment/payment_page.dart';

class BookingSummaryPage extends StatelessWidget {
  final dynamic data;
  final DateTime date;
  final int jumlah;
  final double total;
  final String notes;
  final Promo? promo; 

  const BookingSummaryPage({
    super.key,
    required this.data,
    required this.date,
    required this.jumlah,
    required this.total,
    required this.notes,
    this.promo, 
  });

  String formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return "${d.day} ${months[d.month]} ${d.year}";
  }

  String formatRupiah(double value) {
    return "Rp ${value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}";
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = data['image_url'] ?? '';
    double harga = double.parse(data['price_per_person'].toString());

    // 🔥 FIX - tambah .trim().toLowerCase() agar konsisten
    double discount = 0;
    if (promo != null) {
      discount = promo!.discountType.trim().toLowerCase() == 'percentage'
          ? harga * (promo!.discountValue / 100)
          : promo!.discountValue;
    }
    double hargaFinal = (harga - discount).clamp(0, double.infinity);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F0),
      body: CustomScrollView(
        slivers: [

          /// 🔥 APP BAR
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF8B2E2E),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Ringkasan Pesanan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [

                /// 🔥 HERO IMAGE
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF8B2E2E).withOpacity(0.2),
                          child: const Icon(Icons.image_not_supported,
                              size: 60, color: Colors.white54),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "${data['duration_days']} hari perjalanan",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      /// 🔥 DETAIL PERJALANAN
                      _card(
                        title: "Detail Perjalanan",
                        icon: Icons.luggage_rounded,
                        child: Column(
                          children: [
                            _infoRow(
                              icon: Icons.calendar_today_rounded,
                              label: "Tanggal",
                              value: formatDate(date),
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              icon: Icons.people_alt_rounded,
                              label: "Peserta",
                              value: "$jumlah orang",
                            ),
                            if (notes.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _infoRow(
                                icon: Icons.edit_note_rounded,
                                label: "Catatan",
                                value: notes,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// 🔥 RINCIAN HARGA
                      _card(
                        title: "Rincian Harga",
                        icon: Icons.receipt_long_rounded,
                        child: Column(
                          children: [
                            // 👈 BERUBAH - tampilkan harga normal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$jumlah orang × ${formatRupiah(harga)}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                Text(
                                  formatRupiah(harga * jumlah),
                                  style: TextStyle(
                                    fontSize: 13,
                                    decoration: promo != null
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: promo != null
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),

                            // 👈 TAMBAH - tampilkan baris diskon jika ada promo
                            if (promo != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Diskon "${promo!.title}"',
                                    style: const TextStyle(
                                        color: Colors.green, fontSize: 13),
                                  ),
                                  Text(
                                    '- ${formatRupiah(discount * jumlah)}',
                                    style: const TextStyle(
                                        color: Colors.green, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Pembayaran",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  formatRupiah(total),
                                  style: const TextStyle(
                                    color: Color(0xFF8B2E2E),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B2E2E).withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF8B2E2E).withOpacity(0.15),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: Color(0xFF8B2E2E), size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Harga sudah termasuk semua pajak dan biaya layanan",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8B2E2E)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// 🔥 BUTTON
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
                          onPressed: () async {
                            bool lanjut = await _showConfirmDialog(context);
                            if (!lanjut) return;

                            await Future.delayed(const Duration(milliseconds: 150));

                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt("user_id") ?? 0;

                            final result = await BookingPaketService.createBooking(
                              userId: userId,
                              tourId: data['id'],
                              date: "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                              qty: jumlah,
                              total: total,
                              notes: notes,
                            );

                            print(result);

                            if (result['success'] == true) {
                              final bookingData = result['data'];
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentPage(
                                    data: bookingData,
                                    type: "tour",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ?? "Gagal booking"),
                                ),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Lanjutkan Pembayaran",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
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
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAECE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFFD85A30),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Konfirmasi Pesanan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pesanan akan langsung dibuat dan masuk ke menu Pesanan.\n\nLanjutkan pembayaran sekarang?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Paket",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              Flexible(
                                child: Text(
                                  data['name'] ?? '-',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Tanggal",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              Text(
                                formatDate(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Peserta",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              Text(
                                "$jumlah orang",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                formatRupiah(total),
                                style: const TextStyle(
                                  color: Color(0xFF8B2E2E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text("Cek Lagi"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B2E2E),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lanjutkan",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }
}