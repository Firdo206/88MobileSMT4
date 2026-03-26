import 'dart:async';
import 'package:flutter/material.dart';
import 'transfer_page.dart';

class PaymentPage extends StatefulWidget {
  final Map bookingData;

  const PaymentPage({
    super.key,
    required this.bookingData,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Color _primary = Color(0xFF7B2D2D);

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    final expiredAt = widget.bookingData['expired_at'];
    if (expiredAt == null) return;

    final rawString = expiredAt.toString().trim();
    if (rawString.isEmpty) return;

    DateTime? expiry;

    // Jika format tidak mengandung timezone info (dari Laravel tanpa 'Z' atau '+'),
    // anggap sebagai UTC lalu convert ke local (fix timezone WIB UTC+7)
    if (!rawString.contains('+') && !rawString.toUpperCase().contains('Z')) {
      expiry = DateTime.tryParse(rawString + 'Z')?.toLocal();
    } else {
      expiry = DateTime.tryParse(rawString)?.toLocal();
    }

    if (expiry == null) return;

    _remaining = expiry.difference(DateTime.now());

    if (_remaining.isNegative) {
      setState(() => _isExpired = true);
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = expiry!.difference(DateTime.now());
      if (diff.isNegative) {
        setState(() {
          _remaining = Duration.zero;
          _isExpired = true;
        });
        _timer?.cancel();
      } else {
        setState(() => _remaining = diff);
      }
    });
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return "Rp. $formatted";
  }

  @override
  Widget build(BuildContext context) {
    final seats = widget.bookingData['seats'] ?? [];
    final totalPrice = int.tryParse(widget.bookingData['total_price'].toString()) ?? 0;

    final bookingId = int.tryParse(
          (widget.bookingData['id'] ?? widget.bookingData['booking_id'])?.toString() ?? "0",
        ) ?? 0;

    final bookingCode = widget.bookingData['booking_code'] ?? "";
    final pricePerSeat = seats.isEmpty ? 0 : totalPrice ~/ seats.length;
    final passengers = widget.bookingData['passengers'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          "Pesan Tiket",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // ── Step Indicator ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            child: Row(
              children: [
                Expanded(child: Container(height: 1.5, color: _primary)),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text("3", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Text("Pembayaran", style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w600)),
                Expanded(child: Container(height: 1.5, color: Colors.grey.shade300)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // ── Warning box dengan countdown ────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isExpired ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isExpired ? const Color(0xFFEF9A9A) : const Color(0xFFFFCC80),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isExpired ? Icons.cancel_rounded : Icons.access_time_rounded,
                          color: _isExpired ? Colors.red : const Color(0xFFE65100),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _isExpired
                              ? const Text(
                                  "Waktu pembayaran habis. Pesanan ini telah dibatalkan.",
                                  style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Selesaikan pembayaran sebelum waktu habis",
                                      style: TextStyle(fontSize: 12, color: Color(0xFF5D3A00)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCountdown(_remaining),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE65100),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Detail Pesanan ──────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Detail Pesanan", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        _buildRow("Kode Booking", widget.bookingData['booking_code'] ?? "-"),
                        _buildRow("Rute", "${widget.bookingData['origin'] ?? '-'} → ${widget.bookingData['destination'] ?? '-'}"),
                        _buildRow("Tanggal", widget.bookingData['departure_date'] ?? "-"),
                        _buildRow("Jam", widget.bookingData['departure_time'] ?? "-"),
                        _buildRow("Bus", widget.bookingData['bus_name'] ?? "-"),

                        const SizedBox(height: 14),
                        const Text("Penumpang", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 8),

                        // ✅ Tampil per penumpang jika ada, fallback ke 1 nama
                        if (passengers.isNotEmpty)
                          ...passengers.map((p) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: const Color(0xFFF5EAEA), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(8)),
                                  alignment: Alignment.center,
                                  child: Text(p['seat'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['passenger_name'] ?? "-", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                                    if ((p['phone'] ?? '').toString().isNotEmpty)
                                      Text(p['phone'].toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          )).toList()
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: const Color(0xFFF5EAEA), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(8)),
                                  child: Text(seats.join(", "), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                const SizedBox(width: 12),
                                Text(widget.bookingData['passenger_name'] ?? "-", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Ringkasan Harga ─────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEFD5D5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${seats.length} Kursi x ${formatPrice(pricePerSeat)}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Pembayaran", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                            Text(formatPrice(totalPrice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Lakukan Pembayaran pada pesanan",
                            style: TextStyle(fontSize: 12, color: _primary, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tombol Lanjut ───────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isExpired ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransferPage(
                        bookingId: bookingId,
                        total: totalPrice,
                        bookingCode: bookingCode,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isExpired ? Colors.grey : _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpired ? "Pesanan Dibatalkan" : "Lanjut ke Pembayaran",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    if (!_isExpired) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}