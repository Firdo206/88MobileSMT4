import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../../services/booking_paket_service.dart';
import '../payment/payment_page.dart';

class BookingSummaryPage extends StatelessWidget {
  final dynamic data;
  final DateTime date;
  final int jumlah;
  final double total;
  final String notes;

  const BookingSummaryPage({
    super.key,
    required this.data,
    required this.date,
    required this.jumlah,
    required this.total,
    required this.notes,
  });

  String formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = data['image_url'] ?? '';
    double harga = double.parse(data['price_per_person'].toString());

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const Text(
              "Ringkasan pesanan anda",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            /// 🔥 CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 70,
                            width: 70,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${data['duration_days']} hari",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  /// HARGA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Harga per Orang",
                          style: TextStyle(color: Colors.grey)),
                      Text("Rp ${harga.toStringAsFixed(0)}"),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// TOTAL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rp ${total.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// INFO
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "*Harga sudah termasuk semua pajak dan biaya layanan yang berlaku",
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),

            const Spacer(),

            /// 🔥 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
               onPressed: () async {

                  /// 🔥 MUNCULIN KONFIRMASI DULU
                 bool lanjut = await _showConfirmDialog(context);

                  if (!lanjut) return;

                  /// 🔥 kasih jeda dikit biar dialog nutup dulu
                  await Future.delayed(const Duration(milliseconds: 150));
                  final result = await BookingPaketService.createBooking(
                    userId: 1,
                    tourId: data['id'],
                    date:
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
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
                child: const Text("Lanjutkan Pembayaran →"),
              ),
            ),

          ],
        ),
      ),
    );
  }

    Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 🔥 ICON
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColor.primary,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 🔥 TITLE
                    const Text(
                      "Konfirmasi Pesanan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🔥 DESC
                    const Text(
                      "Pesanan akan langsung dibuat dan masuk ke menu Pesanan.\n\nLanjutkan pembayaran sekarang?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 BUTTONS
                    Row(
                      children: [

                        /// ❌ CEK LAGI
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Cek Lagi"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// ✅ LANJUTKAN
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Lanjutkan"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }
}