import 'package:flutter/material.dart';
import '../booking/payment_page.dart';
import '../payment/payment_page.dart' as other;
import 'widgets/detail_pesanan_service.dart';
import 'widgets/detail_pesanan_pdf.dart';
import 'refund_page.dart';
import '../profil/review_page.dart';

class DetailPesananPage extends StatelessWidget {
  final Map data;
  final String type;
  const DetailPesananPage({
    super.key,
    required this.data,
    required this.type,
  });

  // ─── Helpers ───────────────────────────────────────────────
  String get statusFinal => data["status_final"] ?? "-";

  String get _reviewType {
  if (type == "ticket") return "booking";
  if (type == "bus")    return "rental";
  return "tour";
}

  String rupiah(dynamic value) {
    int v = int.tryParse(value.toString()) ?? 0;
    return v
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.");
  }

  int getPrice() {
    final fp = data["final_price"];
    if (fp != null) {
      final p = double.tryParse(fp.toString());
      if (p != null && p > 0) return p.toInt();
    }
    dynamic val = data["total_price"] ?? data["amount"] ?? data["price"] ?? 0;
    if (val.toString().contains(".")) return double.tryParse(val.toString())?.toInt() ?? 0;
    return int.tryParse(val.toString()) ?? 0;
  }

  List<String> parseDestinations(dynamic value) {
    if (value == null) return [];
    return value
        .toString()
        .replaceAll('[', '').replaceAll(']', '').replaceAll('"', '')
        .split(',')
        .map((e) => e.trim())
        .toList();
  }

  Map? get firstPassenger {
    final p = data["passengers"];
    return (p is List && p.isNotEmpty) ? p[0] as Map? : null;
  }

  String get displayName =>
      (data["name"] ?? data["passenger_name"] ?? data["contact_name"])?.toString().isNotEmpty == true
          ? (data["name"] ?? data["passenger_name"] ?? data["contact_name"]).toString()
          : firstPassenger?["passenger_name"]?.toString() ?? "-";

  String get displayPhone =>
      (data["phone"] ?? data["contact_phone"])?.toString().isNotEmpty == true
          ? (data["phone"] ?? data["contact_phone"]).toString()
          : firstPassenger?["phone"]?.toString() ?? "-";

  String get displayEmail => data["email"]?.toString() ?? "-";

  // ─── Status ─────────────────────────────────────────────────
  // Mapping lengkap sesuai backend:
  //   pending_refund → user ajukan refund, admin belum proses
  //   refund         → nilai lama (samakan dengan pending_refund)
  //   refunded       → admin set status "completed" → uang sudah dikembalikan
  static const _statusMap = {
    "pending_payment":     (Color(0xFFFF9800), "Belum Bayar"),
    "waiting_confirmation":(Color(0xFF2196F3), "Wait Confirm"),
    "waiting_approval":    (Color(0xFF2196F3), "Wait Approval"),
    "paid":                (Color(0xFF4CAF50), "Lunas"),
    "completed":           (Color(0xFF9E9E9E), "Selesai"),
    "cancelled":           (Color(0xFFF44336), "Dibatalkan"),
    "rejected":            (Color(0xFFF44336), "Ditolak"),
    "pending_refund":      (Color(0xFF9C27B0), "Menunggu Refund"),
    "refund":              (Color(0xFF9C27B0), "Menunggu Refund"),
    "refunded":            (Color(0xFF00BCD4), "Refund Selesai"),  // ← admin set completed
  };

  String get _paymentStatus => data["payment_status"]?.toString() ?? statusFinal;

  Color statusColor() => _statusMap[_paymentStatus]?.$1 ?? _statusMap[statusFinal]?.$1 ?? const Color(0xFF9E9E9E);
  String statusText()  => _statusMap[_paymentStatus]?.$2 ?? _statusMap[statusFinal]?.$2 ?? "-";

  // Helper: apakah dalam kondisi refund apapun (blokir semua tombol)
  bool get _isRefundState =>
      _paymentStatus == "pending_refund" ||
      _paymentStatus == "refund" ||
      _paymentStatus == "refunded";

  // ─── Theme ───────────────────────────────────────────────────
  static const Color _primary      = Color(0xFF8B2E2E);
  static const Color _primaryLight = Color(0xFFB84545);
  static const Color _bgColor      = Color(0xFFF5F5F5);

