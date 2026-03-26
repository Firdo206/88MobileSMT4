import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../../services/booking_paket_service.dart';

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

            /// 🔥 CARD UTAMA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔥 HEADER (GAMBAR + NAMA)
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
                                fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text("${data['duration_days']} hari",
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  /// 🔥 HARGA PER ORANG
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Harga per Orang",
                          style: TextStyle(color: Colors.grey)),
                      Text("Rp ${harga.toStringAsFixed(0)}"),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 🔥 TOTAL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
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

                  /// 🔥 INFO BOX
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

            /// 🔥 BUTTON BAYAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {

                  /// 🔥 HIT API SIMPAN DB
                  final result = await BookingService.createBooking(
                    userId: 1,
                    tourId: data['id'],
                    date: "${date.year}-${date.month}-${date.day}",
                    qty: jumlah,
                    total: total,
                    notes: notes,
                  );

                  print(result);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Booking berhasil!")),
                  );

                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Lanjutkan Pembayaran →"),
              ),
            )
          ],
        ),
      ),
    );
  }
}