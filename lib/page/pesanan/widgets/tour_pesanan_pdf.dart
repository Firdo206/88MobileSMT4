import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';

import 'base_pesanan_pdf.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// TOUR PDF — Paket Wisata
// ═══════════════════════════════════════════════════════════════════════════════

class TourPesananPdf extends BasePesananPdf {
  const TourPesananPdf({
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
      "type": "tour",
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
                  _buildPackageRow(bookingCode),
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

  pw.Widget _buildPackageRow(String bookingCode) {
    final packageName = data["package_name"] ?? "-";
    final travelDate = data["travel_date"] ?? "-";
    final durationDays = data["duration_days"]?.toString() ?? "-";

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                packageName,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Tanggal Keberangkatan: $travelDate",
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                "Durasi: $durationDays hari",
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
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
            "Rincian Paket Wisata",
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 10),
          dotRow(PdfColors.blue700, "Nama Paket", data["package_name"] ?? "-"),
          pw.SizedBox(height: 8),
          labelValue("Tanggal", data["travel_date"] ?? "-"),
          labelValue("Durasi", "${data["duration_days"]} hari"),
          labelValue("Jumlah Peserta", "${data["passenger_count"]} orang"),
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
                  "Rincian Pemesan",
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 10),
                passengerField("Nama Pemesan", displayName),
                pw.SizedBox(height: 6),
                passengerField("No. Telepon", displayPhone),
                pw.SizedBox(height: 6),
                passengerField("Kode Booking", bookingCode),
                pw.SizedBox(height: 6),
                passengerField("Jumlah Peserta", "${data["passenger_count"]} orang"),
                pw.SizedBox(height: 6),
                passengerField("Tanggal Keberangkatan", data["travel_date"] ?? "-"),
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