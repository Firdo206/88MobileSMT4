import 'package:flutter/material.dart' show Color;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';

class DetailPesananPdf {
  final Map data;
  final String type;
  final String displayName;
  final String displayPhone;
  final String displayEmail;
  

  const DetailPesananPdf({
    required this.data,
    required this.type,
    required this.displayName,
    required this.displayPhone,
    required this.displayEmail,
  });

  // ─── helpers (tidak diubah) ────────────────────────────────────────────────

  String rupiah(dynamic value) {
    int v = int.tryParse(value.toString()) ?? 0;
    return v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => "${m[1]}.",
    );
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

  // ─── generate (logic tidak diubah, hanya layout) ──────────────────────────

  Future<void> generate(int price) async {
    final pdf = pw.Document();
    final bookingCode =
        data["booking_code"] ?? data["rental_code"] ?? "UNKNOWN";

    final qrData = jsonEncode({
      "code": bookingCode,
      "type": type,
      "name": displayName,
      "phone": displayPhone,
      "price": price,
      "status": data["status_final"] ?? "-",
    });

    final qrBytes = await _generateQrBytes(qrData);
    final qrPdfImage = pw.MemoryImage(qrBytes);

    // Ambil waktu cetak sekarang
    final now = DateTime.now();
    final printTime =
        "${now.year}-${_pad(now.month)}-${_pad(now.day)} ${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Header merah ──────────────────────────────────────────────
            _buildTopHeader(),
            // ── Info bar (contact, email, website) ───────────────────────
            _buildInfoBar(),
            // ── Konten utama ─────────────────────────────────────────────
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // PENTING banner
                  _buildPentingBanner(),
                  pw.SizedBox(height: 12),
                  // Rute + Kode Booking
                  _buildRouteRow(bookingCode),
                  pw.SizedBox(height: 12),
                  // Total harga bar
                  _buildTotalBar(price, printTime),
                  pw.SizedBox(height: 12),
                  // Dua kartu: Rincian Perjalanan & Rincian Penumpang
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _buildTripCard()),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: _buildPassengerCard(
                          price,
                          bookingCode,
                          printTime,
                          qrPdfImage,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  // Kartu Kontak
                  _buildContactCard(),
                ],
              ),
            ),
            pw.Spacer(),
            // ── Footer ───────────────────────────────────────────────────
            _buildFooter(printTime),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ─── UI builders (diubah agar mirip web) ──────────────────────────────────

  /// Header merah atas: logo kiri, alamat kanan
  pw.Widget _buildTopHeader() {
    return pw.Container(
      color: PdfColors.red800,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo kiri
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
          // Alamat kanan
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

  /// Bar abu-abu: contact center, email, website
  pw.Widget _buildInfoBar() {
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
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  /// Banner kuning "PENTING"
  pw.Widget _buildPentingBanner() {
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

  /// Baris rute: Kota Asal -> Kota Tujuan + badge kode booking
  pw.Widget _buildRouteRow(String bookingCode) {
    String origin = "-";
    String destination = "-";
    String depDate = "-";
    String depTime = "-";
    String arrDate = "-";
    String arrTime = "-";

    if (type == "ticket") {
      origin = data["origin"] ?? "-";
      destination = data["destination"] ?? "-";
      depDate = data["departure_date"] ?? "-";
      depTime = "${data["departure_time"] ?? "-"} WIB";
      arrDate = data["departure_date"] ?? "-"; // sama hari
      arrTime = "${data["arrival_time"] ?? "-"} WIB";
    } else if (type == "bus") {
      origin = data["pickup_location"] ?? "-";
      destination = data["destination"] ?? "-";
      depDate = data["start_date"] ?? "-";
      arrDate = data["end_date"] ?? "-";
    } else {
      origin = data["package_name"] ?? "-";
      destination = data["destination"] ?? "-";
      depDate = data["travel_date"] ?? "-";
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Asal
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                origin,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                depDate,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                depTime,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        // Panah
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            "->",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey500,
            ),
          ),
        ),
        // Tujuan
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  destination,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  arrDate,
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text(
                  arrTime,
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
        ),
        // Badge kode booking
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "Kode Booking",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              ),
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
        ),
      ],
    );
  }

  /// Bar total harga
  pw.Widget _buildTotalBar(int price, String printTime) {
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

  /// Kartu Rincian Perjalanan (kiri)
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
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildTripSection(),
        ],
      ),
    );
  }

  /// Isi Rincian Perjalanan (logika tidak berubah, hanya pakai dot bullet)
  pw.Widget _buildTripSection() {
    if (type == "ticket") {
      final origin = data["origin"] ?? "-";
      final destination = data["destination"] ?? "-";
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _dotRow(PdfColors.blue700, "Berangkat Dari", origin),
          pw.SizedBox(height: 8),
          _dotRow(PdfColors.red700, "Menuju ke", destination),
        ],
      );
    }
    if (type == "bus") {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _dotRow(
            PdfColors.blue700,
            "Penjemputan",
            data["pickup_location"] ?? "-",
          ),
          pw.SizedBox(height: 8),
          _dotRow(PdfColors.red700, "Tujuan", data["destination"] ?? "-"),
          pw.SizedBox(height: 8),
          _labelValue("Tanggal", "${data["start_date"]} - ${data["end_date"]}"),
          _labelValue("Durasi", "${data["duration_days"]} hari"),
          _labelValue("Penumpang", "${data["passenger_count"]} orang"),
        ],
      );
    }
    // tour
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _dotRow(PdfColors.blue700, "Paket", data["package_name"] ?? "-"),
        pw.SizedBox(height: 8),
        _labelValue("Tanggal", data["travel_date"] ?? "-"),
        _labelValue("Durasi", "${data["duration_days"]} hari"),
        _labelValue("Penumpang", "${data["passenger_count"]} orang"),
      ],
    );
  }

  pw.Widget _dotRow(PdfColor color, String label, String value) {
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
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _labelValue(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 14),
          pw.Text(
            "$label: ",
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Kartu Rincian Penumpang (kanan) + QR
  pw.Widget _buildPassengerCard(
    int price,
    String bookingCode,
    String printTime,
    pw.ImageProvider qrImage,
  ) {
    final passengers = data["passengers"];
      final firstPassenger = (passengers is List && passengers.isNotEmpty)
          ? passengers[0] as Map
          : null;
      final seatNo = firstPassenger?["seat"]?.toString()
          ?? data["seat_number"]?.toString()
          ?? data["seat"]?.toString()
          ?? "-";
    final busName = type == "ticket" ? (data["bus_name"] ?? "-") : null;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Info penumpang
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Rincian Penumpang",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 10),
                _passengerField("Nama Penumpang", displayName),
                pw.SizedBox(height: 6),
                _passengerField("Nomor Kursi", seatNo.toString()),
                pw.SizedBox(height: 6),
                _passengerField("No. Telepon", displayPhone),
                pw.SizedBox(height: 6),
                _passengerField("Kode Tiket", bookingCode),
                if (busName != null) ...[
                  pw.SizedBox(height: 6),
                  _passengerField("Bus", busName),
                ],
                pw.SizedBox(height: 6),
                _passengerField(
                  "Waktu Keberangkatan",
                  type == "ticket"
                      ? "${data["departure_date"] ?? "-"}\nPukul ${data["departure_time"] ?? "-"} WIB"
                      : data["start_date"] ?? "-",
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          // QR + harga
          pw.Column(
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
          ),
        ],
      ),
    );
  }

  pw.Widget _passengerField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  /// Kartu Kontak bawah
  pw.Widget _buildContactCard() {
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
              pw.Text(
                "No. Telepon",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
              ),
              pw.Text(
                displayPhone,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(width: 30),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Email",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
              ),
              pw.Text(
                displayEmail,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Footer
  pw.Widget _buildFooter(String printTime) {
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

  // ─── helper kecil ─────────────────────────────────────────────────────────

  String _pad(int n) => n.toString().padLeft(2, '0');
}
