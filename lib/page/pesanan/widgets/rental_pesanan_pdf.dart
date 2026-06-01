import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'base_pesanan_pdf.dart';

class RentalPesananPdf extends BasePesananPdf {
  const RentalPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });
  // Brand colors
  static const _darkBlue   = PdfColor.fromInt(0xFF1A2550);
  static const _accentBlue = PdfColor.fromInt(0xFF2D3A8C);
  static const _lightBlue  = PdfColor.fromInt(0xFFEEF0FA);
  static const _borderBlue = PdfColor.fromInt(0xFF4A5BC4);
  static const _infoBlue   = PdfColor.fromInt(0xFFD6DCF7);
  static const _warningYellow  = PdfColor.fromInt(0xFFFFF8E1);
  static const _warningBorder  = PdfColor.fromInt(0xFFFFB300);
  static const _textDark  = PdfColor.fromInt(0xFF1A1A1A);
  static const _textGrey  = PdfColor.fromInt(0xFF6B7280);
  static const _textLight = PdfColor.fromInt(0xFF9CA3AF);
  static const _white     = PdfColors.white;
  static const _divider   = PdfColor.fromInt(0xFFE5E7EB);

  Future<void> generate(int price) async {
    print("DATA KEYS: ${data.keys.toList()}");
  print("DATA VALUES: $data");
    final pdf = pw.Document();
    final bookingCode = data["rental_code"] ?? "UNKNOWN";
    final time = printTime;
    final status = (data["status_final"] ?? "-").toString().toUpperCase();

    final ttf     = await PdfGoogleFonts.nunitoRegular();
    final ttfBold = await PdfGoogleFonts.nunitoBold();

    final qrData = jsonEncode({
      "code": bookingCode,
      "type": "rental",
      "name": displayName,
      "phone": displayPhone,
      "price": price,
      "status": data["status_final"] ?? "-",
      "purpose": data["purpose"] ?? "-",    
      "passengers": data["passenger_count"],
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
            _buildRouteBar(),
            _buildPentingBanner(),
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // Rincian Perjalanan + Verifikasi Tiket (side by side)
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(child: _buildRincianPerjalanan()),
                        pw.SizedBox(width: 16),
                        _buildQrBlock(qrImage, bookingCode, price, status, time),
                      ],
                    ),
                    pw.SizedBox(height: 14),
                    _buildInfoPenyewa(),
                    pw.SizedBox(height: 14),
                    _buildDetailArmada(),
                    pw.SizedBox(height: 14),
                    _buildSyaratKetentuan(),
                  ],
                ),
              ),
            ),
            _buildFooter(price, time),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  pw.Widget _buildHeader(String bookingCode, String status) {
    return pw.Container(
      color: _darkBlue,
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
                  color: _darkBlue,
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
                pw.Text(
                  "E-Ticket Sewa Bus - Bus Charter Ticket",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey300),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "KODE SEWA",
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
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: _white,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  status,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ROUTE BAR ────────────────────────────────────────────────────────────

  pw.Widget _buildRouteBar() {
    final pickup      = (data["pickup_location"] ?? "-").toString();
    final destination = (data["destination"] ?? "-").toString();
    final duration    = (data["duration_days"] ?? "-").toString();

    return pw.Container(
      color: _lightBlue,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Pickup
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  pickup,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _accentBlue,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "Lokasi Penjemputan",
                  style: pw.TextStyle(fontSize: 8, color: _textGrey),
                ),
              ],
            ),
          ),
          // Arrow + duration
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: pw.Column(
              children: [
                pw.Text(
                  "->",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _accentBlue,
                  ),
                ),
                pw.Text(
                  "$duration Hari",
                  style: pw.TextStyle(fontSize: 7.5, color: _textGrey),
                ),
              ],
            ),
          ),
          // Destination
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  destination,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _accentBlue,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "Tujuan",
                  style: pw.TextStyle(fontSize: 8, color: _textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PENTING BANNER ───────────────────────────────────────────────────────

  pw.Widget _buildPentingBanner() {
    final message = (data["important_note"] ??
            "Tunjukkan e-tiket ini kepada pengemudi/petugas saat penjemputan armada.")
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

  // ─── RINCIAN PERJALANAN ───────────────────────────────────────────────────

  pw.Widget _buildRincianPerjalanan() {
    final pickup      = (data["pickup_location"] ?? "-").toString();
    final destination = (data["destination"] ?? "-").toString();
    final startDate   = _formatDate(data["start_date"]?.toString());
    final endDate     = _formatDate(data["end_date"]?.toString());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle("RINCIAN PERJALANAN"),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _divider),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _divider),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Penjemputan
              pw.Text(
                "PENJEMPUTAN",
                style: pw.TextStyle(fontSize: 7, color: _textLight),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                pickup,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                startDate,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _accentBlue,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(height: 0.5, color: _divider),
              pw.SizedBox(height: 10),
              // Tujuan
              pw.Text(
                "TUJUAN UTAMA",
                style: pw.TextStyle(fontSize: 7, color: _textLight),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                destination,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                endDate,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _accentBlue,
                ),
              ),
            ],
          ),
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
    final formattedTotal = _formatCurrency(price);
    return pw.Container(
      width: 140,
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
              color: _accentBlue,
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
            "Total Harga Sewa",
            style: pw.TextStyle(fontSize: 7.5, color: _textGrey),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            "Rp $formattedTotal",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _accentBlue,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: _divider),
          pw.SizedBox(height: 8),
          pw.Text(
            "Status: $status",
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _accentBlue,
            ),
          ),
          pw.Text(
            "Dicetak pada: $time",
            style: pw.TextStyle(fontSize: 7, color: _textGrey),
          ),
        ],
      ),
    );
  }

  // ─── INFORMASI PENYEWA ────────────────────────────────────────────────────

  pw.Widget _buildInfoPenyewa() {
    final orderDate = _formatDate(data["created_at"]?.toString());
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle("INFORMASI PENYEWA"),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _divider),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(child: _labelValueBlock("NAMA PENYEWA", displayName)),
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
  pw.Widget _buildDetailArmada() {
    final busName   = (data["bus_name"] ?? data["name"] ?? "-").toString();
    final capacity = (data["bus_capacity"] ?? "-").toString(); 
    final duration  = (data["duration_days"] ?? "-").toString();
    final notes     = (data["purpose"] ?? "-").toString();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle("DETAIL ARMADA & SEWA"),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _divider),
        pw.SizedBox(height: 10),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _divider),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            children: [
              _tableRow("Nama Armada", busName, isFirst: true),
              _tableRow("Kapasitas", "$capacity Kursi"),
              _tableRow("Durasi", "$duration Hari"),
              _tableRow("Keperluan", notes, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  // ─── SYARAT & KETENTUAN ───────────────────────────────────────────────────

  pw.Widget _buildSyaratKetentuan() {
    return pw.Stack(
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            color: _lightBlue,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.only(left: 15, top: 12, right: 12, bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Syarat & Ketentuan:",
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _accentBlue,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "- Armada akan standby 30 menit sebelum waktu penjemputan.\n"
                "- Biaya sudah termasuk BBM dan Driver (Kecuali disepakati lain).\n"
                "- Hubungi CS di 0812-XXXX-XXXX jika ada kendala lapangan.",
                style: pw.TextStyle(fontSize: 8, color: _accentBlue, height: 1.5),
              ),
            ],
          ),
        ),
        pw.Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: pw.Container(
            width: 4,
            decoration: pw.BoxDecoration(
              color: _borderBlue,
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
      color: _darkBlue,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "BUS 88 - Layanan Sewa Bus Terpercaya",
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: _white,
                  ),
                ),
                pw.Text(
                  "Dokumen ini diterbitkan secara digital dan sah tanpa tanda tangan.",
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "Total Pembayaran",
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
        color: _accentBlue,
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
      return "${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}";
    } catch (_) {
      return raw;
    }
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[m];
  }
}