  // ─── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final price = getPrice();
    final promoTitle        = data["promo_title"];
    final discountAmountRaw = data["discount_amount"];
    final hasPromo          = promoTitle != null && discountAmountRaw != null;
    final discountAmount    = double.tryParse(discountAmountRaw?.toString() ?? '0')?.toInt() ?? 0;
    final totalNormal       = hasPromo ? price + discountAmount : price;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroStack(),
            const SizedBox(height: 16),
            _buildPaymentSection(price, promoTitle, hasPromo, discountAmount, totalNormal),
            const SizedBox(height: 16),
            buildActionButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar:
    statusFinal == "paid"
        ? _buildBottomDownloadBar(context, price)
        : null,
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
        title: const Text("Detail Pesanan",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      );

  // ─── Hero Stack (gradient bg + card) ────────────────────────
  Widget _buildHeroStack() => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 270,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
            child: _topContent(),
          ),
          Container(margin: const EdgeInsets.only(top: 200), child: _detailCardUI()),
        ],
      );

  // ─── Payment Section ─────────────────────────────────────────
  Widget _buildPaymentSection(
    int price, dynamic promoTitle, bool hasPromo, int discountAmount, int totalNormal,
  ) {
    return _sectionCard(
      icon: Icons.payment_rounded,
      title: "Informasi Pembayaran",
      children: [
        _infoRow(Icons.account_balance_wallet_outlined, "Metode",
            data["payment_method"] ?? "Midtrans"),
        const SizedBox(height: 8),
        if (hasPromo) ...[
          _promoBanner(promoTitle),
          _promoRows(promoTitle, totalNormal, discountAmount),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1)),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _primary.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              Text("Rp ${rupiah(price)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: _primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _promoBanner(String promoTitle) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: Colors.green, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Promo "$promoTitle" diterapkan',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
      );

  Widget _promoRows(String promoTitle, int totalNormal, int discountAmount) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Harga Normal", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text("Rp ${rupiah(totalNormal)}",
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diskon "$promoTitle"',
                  style: const TextStyle(color: Colors.green, fontSize: 13)),
              Text('- Rp ${rupiah(discountAmount)}',
                  style: const TextStyle(color: Colors.green, fontSize: 13)),
            ],
          ),
        ],
      );

  // ─── Bottom Download Bar ─────────────────────────────────────
  Widget _buildBottomDownloadBar(BuildContext context, int price) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await DetailPesananPdf(
                data: data,
                type: type,
                displayName: displayName,
                displayPhone: displayPhone,
                displayEmail: displayEmail,
              ).generate(price);
            },
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text("Download E-Tiket",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ),
      );

  // ─── Header Content (gradient area) ─────────────────────────
  Widget _topContent() {
    if (type == "ticket") return _headerTicket();
    if (type == "bus")    return _headerBus();
    return _headerTour();
  }

  Widget _headerTicket() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _typeBadge("🎫  TIKET BUS"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeCol(data["departure_time"], data["origin"]),
              Column(children: [
                const Icon(Icons.arrow_forward_rounded, color: Colors.white70),
                Text(data["departure_date"] ?? "-",
                    style: const TextStyle(color: Colors.white60, fontSize: 10)),
              ]),
              _timeCol(data["arrival_time"], data["destination"],
                  crossAlign: CrossAxisAlignment.end),
            ],
          ),
        ],
      );

  Widget _headerBus() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _typeBadge("🚌  SEWA BUS"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _locationCol(
                    data["pickup_location"], "Penjemputan", CrossAxisAlignment.start),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white70)),
              Expanded(
                child: _locationCol(
                    data["destination"], "Tujuan", CrossAxisAlignment.end),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, color: Colors.white60, size: 13),
            const SizedBox(width: 5),
            Text("${data["start_date"]} - ${data["end_date"]}",
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ],
      );

  Widget _headerTour() {
    final destinations = parseDestinations(data["destinations"]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _typeBadge("🌴  PAKET WISATA"),
        const SizedBox(height: 10),
        Text(data["package_name"] ?? "-",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.schedule_rounded, color: Colors.white60, size: 13),
          const SizedBox(width: 4),
          Text("${data["duration_days"] ?? 0} hari",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 12),
          const Icon(Icons.people_outline_rounded, color: Colors.white60, size: 13),
          const SizedBox(width: 4),
          Text("${data["passenger_count"] ?? 0} orang",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 5,
          children: destinations
              .map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ─── Card UI ─────────────────────────────────────────────────
  Widget _detailCardUI() => Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.confirmation_number_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(data["booking_code"] ?? data["rental_code"] ?? "-",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5)),
                      ]),
                      _statusBadge(),
                    ],
                  ),
                ),
                _dashedDivider(),
                Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _detailCard()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Divider(color: Colors.grey[200], height: 28)),
                Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: _dataDiri()),
              ],
            ),
          ),
          _punchHole(left: 4),
          _punchHole(right: 4),
        ],
      );

  Widget _punchHole({double? left, double? right}) => Positioned(
        left: left,
        right: right,
        top: 78,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: _bgColor, shape: BoxShape.circle),
        ),
      );

  Widget _dashedDivider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            30,
            (i) => Expanded(
              child: Container(
                  height: 1, color: i.isEven ? Colors.grey[300] : Colors.transparent),
            ),
          ),
        ),
      );

  Widget _detailCard() {
    if (type == "ticket") {
      final passengers = data["passengers"];
      if (passengers is List && passengers.isNotEmpty) {
        return Column(children: [
          _infoRow(Icons.directions_bus_rounded, "Bus", data["bus_name"] ?? "-"),
          const SizedBox(height: 10),
          ...passengers.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text("Kursi ${p['seat'] ?? '-'}",
                          style: const TextStyle(
                              color: _primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    Text(p['passenger_name'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
        ]);
      }
      return _infoRow(Icons.directions_bus_rounded, "Bus", data["bus_name"] ?? "-");
    }

    if (type == "bus") {
      return Column(children: [
        _infoRow(Icons.people_outline_rounded, "Penumpang", "${data["passenger_count"]}"),
        const SizedBox(height: 8),
        _infoRow(Icons.work_outline_rounded, "Keperluan", data["purpose"] ?? "-"),
        const SizedBox(height: 8),
        _infoRow(Icons.schedule_rounded, "Durasi", "${data["duration_days"] ?? 0} hari"),
        const SizedBox(height: 8),
        _infoRow(Icons.place_outlined, "Tujuan", data["destination"] ?? "-"),
      ]);
    }

    return Column(children: [
      _infoRow(Icons.calendar_today_rounded, "Tanggal", data["travel_date"] ?? "-"),
      const SizedBox(height: 8),
      _infoRow(Icons.schedule_rounded, "Durasi", "${data["duration_days"] ?? 0} hari"),
      const SizedBox(height: 8),
      _infoRow(Icons.tour_outlined, "Paket", data["package_name"] ?? "-"),
    ]);
  }

  Widget _dataDiri() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Data Pemesan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 10),
          _infoRow(Icons.person_outline_rounded, "Nama", displayName),
          const SizedBox(height: 8),
          _infoRow(Icons.phone_outlined, "Telepon", displayPhone),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            const Text("Email", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            Flexible(
              child: Text(displayEmail,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            ),
          ]),
        ],
      );

  // ─── Action Buttons ──────────────────────────────────────────
  Widget buildActionButton(BuildContext context) {
    // ── GUARD: semua kondisi refund → blokir tombol, tampilkan info ──
    if (_isRefundState) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _refundInfoBanner(),
      );
    }

