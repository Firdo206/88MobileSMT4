import 'package:flutter/material.dart' show Color;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';

// ═══════════════════════════════════════════════════════════════════════════════
// BASE CLASS — shared helpers & common layout widgets
// ═══════════════════════════════════════════════════════════════════════════════

abstract class _BasePesananPdf {
  final Map data;
  final String displayName;
  final String displayPhone;
  final String displayEmail;

  const _BasePesananPdf({
    required this.data,
    required this.displayName,
    required this.displayPhone,
    required this.displayEmail,
  });

  // ─── helpers ────────────────────────────────────────────────────────────────

  String rupiah(dynamic value) {
    int v = int.tryParse(value.toString()) ?? 0;
    return v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => "${m[1]}.",
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _printTime {
    final now = DateTime.now();
    return "${now.year}-${_pad(now.month)}-${_pad(now.day)} "
        "${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}";
  }

  Future<Uint8List> _generateQrBytes(String qrData) async {
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
      color: Color(0xFF000000),
      emptyColor: Color(0xFFFFFFFF),
    );
    final imageData = await qrPainter.toImageData(200);
    return imageData!.buffer.asUint8List();
  }

  // ─── shared layout widgets ──────────────────────────────────────────────────

  pw.Widget buildTopHeader() {
    return pw.Container(
      color: PdfColors.red800,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 36,
                height: 36,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "88",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "BUS 88",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    "PERUSAHAAN OTOBUS &\nTRAVEL",
                    style: pw.TextStyle(fontSize: 7, color: PdfColors.red100),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "Kantor Pusat Bus 88",
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                "Jl. Brawijaya, Darungan, Jubung, Kec. Sukorambi,",
                style: pw.TextStyle(fontSize: 8, color: PdfColors.red100),
              ),
              pw.Text(
                "Kab. Jember, Jawa Timur 68151",
                style: pw.TextStyle(fontSize: 8, color: PdfColors.red100),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget buildInfoBar() {
    return pw.Container(
      color: PdfColors.grey100,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: pw.Row(
        children: [
          _infoBarItem("Contact Center", "(0331) 3068888"),
          pw.SizedBox(width: 32),
          _infoBarItem("Email Customer Service", "cs@bus88.co.id"),
          pw.SizedBox(width: 32),
          _infoBarItem("Website", "www.bus88.co.id"),
        ],
      ),
    );
  }

  pw.Widget _infoBarItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget buildPentingBanner() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex("#FFF9C4"),
        border: pw.Border.all(color: PdfColor.fromHex("#F9A825"), width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            "PENTING  ",
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex("#E65100"),
            ),
          ),
          pw.Text(
            "Kode QR anda harus dipindai saat naik.",
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
          ),
        ],
      ),
    );
  }

  pw.Widget buildTotalBar(int price, String printTime) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Total Harga : Rp ${rupiah(price)}",
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            "Pembayaran diterima pada $printTime",
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget buildContactCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            "Kontak",
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(width: 30),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("No. Telepon", style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
              pw.Text(displayPhone, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(width: 30),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Email", style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
              pw.Text(displayEmail, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget buildFooter(String printTime) {
    return pw.Container(
      color: PdfColors.grey100,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: pw.Text(
        "Dicetak: $printTime WIB  |  Bus 88 — Perusahaan Otobus & Tour & Travel  |  "
        "Tiket ini sah tanpa tanda tangan basah. Berlaku untuk satu kali perjalanan.",
        style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // ─── reusable micro-widgets ─────────────────────────────────────────────────

  pw.Widget dotRow(PdfColor color, String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 8,
          height: 8,
          margin: const pw.EdgeInsets.only(top: 2, right: 6),
          decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  pw.Widget labelValue(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 14),
          pw.Text("$label: ", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget passengerField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
        pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget bookingCodeBadge(String bookingCode) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text("Kode Booking", style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          pw.SizedBox(height: 2),
          pw.Text(
            bookingCode,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget qrBlock(pw.ImageProvider qrImage, int price, String printTime) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(qrImage, width: 90, height: 90),
        pw.SizedBox(height: 4),
        pw.Text(
          "Rp ${rupiah(price)}",
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red800,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          "Dicetak: $printTime",
          style: pw.TextStyle(fontSize: 6, color: PdfColors.grey500),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 1. TICKET PDF — Pemesanan Tiket Bus
// ═══════════════════════════════════════════════════════════════════════════════

class TicketPesananPdf extends _BasePesananPdf {
  const TicketPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });

  Future<void> generate(int price) async {
    final pdf = pw.Document();
    final bookingCode = data["booking_code"] ?? "UNKNOWN";
    final printTime = _printTime;

    final qrData = jsonEncode({
      "code": bookingCode,
      "type": "ticket",
      "name": displayName,
      "phone": displayPhone,
      "price": price,
      "status": data["status_final"] ?? "-",
    });

    final qrImage = pw.MemoryImage(await _generateQrBytes(qrData));

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
                  buildTotalBar(price, printTime),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _buildTripCard()),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _buildPassengerCard(price, bookingCode, printTime, qrImage),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  buildContactCard(),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(printTime),
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
              pw.Text(origin, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(depDate, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.Text(depTime, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            "->",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey500),
          ),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(destination, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(depDate, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                pw.Text(arrTime, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
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
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
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
    String printTime,
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
                      fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
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
          qrBlock(qrImage, price, printTime),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. TOUR PDF — Paket Wisata
// ═══════════════════════════════════════════════════════════════════════════════

class TourPesananPdf extends _BasePesananPdf {
  const TourPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });

  Future<void> generate(int price) async {
    final pdf = pw.Document();
    final bookingCode = data["booking_code"] ?? "UNKNOWN";
    final printTime = _printTime;

    final qrData = jsonEncode({
      "code": bookingCode,
      "type": "tour",
      "name": displayName,
      "phone": displayPhone,
      "price": price,
      "status": data["status_final"] ?? "-",
    });

    final qrImage = pw.MemoryImage(await _generateQrBytes(qrData));

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
                  buildTotalBar(price, printTime),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _buildTripCard()),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _buildPassengerCard(price, bookingCode, printTime, qrImage),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  buildContactCard(),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(printTime),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Untuk tour: tampilkan nama paket + badge kode booking (tidak ada rute asal-tujuan)
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
                fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
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
    String printTime,
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
                      fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
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
          qrBlock(qrImage, price, printTime),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. RENTAL PDF — Sewa Bus
// ═══════════════════════════════════════════════════════════════════════════════

class RentalPesananPdf extends _BasePesananPdf {
  const RentalPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });

  Future<void> generate(int price) async {
    final pdf = pw.Document();
    final bookingCode = data["rental_code"] ?? "UNKNOWN";
    final printTime = _printTime;

    final qrData = jsonEncode({
      "code": bookingCode,
      "type": "rental",
      "name": displayName,
      "phone": displayPhone,
      "price": price,
      "status": data["status_final"] ?? "-",
    });

    final qrImage = pw.MemoryImage(await _generateQrBytes(qrData));

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
                  buildTotalBar(price, printTime),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _buildTripCard()),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _buildPassengerCard(price, bookingCode, printTime, qrImage),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  buildContactCard(),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(printTime),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Untuk rental: pickup -> destination, dengan range tanggal
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
              pw.Text(pickup, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text("Mulai: $startDate", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            "->",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey500),
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
                fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
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
    String printTime,
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
                      fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
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
                passengerField("Periode Sewa",
                    "${data["start_date"] ?? "-"} s/d\n${data["end_date"] ?? "-"}"),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          qrBlock(qrImage, price, printTime),
        ],
      ),
    );
  }
}