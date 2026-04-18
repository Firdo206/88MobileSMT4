import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../services/booking_paket_service.dart';
import '../../services/rental_service.dart';
import '../../services/payment_service.dart';
import '../booking/payment_page.dart';
import '../payment/payment_page.dart' as other;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class DetailPesananPage extends StatelessWidget {
  final Map data;
  final String type;

  const DetailPesananPage({
    super.key,
    required this.data,
    required this.type,
  });

  String get statusFinal => data["status_final"] ?? "-";

  /// ================= FORMAT =================
  String rupiah(dynamic value) {
    int v = int.tryParse(value.toString()) ?? 0;
    return v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => "${m[1]}.",
    );
  }

  int getPrice() {
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

  List<String> parseDestinations(dynamic value) {
    if (value == null) return [];
    return value
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',')
        .map((e) => e.trim())
        .toList();
  }

  Map? get firstPassenger {
    final passengers = data["passengers"];
    if (passengers is List && passengers.isNotEmpty) {
      return passengers[0] as Map?;
    }
    return null;
  }

  String get displayName {
    final direct = data["name"] ?? data["passenger_name"] ?? data["contact_name"];
    if (direct != null && direct.toString().isNotEmpty) return direct.toString();
    return firstPassenger?["passenger_name"]?.toString() ?? "-";
  }

  String get displayPhone {
    final direct = data["phone"] ?? data["contact_phone"];
    if (direct != null && direct.toString().isNotEmpty) return direct.toString();
    return firstPassenger?["phone"]?.toString() ?? "-";
  }

  String get displayEmail {
    return data["email"]?.toString() ?? "-";
  }

  /// ================= STATUS =================
  Color statusColor() {
    switch (statusFinal) {
      case "pending_payment": return const Color(0xFFFF9800);
      case "waiting_confirmation":
      case "waiting_approval": return const Color(0xFF2196F3);
      case "paid": return const Color(0xFF4CAF50);
      case "completed": return const Color(0xFF9E9E9E);
      case "cancelled":
      case "rejected": return const Color(0xFFF44336);
      default: return const Color(0xFF9E9E9E);
    }
  }

  String statusText() {
    switch (statusFinal) {
      case "pending_payment": return "Belum Bayar";
      case "waiting_confirmation": return "Wait Confirm";
      case "waiting_approval": return "Wait Approval";
      case "paid": return "Lunas";
      case "completed": return "Selesai";
      case "cancelled": return "Dibatalkan";
      case "rejected": return "Ditolak";
      default: return "-";
    }
  }

  /// ================= THEME =================
  static const Color _primary = Color(0xFF8B2E2E);
  static const Color _primaryLight = Color(0xFFB84545);
  static const Color _bgColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final price = getPrice();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ================= HEADER + CARD =================
            Stack(
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

                Container(
                  margin: const EdgeInsets.only(top: 200),
                  child: _detailCardUI(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// PEMBAYARAN
            _sectionCard(
              icon: Icons.payment_rounded,
              title: "Informasi Pembayaran",
              children: [
                _infoRow(
                  Icons.account_balance_wallet_outlined,
                  "Metode",
                  data["payment_method"] ?? "Transfer",
                ),
                const SizedBox(height: 8),
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
                      const Text(
                        "Total Pembayaran",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Rp ${rupiah(price)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            buildActionButton(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _topContent() {

    if (type == "ticket") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "🎫  TIKET BUS",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["departure_time"] ?? "-",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data["origin"] ?? "-",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white70),
                  Text(
                    data["departure_date"] ?? "-",
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data["arrival_time"] ?? "-",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data["destination"] ?? "-",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    if (type == "bus") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "🚌  SEWA BUS",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["pickup_location"] ?? "-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text("Penjemputan", style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, color: Colors.white70),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data["destination"] ?? "-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                    const Text("Tujuan", style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: Colors.white60, size: 13),
              const SizedBox(width: 5),
              Text(
                "${data["start_date"]} - ${data["end_date"]}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      );
    }

    final destinations = parseDestinations(data["destinations"]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "🌴  PAKET WISATA",
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          data["package_name"] ?? "-",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            const Icon(Icons.schedule_rounded, color: Colors.white60, size: 13),
            const SizedBox(width: 4),
            Text(
              "${data["duration_days"] ?? 0} hari",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.people_outline_rounded, color: Colors.white60, size: 13),
            const SizedBox(width: 4),
            Text(
              "${data["passenger_count"] ?? 0} orang",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 6,
          runSpacing: 5,
          children: destinations.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 11)),
            );
          }).toList(),
        )
      ],
    );
  }

  /// ================= CARD =================
  Widget _detailCardUI() {
    return Stack(
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
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [

              /// Header kode + status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          data["booking_code"] ?? data["rental_code"] ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    _statusBadge(),
                  ],
                ),
              ),

              /// Dashed divider
              _dashedDivider(),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: _detailCard(),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Divider(color: Colors.grey[200], height: 28),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: _dataDiriBetter(),
              ),
            ],
          ),
        ),

        // Notch kiri
        Positioned(
          left: 4,
          top: 78,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _bgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Notch kanan
        Positioned(
          right: 4,
          top: 78,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _bgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          30,
          (i) => Expanded(
            child: Container(
              height: 1,
              color: i.isEven ? Colors.grey[300] : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailCard() {

    if (type == "ticket") {
      final passengers = data["passengers"];
      if (passengers is List && passengers.isNotEmpty) {
        return Column(
          children: [
            _infoRow(Icons.directions_bus_rounded, "Bus", data["bus_name"] ?? "-"),
            const SizedBox(height: 10),
            ...passengers.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Kursi ${p['seat'] ?? '-'}",
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    p['passenger_name'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
          ],
        );
      }
      return _infoRow(Icons.directions_bus_rounded, "Bus", data["bus_name"] ?? "-");
    }

    if (type == "bus") {
      return Column(
        children: [
          _infoRow(Icons.people_outline_rounded, "Penumpang", "${data["passenger_count"]}"),
          const SizedBox(height: 8),
          _infoRow(Icons.work_outline_rounded, "Keperluan", data["purpose"] ?? "-"),
          const SizedBox(height: 8),
          _infoRow(Icons.schedule_rounded, "Durasi", "${data["duration_days"] ?? 0} hari"),
          const SizedBox(height: 8),
          _infoRow(Icons.place_outlined, "Tujuan", data["destination"] ?? "-"),
        ],
      );
    }

    return Column(
      children: [
        _infoRow(Icons.calendar_today_rounded, "Tanggal", data["travel_date"] ?? "-"),
        const SizedBox(height: 8),
        _infoRow(Icons.schedule_rounded, "Durasi", "${data["duration_days"] ?? 0} hari"),
        const SizedBox(height: 8),
        _infoRow(Icons.tour_outlined, "Paket", data["package_name"] ?? "-"),
      ],
    );
  }

  /// ================= DATA DIRI =================
  Widget _dataDiriBetter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Data Pemesan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 10),

        _infoRow(Icons.person_outline_rounded, "Nama", displayName),
        const SizedBox(height: 8),
        _infoRow(Icons.phone_outlined, "Telepon", displayPhone),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            const Text("Email", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            Flexible(
              child: Text(
                displayEmail,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ================= BUTTON =================
  Widget buildActionButton(BuildContext context) {

    if (statusFinal == "pending_payment") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

            _primaryButton(
              text: "Lanjut Pembayaran",
              icon: Icons.payment_rounded,
              onTap: () {
                if (type == "ticket") {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PaymentPage(bookingData: data),
                  ));
                } else if (type == "tour") {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => other.PaymentPage(data: data, type: "tour"),
                  ));
                } else {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => other.PaymentPage(data: data, type: "rental"),
                  ));
                }
              },
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  final bookingId = int.tryParse(data["id"]?.toString() ?? "0") ?? 0;
                  final status = await PaymentService.checkStatus(bookingId);

                  Navigator.pop(context);

                  if (status == 'settlement' || status == 'capture') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("✅ Pembayaran berhasil dikonfirmasi!"),
                      backgroundColor: Colors.green,
                    ));
                    Navigator.pop(context, true);
                  } else if (status == 'pending') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("⏳ Pembayaran masih pending, harap tunggu..."),
                      backgroundColor: Colors.orange,
                    ));
                  } else if (status != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Status: $status")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Belum ada pembayaran via Midtrans"),
                    ));
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  "Cek Status Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.redAccent),
                label: const Text(
                  "Batalkan Pesanan",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  backgroundColor: Colors.redAccent.withOpacity(0.05),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (statusFinal == "paid") {
      final dateStr = data["departure_date"] ?? data["travel_date"] ?? data["end_date"];
      final tripDate = DateTime.tryParse(dateStr ?? "");
      final isDone = tripDate != null && DateTime.now().isAfter(tripDate);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _primaryButton(
          text: "Pesanan Selesai",
          icon: Icons.check_circle_outline_rounded,
          onTap: isDone ? () async => await finishOrder(context) : null,
        ),
      );
    }

    if (statusFinal == "completed") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _primaryButton(
          text: "Download E-Tiket",
          icon: Icons.download_rounded,
          color: const Color(0xFF1976D2),
          onTap: () async => await generateTicketPdf(),
        ),
      );
    }

    return const SizedBox();
  }

  /// ================= COMPONENT =================
  Widget _primaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
    Color color = _primary,
  }) {
    final isDisabled = onTap == null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey[400] : color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isDisabled ? 0 : 2,
        ),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor().withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor().withOpacity(0.3)),
      ),
      child: Text(
        statusText(),
        style: TextStyle(
          color: statusColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String title, String? value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value ?? "-",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeText(String? text) {
    return Text(
      text ?? "-",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Batalkan Pesanan?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Masukkan alasan pembatalan",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),

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
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primary),
                        ),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Text("Tidak", style: TextStyle(color: Colors.black54)),
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
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => isLoading = true);
                                    Navigator.pop(context);
                                    await cancelOrder(context, reason: reasonController.text.trim());
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "Ya, Batalkan",
                                    style: TextStyle(fontWeight: FontWeight.bold),
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
        );
      },
    );
  }

  /// ================= Download PDF =================
  Future<void> generateTicketPdf() async {
    final pdf = pw.Document();
    final price = getPrice();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Stack(
              children: [

                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    pw.Text(
                      "E-TIKET BUS 88",
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),

                    pw.SizedBox(height: 10),

                    pw.Text("Kode: ${data["booking_code"] ?? data["rental_code"] ?? "-"}"),

                    pw.Divider(),

                    pw.Text("Detail Perjalanan", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

                    pw.SizedBox(height: 10),

                    if (type == "ticket") ...[
                      pw.Text("${data["origin"]} → ${data["destination"]}"),
                      pw.Text("Tanggal: ${data["departure_date"]}"),
                      pw.Text("Jam: ${data["departure_time"]} - ${data["arrival_time"]}"),
                    ],

                    if (type == "bus") ...[
                      pw.Text("${data["pickup_location"]} → ${data["destination"]}"),
                      pw.Text("Tanggal: ${data["start_date"]} - ${data["end_date"]}"),
                      pw.Text("Durasi: ${data["duration_days"]} hari"),
                    ],

                    if (type == "tour") ...[
                      pw.Text("${data["package_name"]}"),
                      pw.Text("Tanggal: ${data["travel_date"]}"),
                      pw.Text("Durasi: ${data["duration_days"]} hari"),
                    ],

                    pw.SizedBox(height: 20),

                    pw.Text("Data Diri", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

                    pw.SizedBox(height: 10),

                    pw.Text("Nama: $displayName"),
                    pw.Text("Telp: $displayPhone"),
                    pw.Text("Email: $displayEmail"),

                    pw.SizedBox(height: 20),

                    pw.Text("Pembayaran", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

                    pw.SizedBox(height: 10),

                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(children: [_cell("Metode"), _cell(data["payment_method"] ?? "Transfer")]),
                        pw.TableRow(children: [_cell("Harga"), _cell("Rp ${rupiah(price)}")]),
                        pw.TableRow(children: [_cell("Total"), _cell("Rp ${rupiah(price)}")]),
                      ],
                    ),
                  ],
                ),

                pw.Positioned(
                  bottom: 40,
                  right: 20,
                  child: pw.Transform.rotate(
                    angle: -0.3,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.green, width: 3),
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Text(
                        "LUNAS",
                        style: pw.TextStyle(
                          color: PdfColors.green,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text),
    );
  }

  /// ================= API =================
  Future<void> cancelOrder(BuildContext context, {String reason = ""}) async {
    try {
      if (type == "ticket") {
        await BookingService.cancelBooking(data["id"], reason: reason);
      } else if (type == "tour") {
        await BookingPaketService.cancelTour(data["id"], reason: reason);
      } else {
        await RentalService.cancelRental(data["id"], reason: reason);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Pesanan berhasil dibatalkan"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Gagal membatalkan: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> finishOrder(BuildContext context) async {
    if (type == "ticket") {
      await BookingService.finish(data["id"]);
    } else if (type == "tour") {
      await BookingPaketService.finish(data["id"]);
    } else {
      await RentalService.finish(data["id"]);
    }
    Navigator.pop(context, true);
  }
}