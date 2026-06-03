import 'package:flutter/material.dart' show Color;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';

// ═══════════════════════════════════════════════════════════════════════════════
// BASE CLASS — shared helpers & common layout widgets
// ═══════════════════════════════════════════════════════════════════════════════

abstract class BasePesananPdf {
  final Map data;
  final String displayName;
  final String displayPhone;
  final String displayEmail;

  const BasePesananPdf({
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

  String pad(int n) => n.toString().padLeft(2, '0');

  String get printTime {
    final now = DateTime.now();
    return "${now.year}-${pad(now.month)}-${pad(now.day)} "
        "${pad(now.hour)}:${pad(now.minute)}:${pad(now.second)}";
  }

  Future<Uint8List> generateQrBytes(String qrData) async {
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
              pw.Text(displayPhone,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(width: 30),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Email", style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
              pw.Text(displayEmail,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
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