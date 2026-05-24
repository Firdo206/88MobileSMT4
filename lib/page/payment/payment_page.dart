import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import '../../services/api_service.dart';
import '../../services/payment_service.dart';
import '../pesanan/pesanan_page.dart';
import '../navigation/main_page.dart';

class PaymentPage extends StatefulWidget {
  final Map data;
  final String type;

  const PaymentPage({super.key, required this.data, required this.type});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Color primary = Color(0xFF7B2D2D);

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;
  bool _isLoadingMidtrans = false;
  bool _isLoadingCheck = false;
  bool _sudahBayar = false;
  bool _tokenRequested = false;

  final _appLinks = AppLinks();
  StreamSubscription? _linkSub;

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  String safe(dynamic val) => val?.toString() ?? "-";

  String formatPrice(int price) {
    return "Rp ${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ".")}";
  }

  int getTotal() {
    final val =
        widget.data["total_price"] ??
        widget.data["amount"] ??
        widget.data["price"] ??
        0;
    final str = val.toString();
    if (str.contains(".")) return double.tryParse(str)?.toInt() ?? 0;
    return int.tryParse(str) ?? 0;
  }

  int get bookingId {
    final raw =
        widget.data['id'] ??
        widget.data['booking_id'] ??
        widget.data['tour_booking_id'] ??
        0;
    return int.tryParse(raw.toString()) ?? 0;
  }

  String get bookingCode => type == "rental"
      ? safe(widget.data['rental_code'])
      : safe(widget.data['booking_code']);

  String get type => widget.type;