if (statusFinal == "completed") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _primaryButton(
          text: "Beri Ulasan",
          icon: Icons.star_rounded,
          color: Colors.orange,
          onTap: () {
            final userId = data["user_id"] is int
                ? data["user_id"] as int
                : int.tryParse(data["user_id"].toString()) ?? 0;
                
                  final reviewableId = type == "tour"
                      ? (data["tour_package_id"] is int
                          ? data["tour_package_id"] as int
                          : int.tryParse(data["tour_package_id"].toString()) ?? 0)
                      : (data["id"] is int
                          ? data["id"] as int
                          : int.tryParse(data["id"].toString()) ?? 0);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewPage(
                  userId: userId,
                  reviewableId: reviewableId,
                  type: _reviewType,
                ),
              ),
            );
          },
        ),
      );
    }

    // ── pending_payment: tombol bayar, cek status, batalkan ──
    if (statusFinal == "pending_payment") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _primaryButton(
              text: "Lanjut Pembayaran",
              icon: Icons.payment_rounded,
              onTap: () => _navigateToPayment(context),
            ),
            const SizedBox(height: 10),
            _outlinedButton(
              text: "Cek Status Pembayaran",
              icon: Icons.refresh_rounded,
              onTap: () => DetailPesananService.checkPaymentStatus(context, data),
            ),
            const SizedBox(height: 10),
            _cancelButton(context),
          ],
        ),
      );
    }

    // ── paid + bukan sewa bus: tombol ajukan refund ──
    if (statusFinal == "paid" && type != "bus") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _outlinedButton(
          text: "Ajukan Refund",
          icon: Icons.assignment_return_outlined,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RefundPage(booking: data),
              ),
            );
            if (result == true && context.mounted) {
              Navigator.pop(context, true);
            }
          },
        ),
      );
    }

    return const SizedBox();
  }

  // ─── Refund Info Banner ──────────────────────────────────────
  // Tampilan berbeda sesuai tahap:
  //   pending_refund / refund → menunggu admin proses (ungu)
  //   refunded                → admin sudah complete, uang kembali (cyan)
  Widget _refundInfoBanner() {
    final isRefunded = _paymentStatus == "refunded";
    final color      = isRefunded ? const Color(0xFF00BCD4) : const Color(0xFF9C27B0);
    final icon       = isRefunded
        ? Icons.check_circle_outline_rounded
        : Icons.hourglass_top_rounded;
    final message    = isRefunded
        ? "Refund telah selesai diproses oleh admin. Dana akan masuk ke rekening kamu dalam 1–3 hari kerja."
        : "Pengajuan refund sedang menunggu diproses oleh admin. Mohon tunggu konfirmasi dari kami.";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(BuildContext context) {
    if (type == "ticket") {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => PaymentPage(bookingData: data)));
    } else if (type == "tour") {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => other.PaymentPage(data: data, type: "tour")));
    } else {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => other.PaymentPage(data: data, type: "rental")));
    }
  }

  Widget _cancelButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () => _showCancelDialog(context),
          icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.redAccent),
          label: const Text("Batalkan Pesanan",
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 15)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
            ),
            backgroundColor: Colors.redAccent.withOpacity(0.05),
          ),
        ),
      );

  // ─── Cancel Dialog ───────────────────────────────────────────
  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.redAccent, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text("Batalkan Pesanan?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Masukkan alasan pembatalan",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Contoh: Ada keperluan mendadak...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primary)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text("Tidak",
                              style: TextStyle(color: Colors.black54)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (reasonController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Masukkan alasan pembatalan"),
                                          backgroundColor: Colors.orange),
                                    );
                                    return;
                                  }
                                  setState(() => isLoading = true);
                                  Navigator.pop(context);
                                  await DetailPesananService.cancelOrder(
                                    context,
                                    data: data,
                                    type: type,
                                    reason: reasonController.text.trim(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("Ya, Batalkan",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Small Reusable Widgets ──────────────────────────────────
  Widget _typeBadge(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Widget _timeCol(dynamic time, dynamic place,
      {CrossAxisAlignment crossAlign = CrossAxisAlignment.start}) =>
      Column(
        crossAxisAlignment: crossAlign,
        children: [
          Text(time?.toString() ?? "-",
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(place?.toString() ?? "-",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );

  Widget _locationCol(dynamic val, String label, CrossAxisAlignment align) =>
      Column(
        crossAxisAlignment: align,
        children: [
          Text(val?.toString() ?? "-",
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: align == CrossAxisAlignment.end ? TextAlign.right : TextAlign.left),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      );

  Widget _statusBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: statusColor().withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor().withOpacity(0.3)),
        ),
        child: Text(statusText(),
            style: TextStyle(
                color: statusColor(), fontWeight: FontWeight.bold, fontSize: 12)),
      );

  Widget _infoRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      );

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: _primary),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87)),
            ]),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _primaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
    Color color = _primary,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: onTap == null ? Colors.grey[400] : color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: onTap == null ? 0 : 2,
          ),
        ),
      );

  Widget _outlinedButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}