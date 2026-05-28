import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';

import 'base_pesanan_pdf.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// RENTAL PDF — Sewa Bus
// ═══════════════════════════════════════════════════════════════════════════════

class RentalPesananPdf extends BasePesananPdf {
  const RentalPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });

  Future<void> generate(int price) async {
    final pdf = pw.Document();
    final bookingCode = data["rental_code"] ?? "UNKNOWN";
    final time = printTime;

    final qrData = jsonEncode({
      "code": bookingCode,
      "type": "rental",
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
    final pickup = data["pickup_location"] ?? "-";
    final destination = data["destination"] ?? "-";
    final startDate = data["start_date"] ?? "-";
    final endDate = data["end_date"] ?? "-";

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(pickup,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text("Mulai: $startDate",
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
                pw.Text("Selesai: $endDate",
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
            "Rincian Sewa Bus",
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 10),
          dotRow(PdfColors.blue700, "Lokasi Penjemputan", data["pickup_location"] ?? "-"),
          pw.SizedBox(height: 8),
          dotRow(PdfColors.red700, "Tujuan", data["destination"] ?? "-"),
          pw.SizedBox(height: 8),
          labelValue("Periode", "${data["start_date"]} - ${data["end_date"]}"),
          labelValue("Durasi", "${data["duration_days"]} hari"),
          labelValue("Jumlah Penumpang", "${data["passenger_count"]} orang"),
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
                  "Rincian Penyewa",
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 10),
                passengerField("Nama Penyewa", displayName),
                pw.SizedBox(height: 6),
                passengerField("No. Telepon", displayPhone),
                pw.SizedBox(height: 6),
                passengerField("Kode Rental", bookingCode),
                pw.SizedBox(height: 6),
                passengerField("Jumlah Penumpang", "${data["passenger_count"]} orang"),
                pw.SizedBox(height: 6),
                passengerField(
                  "Periode Sewa",
                  "${data["start_date"] ?? "-"} s/d\n${data["end_date"] ?? "-"}",
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