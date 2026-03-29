import 'package:flutter/material.dart';
import 'transfer_page.dart';
import '../pesanan/pesanan_page.dart';

class PaymentPage extends StatelessWidget {
  final Map data;
  final String type; // rental / tour

  const PaymentPage({
    super.key,
    required this.data,
    required this.type,
  });

  static const Color primary = Color(0xFF7B2D2D);

  /// FORMAT RUPIAH
  String formatPrice(int price) {
    return "Rp ${price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ".",
    )}";
  }

  /// 🔥 FIX TOTAL (ANTI 0)
  int getTotal() {
    dynamic val =
        data["total_price"] ??
        data["amount"] ??
        data["price"] ??
        0;

    if (val.toString().contains(".")) {
      return double.tryParse(val.toString())?.toInt() ?? 0;
    }

    return int.tryParse(val.toString()) ?? 0;
  }

  String safe(val) => val?.toString() ?? "-";

  @override
  Widget build(BuildContext context) {
    final total = getTotal();

    final code = type == "rental"
        ? safe(data['rental_code'])
        : safe(data['booking_code']);

    final title = type == "rental"
        ? "Pesan Sewa Bus"
        : "Pesan Paket Wisata";

    return WillPopScope(
    onWillPop: () async {
      bool keluar = await _showExitDialog(context);

      if (keluar) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => PesananPage()),
          (route) => false,
        );
      }

      return false; // ❗ penting → biar gak auto pop
    },
    child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),

      /// 🔥 APPBAR MIRIP TIKET
      appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          bool keluar = await _showExitDialog(context);

          if (keluar) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => PesananPage()),
              (route) => false,
            );
          }
        },
      ),
    ),

      body: Column(
        children: [

          /// 🔥 TIMER (TIRU TIKET)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Selesaikan pembayaran sebelum waktu habis",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const Text(
                  "00:15:00",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
      
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  /// 🔥 DETAIL CARD (MIRIP TIKET)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Detail Pesanan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _row("Kode", code),

                        if (type == "rental") ...[
                          _row("Pickup", safe(data['pickup_location'])),
                          _row("Tujuan", safe(data['destination'])),
                          _row(
                            "Tanggal",
                            "${safe(data['start_date'])} - ${safe(data['end_date'])}",
                          ),
                        ] else ...[
                          _row("Tanggal", safe(data['travel_date'])),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔥 TOTAL CARD (MIRIP TIKET)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEFD5D5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔥 BARIS ATAS (BIAR KAYAK TIKET)
                        Text(
                          formatPrice(total),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// TOTAL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Pembayaran",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatPrice(total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Lakukan pembayaran pada pesanan",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔥 BUTTON
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransferPage(
                        id: data['id'] ?? 0,
                        code: code,
                        total: total,
                        type: type,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Lanjut ke Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Keluar Pembayaran"),
            content: const Text(
              "Lanjutkan bayar nanti?\nPesananmu ada di menu Pesanan.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("Tidak"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Ya"),
              ),
            ],
          ),
        ) ??
        false;
  }
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}