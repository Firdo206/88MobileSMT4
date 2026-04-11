import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../services/payment_service.dart';
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
  bool _isLoadingMidtrans = false;
  bool _isLoadingCheck = false;
  bool _sudahBayar = false;

  // ================= MIDTRANS =================
  Future<String?> getSnapToken(int bookingId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.midtransPayment),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"booking_id": bookingId}),
      );

      final data = jsonDecode(response.body);
      debugPrint("RESPONSE MIDTRANS: ${response.body}");

      if (response.statusCode == 200 && data['status'] == true) {
        return data['snap_token'];
      } else {
        debugPrint("Gagal token: ${data.toString()}");
        return null;
      }
    } catch (e) {
      debugPrint("Error Midtrans: $e");
      return null;
    }
  }

  Future<void> openMidtrans(int bookingId) async {
    if (_isLoadingMidtrans) return;

    setState(() => _isLoadingMidtrans = true);

    final token = await getSnapToken(bookingId);

    if (token == null) {
      setState(() => _isLoadingMidtrans = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka pembayaran")),
      );
      return;
    }

    final url = "https://app.sandbox.midtrans.com/snap/v2/vtweb/$token";

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Launch error: $e");
    }

    setState(() {
      _isLoadingMidtrans = false;
      _sudahBayar = true;
    });
  }

  // ================= CEK STATUS =================
  Future<void> _checkStatus(int bookingId) async {
    if (_isLoadingCheck) return;
    setState(() => _isLoadingCheck = true);

    final status = await PaymentService.checkStatus(bookingId);

    setState(() => _isLoadingCheck = false);

    if (status == 'settlement' || status == 'capture') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Pembayaran berhasil dikonfirmasi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⏳ Pembayaran masih pending, harap tunggu..."),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (status != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: $status")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengecek status pembayaran")),
      );
    }
  }
  // ============================================

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
    final rawSeats = widget.bookingData['seats'];
    final rawPassengers = widget.bookingData['passengers'];

    final seats = rawSeats is List
        ? rawSeats
        : (rawSeats is String && rawSeats.isNotEmpty)
            ? rawSeats.split(',')
            : [];

    final passengers = rawPassengers is List ? rawPassengers : [];

    final seatCount = seats.isNotEmpty
        ? seats.length
        : (widget.bookingData['seat_count'] ?? 1);

    // 🔥 FIX - prioritaskan final_price (harga setelah diskon promo) jika ada
    final int totalPrice = (() {
      // Cek apakah ada final_price dari promo
      final finalPriceRaw = widget.bookingData['final_price'];
      if (finalPriceRaw != null) {
        final parsed = double.tryParse(finalPriceRaw.toString());
        if (parsed != null && parsed > 0) return parsed.toInt();
      }
      // Fallback ke total_price dari API
      final totalPriceRaw = int.tryParse(
        widget.bookingData['total_price']?.toString() ?? "0",
      );
      if (totalPriceRaw != null && totalPriceRaw > 0) return totalPriceRaw;
      // Fallback hitung manual
      return seatCount *
          (int.tryParse(widget.bookingData['price']?.toString() ?? "0") ?? 0);
    })();

    // 🔥 Ambil info diskon jika ada
    final discountAmount = widget.bookingData['discount_amount'];
    final promoTitle = widget.bookingData['promo_title'];
    final hasPromo = promoTitle != null && discountAmount != null;

    // Harga normal (sebelum diskon) untuk ditampilkan jika ada promo
    final int totalNormal = hasPromo
        ? (totalPrice +
            (double.tryParse(discountAmount.toString())?.toInt() ?? 0))
        : totalPrice;

    final pricePerSeat = seatCount == 0 ? 0 : (totalNormal ~/ seatCount);

    final bookingId = int.tryParse(
          (widget.bookingData['id'] ?? widget.bookingData['booking_id'])
              ?.toString() ?? "0",
        ) ?? 0;

    final bookingCode = widget.bookingData['booking_code'] ?? "";

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
          // Step indicator
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
                  // Timer countdown
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

                  // Detail Pesanan
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
                        if (passengers.isNotEmpty)
                          ...passengers.map((p) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5EAEA),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(8)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        p['seat']?.toString() ?? "-",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p['passenger_name'] ?? "-"),
                                        Text(p['phone'] ?? "", style: const TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                              ))
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

                  // 🔥 Ringkasan Harga — tampilkan diskon jika ada promo
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
                        // Banner promo jika ada
                        if (hasPromo) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_rounded, color: Colors.green, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Promo "$promoTitle" diterapkan',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        Text(
                          "$seatCount Kursi x ${formatPrice(pricePerSeat)}",
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),

                        const SizedBox(height: 8),

                        // Harga normal dicoret jika ada promo
                        if (hasPromo) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Harga Normal", style: TextStyle(fontSize: 13, color: Colors.black54)),
                              Text(
                                formatPrice(totalNormal),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Diskon "$promoTitle"', style: const TextStyle(fontSize: 13, color: Colors.green)),
                              Text(
                                '- ${formatPrice(double.tryParse(discountAmount.toString())?.toInt() ?? 0)}',
                                style: const TextStyle(fontSize: 13, color: Colors.green),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                        ],

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

          // ================= TOMBOL BAYAR =================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                // 🔴 Tombol Midtrans
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_isExpired || _isLoadingMidtrans)
                        ? null
                        : () async => await openMidtrans(bookingId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoadingMidtrans
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Bayar dengan Midtrans",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                // ⚪ Tombol Transfer Manual
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isExpired
                        ? null
                        : () {
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
                      backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Transfer Manual",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),

                // 🟢 Tombol Cek Status — muncul SETELAH user buka Midtrans
                if (_sudahBayar) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isLoadingCheck
                          ? null
                          : () async => await _checkStatus(bookingId),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7B2D2D), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoadingCheck
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF7B2D2D),
                              ),
                            )
                          : const Text(
                              "Cek Status Pembayaran",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7B2D2D),
                              ),
                            ),
                    ),
                  ),
                ],
              ],
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