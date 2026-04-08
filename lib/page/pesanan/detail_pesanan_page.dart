import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../services/booking_paket_service.dart';
import '../../services/rental_service.dart';
import '../../services/payment_service.dart'; // 🔥 TAMBAHAN
import '../booking/payment_page.dart'; // 🔥 tiket
import '../payment/payment_page.dart' as other; // 🔥 paket & rental
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

  /// ================= STATUS =================
  Color statusColor() {
    switch (statusFinal) {
      case "pending_payment": return Colors.orange;
      case "waiting_confirmation":
      case "waiting_approval": return Colors.blue;
      case "paid": return Colors.green;
      case "completed": return Colors.grey;
      case "cancelled":
      case "rejected": return Colors.red;
      default: return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    final price = getPrice();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ================= HEADER + CARD =================
            Stack(
              children: [

                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF8B2E2E),
                        Color(0xFFB84545),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: _topContent(),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 190),
                  child: _detailCardUI(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// PEMBAYARAN
            _card([
              _row("Metode", data["payment_method"] ?? "Transfer"),
              _row("Total", "Rp ${rupiah(price)}", bold: true),
            ]),

            const SizedBox(height: 20),

            buildActionButton(context),

            const SizedBox(height: 30),
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

          const Text("Bus 88 - TICKET",
              style: TextStyle(color: Colors.white70)),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _routeText(data["departure_time"]),
              const Icon(Icons.arrow_forward, color: Colors.white),
              _routeText(data["arrival_time"]),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data["origin"] ?? "-",
                  style: const TextStyle(color: Colors.white70)),
              Text(data["destination"] ?? "-",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              data["departure_date"] ?? "-",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      );
    }

    if (type == "bus") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("Bus 88 - SEWA BUS",
              style: TextStyle(color: Colors.white70)),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _routeText(data["pickup_location"]),
              const Icon(Icons.arrow_forward, color: Colors.white),
              _routeText(data["destination"]),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data["pickup_location"] ?? "-",
                  style: const TextStyle(color: Colors.white70)),
              Text(data["destination"] ?? "-",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "${data["start_date"]} - ${data["end_date"]}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      );
    }

    final destinations = parseDestinations(data["destinations"]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Bus 88 - PAKET WISATA",
            style: TextStyle(color: Colors.white70)),

        const SizedBox(height: 10),

        Text(data["package_name"] ?? "-",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),

        const SizedBox(height: 6),

        Text(
          "${data["duration_days"] ?? 0} hari • ${data["passenger_count"] ?? 0} orang",
          style: const TextStyle(color: Colors.white70),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: destinations.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(e,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
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
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data["booking_code"] ??
                        data["rental_code"] ??
                        "-",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _statusBadge(),
                ],
              ),

              const Divider(height: 30),

              _detailCard(),

              const Divider(),

              _dataDiriBetter(),
            ],
          ),
        ),

        Positioned(
          left: 10,
          top: 90,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          right: 10,
          top: 90,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailCard() {

    if (type == "ticket") {
      return _row("Bus", data["bus_name"]);
    }

    if (type == "bus") {
      return Column(
        children: [
          _row("Penumpang", "${data["passenger_count"]}"),
          _row("Keperluan", data["purpose"]),
          _row("Durasi", "${data["duration_days"] ?? 0} hari"),
          _row("Tujuan", data["destination"]),
        ],
      );
    }

    return Column(
      children: [
        _row("Tanggal", data["travel_date"]),
        _row("Durasi", "${data["duration_days"] ?? 0} hari"),
        _row("Tujuan", data["package_name"]),
      ],
    );
  }

  /// ================= DATA DIRI =================
  Widget _dataDiriBetter() {
    return Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Nama", style: TextStyle(color: Colors.grey)),
            Text(data["name"] ?? "-",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Telp", style: TextStyle(color: Colors.grey)),
            Text(data["phone"] ?? "-"),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Email", style: TextStyle(color: Colors.grey)),
            Flexible(
              child: Text(
                data["email"] ?? "-",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ================= BUTTON =================
  Widget buildActionButton(BuildContext context) {

    /// 🟡 BELUM BAYAR
    if (statusFinal == "pending_payment") {
      return Column(
        children: [
          _mainButton(
            text: "Lanjut Pembayaran",
            color: const Color(0xFF8B2E2E),
            onTap: () {
              if (type == "ticket") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(bookingData: data),
                  ),
                );
              } else if (type == "tour") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => other.PaymentPage(data: data, type: "tour"),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => other.PaymentPage(data: data, type: "rental"),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 10),

          // 🔥 TAMBAHAN: Tombol Cek Status Pembayaran
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                final bookingId = int.tryParse(data["id"]?.toString() ?? "0") ?? 0;
                final status = await PaymentService.checkStatus(bookingId);

                Navigator.pop(context); // tutup loading

                if (status == 'settlement' || status == 'capture') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Pembayaran berhasil dikonfirmasi!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true); // refresh halaman pesanan
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
                    const SnackBar(
                      content: Text("Belum ada pembayaran via Midtrans"),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8B2E2E)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Cek Status Pembayaran",
                style: TextStyle(
                  color: Color(0xFF8B2E2E),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          _mainButton(
            text: "Batalkan",
            color: Colors.grey,
            onTap: () => _showCancelDialog(context),
          ),
        ],
      );
    }

    /// 🔵 SUDAH BAYAR
    if (statusFinal == "paid") {
      final dateStr = data["departure_date"]
          ?? data["travel_date"]
          ?? data["end_date"];

      final tripDate = DateTime.tryParse(dateStr ?? "");
      final isDone = tripDate != null && DateTime.now().isAfter(tripDate);

      return _mainButton(
        text: "Pesanan Selesai",
        color: const Color(0xFF8B2E2E),
        onTap: isDone ? () async => await finishOrder(context) : null,
      );
    }

    /// ⚫ SELESAI
    if (statusFinal == "completed") {
      return _mainButton(
        text: "Download",
        color: const Color(0xFF1976D2),
        onTap: () async => await generateTicketPdf(),
      );
    }

    return const SizedBox();
  }

  /// ================= COMPONENT =================
  Widget _mainButton({
    required String text,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey[400] : color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(isDisabled ? 0.7 : 1),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(String text, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText(),
        style: TextStyle(
          color: statusColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row(String title, String? value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value ?? "-",
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
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
          fontWeight: FontWeight.bold),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
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

                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Batalkan Pesanan?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Anda yakin ingin membatalkan pesanan ini?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Tidak"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await cancelOrder(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B2E2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Ya"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
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
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    pw.Text(
                      "Kode: ${data["booking_code"] ?? data["rental_code"] ?? "-"}",
                    ),

                    pw.Divider(),

                    pw.Text(
                      "Detail Perjalanan",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),

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

                    pw.Text(
                      "Data Diri",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),

                    pw.SizedBox(height: 10),

                    pw.Text("Nama: ${data["name"]}"),
                    pw.Text("Telp: ${data["phone"]}"),
                    pw.Text("Email: ${data["email"]}"),

                    pw.SizedBox(height: 20),

                    pw.Text(
                      "Pembayaran",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),

                    pw.SizedBox(height: 10),

                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(children: [
                          _cell("Metode"),
                          _cell(data["payment_method"] ?? "Transfer"),
                        ]),
                        pw.TableRow(children: [
                          _cell("Harga"),
                          _cell("Rp ${rupiah(price)}"),
                        ]),
                        pw.TableRow(children: [
                          _cell("Total"),
                          _cell("Rp ${rupiah(price)}"),
                        ]),
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
                        border: pw.Border.all(
                          color: PdfColors.green,
                          width: 3,
                        ),
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

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text),
    );
  }

  /// ================= API =================
  Future<void> cancelOrder(BuildContext context) async {
    if (type == "ticket") {
      await BookingService.cancelBooking(data["id"]);
    } else if (type == "tour") {
      await BookingPaketService.cancelTour(data["id"]);
    } else {
      await RentalService.cancelRental(data["id"]);
    }

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pop(context, true);
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