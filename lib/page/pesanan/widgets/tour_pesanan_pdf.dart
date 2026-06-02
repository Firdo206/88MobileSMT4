import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'base_pesanan_pdf.dart';

class TourPesananPdf extends BasePesananPdf {
  const TourPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });

  // Brand colors (sesuai web)
  static const _darkGreen = PdfColor.fromInt(0xFF1A3A2A);
  static const _accentGreen = PdfColor.fromInt(0xFF2D6A4F);
  static const _lightGreen = PdfColor.fromInt(0xFFEAF4ED);
  static const _borderGreen = PdfColor.fromInt(0xFF4CAF7D);
  static const _infoGreen = PdfColor.fromInt(0xFFD4EDDA);
  static const _warningYellow = PdfColor.fromInt(0xFFFFF8E1);
  static const _warningBorder = PdfColor.fromInt(0xFFFFB300);
  static const _textDark = PdfColor.fromInt(0xFF1A1A1A);
  static const _textGrey = PdfColor.fromInt(0xFF6B7280);
  static const _textLight = PdfColor.fromInt(0xFF9CA3AF);
  static const _white = PdfColors.white;
  static const _divider = PdfColor.fromInt(0xFFE5E7EB);

 Future<pw.Document> buildDocument(int price) async {
  print("=== DATA KEYS: ${data.keys.toList()}");
  print("=== order_date: ${data['order_date']}");
  final pdf = pw.Document();
  final bookingCode = data["booking_code"] ?? "UNKNOWN";
  final time = printTime;
  final status = (data["status_final"] ?? "-").toString().toUpperCase();

  final ttf = await PdfGoogleFonts.nunitoRegular();
  final ttfBold = await PdfGoogleFonts.nunitoBold();

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
      theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(bookingCode, status),
          _buildPackageTitle(),
          _buildPentingBanner(),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _buildInfoPemesan()),
                      pw.SizedBox(width: 16),
                      _buildQrBlock(qrImage, bookingCode, price, status, time),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  _buildDetailPaket(),
                  pw.SizedBox(height: 12),
                  _buildTotalHarga(price),
                  pw.SizedBox(height: 12),
                  _buildInfoTambahan(),
                ],
              ),
            ),
          ),
          _buildFooter(price, time),
        ],
      ),
    ),
  );

  return pdf; // ✅ TANPA Printing.layoutPdf
}

Future<Uint8List> generateBytes(int price) async {
  final pdf = await buildDocument(price);
  return Uint8List.fromList(await pdf.save()); 
}