  @override
  void initState() {
    super.initState();
    debugPrint("DATA RENTAL: ${widget.data}");
    _startCountdown();
    _listenDeepLink();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
  void _listenDeepLink() {
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      debugPrint("DEEP LINK RECEIVED: $uri");
      if (uri.scheme == 'app88trans') {
        final transactionStatus = uri.queryParameters['transaction_status'];
        debugPrint("TRANSACTION STATUS FROM URL: $transactionStatus");

        if (transactionStatus == 'settlement' ||
            transactionStatus == 'capture') {
          if (mounted) _checkStatus();
        } else {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const MainPage(initialIndex: 2),
              ),
              (route) => false,
            );
          }
        }
      }
    });
  }

  // ─────────────────────────────────────────
  // COUNTDOWN — dengan fallback created_at + 24 jam
  // ─────────────────────────────────────────

  DateTime? _parseDateTime(dynamic raw) {
  if (raw == null) return null;
  final str = raw.toString().trim();
  if (str.isEmpty) return null;
  return DateTime.tryParse(str);
}

  void _startCountdown() {
    DateTime? expiry = _parseDateTime(widget.data['expired_at']);
    if (expiry == null) {
      final created = _parseDateTime(widget.data['created_at']);
      if (created != null) {
        expiry = created.add(const Duration(hours: 1));
        debugPrint("TIMER: expired_at tidak ada, pakai created_at + 24 jam => $expiry");
      }
    }

    if (expiry == null) {
      debugPrint("TIMER: tidak bisa hitung expiry, timer tidak jalan");
      return;
    }

    _remaining = expiry.difference(DateTime.now());

    if (_remaining.isNegative) {
      if (mounted) setState(() => _isExpired = true);
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
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

  // ─────────────────────────────────────────
  // MIDTRANS
  // ─────────────────────────────────────────

  Future<String?> _getSnapToken(int id) async {
    try {
      final endpoint = type == "tour"
          ? ApiService.midtransPaymentTour
          : ApiService.midtransPayment;

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"booking_id": id}),
      );

      debugPrint("=== MIDTRANS DEBUG ===");
      debugPrint("URL: $endpoint");
      debugPrint("BOOKING ID: $id");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY RAW: ${response.body}");
      debugPrint("=====================");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return data['snap_token'];
      }
      debugPrint("Gagal snap token: ${data.toString()}");
      return null;
    } catch (e) {
      debugPrint("Error Midtrans: $e");
      return null;
    }
  }

  Future<void> _openMidtrans() async {
    if (_isLoadingMidtrans || _tokenRequested) return;
    if (mounted) setState(() => _isLoadingMidtrans = true);
    _tokenRequested = true;

    final token = await _getSnapToken(bookingId);

    if (token == null) {
      if (mounted) {
        setState(() => _isLoadingMidtrans = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka pembayaran")),
        );
      }
      _tokenRequested = false;
      return;
    }

    final url = "https://app.sandbox.midtrans.com/snap/v2/vtweb/$token";

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Launch error: $e");
    }

    if (mounted) {
      setState(() {
        _isLoadingMidtrans = false;
        _sudahBayar = true;
      });
    }
  }

  // ─────────────────────────────────────────
  // CEK STATUS PEMBAYARAN
  // ─────────────────────────────────────────

  Future<void> _checkStatus() async {
    if (_isLoadingCheck) return;
    if (mounted) setState(() => _isLoadingCheck = true);

    final status = await PaymentService.checkStatus(bookingId);

    if (!mounted) return;

    setState(() => _isLoadingCheck = false);

    if (status == 'settlement') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Pembayaran berhasil dikonfirmasi!"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⏳ Pembayaran masih pending, harap tunggu..."),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${status ?? 'gagal cek'}")),
      );
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 2)),
      (route) => false,
    );
  }

  // ─────────────────────────────────────────
  // EXIT DIALOG
  // ─────────────────────────────────────────

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (_) => Dialog(
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
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.orange.shade700,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Keluar Pembayaran?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tenang, pesananmu tetap tersimpan dan bisa dilanjutkan di menu Pesanan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Tidak"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Ya, Keluar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  Future<void> _handleBack() async {
    final keluar = await _showExitDialog();
    if (keluar && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 2)),
        (route) => false,
      );
    }
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = getTotal();
    final title = type == "rental" ? "Pesan Sewa Bus" : "Pesan Paket Wisata";

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0F0),
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTimer(),
                    const SizedBox(height: 14),
                    _card(
                      title: "Detail Pesanan",
                      icon: Icons.luggage_rounded,
                      child: Column(
                        children: [
                          _infoRow(
                            icon: Icons.confirmation_number_rounded,
                            label: "Kode",
                            valueWidget: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                bookingCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          if (type == "rental") ...[
                            const SizedBox(height: 12),
                            _infoRow(
                              icon: Icons.location_on_rounded,
                              label: "Pickup",
                              valueWidget: _valueText(
                                safe(widget.data['pickup_location']),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              icon: Icons.flag_rounded,
                              label: "Tujuan",
                              valueWidget: _valueText(
                                safe(widget.data['destination']),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              icon: Icons.calendar_today_rounded,
                              label: "Tanggal",
                              valueWidget: _valueText(
                                "${safe(widget.data['start_date'])} - ${safe(widget.data['end_date'])}",
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            _infoRow(
                              icon: Icons.map_rounded,
                              label: "Paket",
                              valueWidget: _valueText(
                                safe(
                                  widget.data['tour_name'] ??
                                      widget.data['package_name'],
                                      
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              icon: Icons.calendar_today_rounded,
                              label: "Tanggal",
                              valueWidget: _valueText(
                                safe(widget.data['travel_date']),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              icon: Icons.people_rounded,
                              label: "Peserta",
                              valueWidget: _valueText(
                                safe(
                                  widget.data['participants'] ??
                                      widget.data['pax'],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _card(
                      title: "Rincian Harga",
                      icon: Icons.receipt_long_rounded,
                      child: Column(
                        children: [
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
                                formatPrice(total),
                                style: const TextStyle(
                                  color: primary,
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
                              color: primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primary.withOpacity(0.15),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: primary,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Lakukan pembayaran sesuai nominal di atas",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── TOMBOL BAYAR ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_isExpired || _isLoadingMidtrans || _tokenRequested)
                          ? null
                          : _openMidtrans,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isLoadingMidtrans
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payment_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Bayar Sekarang",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  if (_sudahBayar) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isLoadingCheck ? null : _checkStatus,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoadingCheck
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primary,
                                ),
                              )
                            : const Text(
                                "Lihat Pesanan Saya",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
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
      ),
    );
  }

  // ─────────────────────────────────────────
  // WIDGET HELPERS
  // ─────────────────────────────────────────

  Widget _buildTimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _isExpired ? const Color(0xFFFFEBEE) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isExpired ? const Color(0xFFEF9A9A) : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_isExpired ? Colors.red : Colors.orange).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isExpired ? Icons.cancel_rounded : Icons.access_time_rounded,
              color: _isExpired ? Colors.red : Colors.orange.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _isExpired
                ? const Text(
                    "Waktu pembayaran habis. Pesanan telah dibatalkan.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Text(
                    "Selesaikan pembayaran sebelum waktu habis",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade800,
                    ),
                  ),
          ),
          if (!_isExpired) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatCountdown(_remaining),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
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
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primary, size: 18),
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
    required Widget valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        valueWidget,
      ],
    );
  }

  Widget _valueText(String value) {
    return Flexible(
      child: Text(
        value,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }
}