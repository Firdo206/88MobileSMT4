import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';

import 'base_pesanan_pdf.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// TICKET PDF — Pemesanan Tiket Bus
// ═══════════════════════════════════════════════════════════════════════════════

class TicketPesananPdf extends BasePesananPdf {
  const TicketPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });

  Future<void> generate(int price) async {
    final pdf = pw.Document();
    final bookingCode = data["booking_code"] ?? "UNKNOWN";
    final time = printTime;

    final qrData = jsonEncode({
      "code": bookingCode,
      "type": "ticket",
      "name": displayName,
      "phone": displayPhone,
      "price": price,
      "status": data["status_final"] ?? "-",
    });

    final qrImage = pw.MemoryImage(await generateQrBytes(qrData));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            buildTopHeader(),
            buildInfoBar(),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildPentingBanner(),
                  pw.SizedBox(height: 12),
                  _buildRouteRow(bookingCode),
                  pw.SizedBox(height: 12),
                  buildTotalBar(price, time),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _buildTripCard()),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _buildPassengerCard(price, bookingCode, time, qrImage),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  buildContactCard(),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(time),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildRouteRow(String bookingCode) {
    final origin = data["origin"] ?? "-";
    final destination = data["destination"] ?? "-";
    final depDate = data["departure_date"] ?? "-";
    final depTime = "${data["departure_time"] ?? "-"} WIB";
    final arrTime = "${data["arrival_time"] ?? "-"} WIB";

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(origin,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(depDate,
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.Text(depTime,
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            "->",
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey500),
          ),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(destination,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(depDate,
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                pw.Text(arrTime,
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
          ),
        ),
        bookingCodeBadge(bookingCode),
      ],
    );
  }

  pw.Widget _buildTripCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Rincian Perjalanan",
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 10),
          dotRow(PdfColors.blue700, "Berangkat Dari", data["origin"] ?? "-"),
          pw.SizedBox(height: 8),
          dotRow(PdfColors.red700, "Menuju ke", data["destination"] ?? "-"),
        ],
      ),
    );
  }

  pw.Widget _buildPassengerCard(
    int price,
    String bookingCode,
    String time,
    pw.ImageProvider qrImage,
  ) {
    final passengers = data["passengers"];
    final firstPassenger =
        (passengers is List && passengers.isNotEmpty) ? passengers[0] as Map : null;
    final seatNo = firstPassenger?["seat"]?.toString() ??
        data["seat_number"]?.toString() ??
        data["seat"]?.toString() ??
        "-";

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Rincian Penumpang",
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 10),
                passengerField("Nama Penumpang", displayName),
                pw.SizedBox(height: 6),
                passengerField("Nomor Kursi", seatNo),
                pw.SizedBox(height: 6),
                passengerField("No. Telepon", displayPhone),
                pw.SizedBox(height: 6),
                passengerField("Kode Tiket", bookingCode),
                pw.SizedBox(height: 6),
                passengerField("Bus", data["bus_name"] ?? "-"),
                pw.SizedBox(height: 6),
                passengerField(
                  "Waktu Keberangkatan",
                  "${data["departure_date"] ?? "-"}\nPukul ${data["departure_time"] ?? "-"} WIB",
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          qrBlock(qrImage, price, time),
        ],
      ),
    );
  }
}