Future<void> generate(int price) async {
  final pdf = await buildDocument(price);
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
  // ─── HEADER ───────────────────────────────────────────────────────────────

  pw.Widget _buildHeader(String bookingCode, String status) {
    return pw.Container(
      color: _darkGreen,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              color: _white,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Center(
              child: pw.Text(
                "88",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _darkGreen,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "IND'S 88 TRANS",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _white,
                  ),
                ),
                // FIX: ganti karakter "•" (U+2022) dengan "-" agar tidak crash di Helvetica
                pw.Text(
                  "E-Ticket Paket Wisata - Tour Package Ticket",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey300),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "KODE BOOKING",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400),
              ),
              pw.Text(
                bookingCode,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: pw.BoxDecoration(
                  color: _white,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  status,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── PACKAGE TITLE ────────────────────────────────────────────────────────

  pw.Widget _buildPackageTitle() {
    final packageName = data["package_name"] ?? "-";
    final description = (data["package_description"] ?? "").toString();
    return pw.Container(
      color: _lightGreen,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            packageName,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _textDark,
            ),
          ),
          if (description.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              description,
              style: pw.TextStyle(fontSize: 8.5, color: _textGrey),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Container(height: 2, color: _borderGreen),
        ],
      ),
    );
  }

  // ─── PENTING BANNER ────────────────────────────────────────────────────────

  pw.Widget _buildPentingBanner() {
    final message =
        (data["important_note"] ??
                "Hadir di titik kumpul minimal 30 menit sebelum jadwal keberangkatan.")
            .toString();
    return pw.Container(
      color: _warningYellow,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: pw.Row(
        children: [
          pw.Container(width: 3, height: 18, color: _warningBorder),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              "PENTING: $message",
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF7B5800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── INFORMASI PEMESAN ────────────────────────────────────────────────────

  pw.Widget _buildInfoPemesan() {
    final orderDate = _formatDate(data["created_at"]?.toString());
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle("INFORMASI PEMESAN"),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _divider),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(child: _labelValueBlock("NAMA PEMESAN", displayName)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _labelValueBlock("NO. TELEPON", displayPhone)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(child: _labelValueBlock("EMAIL", displayEmail)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _labelValueBlock("TGL PEMESANAN", orderDate)),
          ],
        ),
      ],
    );
  }

  // ─── QR BLOCK ─────────────────────────────────────────────────────────────

  pw.Widget _buildQrBlock(
    pw.ImageProvider qrImage,
    String bookingCode,
    int price,
    String status,
    String time,
  ) {
    return pw.Container(
      width: 130,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divider),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "VERIFIKASI TIKET",
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _textGrey,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Image(qrImage, width: 90, height: 90),
          pw.SizedBox(height: 6),
          pw.Text(
            bookingCode,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _accentGreen,
            ),
          ),
          pw.Text(
            "Scan untuk cek keaslian",
            style: pw.TextStyle(fontSize: 7, color: _textLight),
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: _divider),
          pw.SizedBox(height: 8),
          pw.Text(
            "Status Pembayaran:",
            style: pw.TextStyle(fontSize: 7, color: _textGrey),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            status == "LUNAS" ? "LUNAS / SETTLED" : status,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _accentGreen,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            "Waktu Cetak:",
            style: pw.TextStyle(fontSize: 7, color: _textGrey),
          ),
          pw.Text(time, style: pw.TextStyle(fontSize: 7, color: _textDark)),
        ],
      ),
    );
  }

  // ─── DETAIL PAKET ─────────────────────────────────────────────────────────

  pw.Widget _buildDetailPaket() {
    final packageName = (data["package_name"] ?? "-").toString();
    final travelDate = (data["travel_date"] ?? "-").toString();
    final passengerCount = data["passenger_count"]?.toString() ?? "-";

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle("DETAIL PAKET WISATA"),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _divider),
        pw.SizedBox(height: 10),
        // FIX: Border.all() boleh pakai borderRadius, tidak crash
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _divider),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            children: [
              _tableRow("Nama Paket", packageName, isFirst: true),
              _tableRow("Tgl Wisata", travelDate),
              _tableRow(
                "Jumlah Peserta",
                "$passengerCount Orang",
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── TOTAL HARGA ──────────────────────────────────────────────────────────

  pw.Widget _buildTotalHarga(int price) {
    final passengerCount =
        int.tryParse(data["passenger_count"]?.toString() ?? "1") ?? 1;
    final pricePerPax = passengerCount > 0 ? price ~/ passengerCount : price;
    final formattedTotal = _formatCurrency(price);
    final formattedPax = _formatCurrency(pricePerPax);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: pw.BoxDecoration(
        color: _infoGreen,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "Total Harga Paket Wisata",
            style: pw.TextStyle(fontSize: 9, color: _accentGreen),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            "Rp $formattedTotal",
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: _accentGreen,
            ),
          ),
          pw.Text(
            "(Rp $formattedPax / orang)",
            style: pw.TextStyle(fontSize: 8.5, color: _accentGreen),
          ),
        ],
      ),
    );
  }

  // ─── INFORMASI TAMBAHAN ───────────────────────────────────────────────────
  // FIX: border kiri saja TIDAK boleh digabung dengan borderRadius.
  // Solusi: bungkus dengan Stack — container hijau tipis di kiri, lalu konten di atas.

  pw.Widget _buildInfoTambahan() {
    return pw.Stack(
      children: [
        // Background + border kiri via Stack trick
        pw.Container(
          decoration: pw.BoxDecoration(
            color: _lightGreen,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.only(
            left: 15,
            top: 12,
            right: 12,
            bottom: 12,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Informasi Tambahan:",
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _accentGreen,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "- Harap membawa kartu identitas yang masih berlaku.\n"
                "- Tiket ini berlaku sesuai dengan tanggal wisata yang tertera.\n"
                "- Hubungi admin jika membutuhkan bantuan penjemputan khusus.",
                style: pw.TextStyle(fontSize: 8, color: _textDark, height: 1.5),
              ),
            ],
          ),
        ),
        // Border kiri hijau tebal
        pw.Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: pw.Container(
            width: 4,
            decoration: pw.BoxDecoration(
              color: _borderGreen,
              borderRadius: pw.BorderRadius.only(
                topLeft: const pw.Radius.circular(6),
                bottomLeft: const pw.Radius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── FOOTER ───────────────────────────────────────────────────────────────

  pw.Widget _buildFooter(int price, String time) {
    final formattedTotal = _formatCurrency(price);

    return pw.Container(
      color: _darkGreen,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "BUS 88 WISATA - Jelajahi Nusantara Bersama Kami",
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: _white,
                  ),
                ),
                pw.Text(
                  "Dokumen digital ini merupakan bukti pembayaran paket wisata yang sah.",
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "Total Bayar",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400),
              ),
              pw.Text(
                "Rp $formattedTotal",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: _accentGreen,
        letterSpacing: 0.5,
      ),
    );
  }

  pw.Widget _labelValueBlock(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: _textLight)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _textDark,
          ),
        ),
      ],
    );
  }

  pw.Widget _tableRow(
    String label,
    String value, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return pw.Container(
      decoration: isFirst
          ? null
          : pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: _divider, width: 0.5),
              ),
            ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8.5, color: _textGrey),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    final n = str.length;
    for (int i = 0; i < n; i++) {
      if (i > 0 && (n - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return "-";
    try {
      final dt = DateTime.parse(raw).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year}";
    } catch (_) {
      return raw;
    }
  }
}
