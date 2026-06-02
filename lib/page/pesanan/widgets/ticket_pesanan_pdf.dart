import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'base_pesanan_pdf.dart';
import 'dart:typed_data';

class TicketPesananPdf extends BasePesananPdf {
  const TicketPesananPdf({
    required super.data,
    required super.displayName,
    required super.displayPhone,
    required super.displayEmail,
  });

  // Brand colors — merah sesuai web
  static const _darkRed    = PdfColor.fromInt(0xFF8B2635);
  static const _accentRed  = PdfColor.fromInt(0xFFB84545);
  static const _lightRed   = PdfColor.fromInt(0xFFFFF0F0);
  static const _borderRed  = PdfColor.fromInt(0xFFE53935);
  static const _textDark   = PdfColor.fromInt(0xFF1A1A1A);
  static const _textGrey   = PdfColor.fromInt(0xFF6B7280);
  static const _textLight  = PdfColor.fromInt(0xFF9CA3AF);
  static const _white      = PdfColors.white;
  static const _divider    = PdfColor.fromInt(0xFFE5E7EB);
  static const _warningYellow = PdfColor.fromInt(0xFFFFF8E1);
  static const _warningBorder = PdfColor.fromInt(0xFFFFB300);

  Future<pw.Document> buildDocument(int price) async {
    final pdf = pw.Document();
    final bookingCode = data["booking_code"] ?? "UNKNOWN";
    final time = printTime;
    final status = (data["status_final"] ?? "PAID").toString().toUpperCase();

    final ttf     = await PdfGoogleFonts.nunitoRegular();
    final ttfBold = await PdfGoogleFonts.nunitoBold();

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
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(child: _buildRincianPerjalanan()),
                        pw.SizedBox(width: 16),
                        _buildQrBlock(qrImage, bookingCode, price, status, time),
                      ],
                    ),
                    pw.SizedBox(height: 14),
                    _buildInfoPenumpang(),
                    pw.SizedBox(height: 14),
                    _buildDetailBus(),
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

    return pdf;
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
      color: _darkRed,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 40, height: 40,
            decoration: pw.BoxDecoration(
              color: _white,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Center(
              child: pw.Text("88",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _darkRed)),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("IND'S 88 TRANS",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _white)),
                pw.Text("E-Ticket Tiket Bus - Bus Ticket",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.red100)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text("KODE BOOKING",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.red100)),
              pw.Text(bookingCode,
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _white)),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: _white,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(status,
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _darkRed)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ROUTE BAR ────────────────────────────────────────────────────────────

  pw.Widget _buildRouteBar() {
    final origin      = (data["origin"] ?? "-").toString();
    final destination = (data["destination"] ?? "-").toString();
    final depDate     = (data["departure_date"] ?? "-").toString();
    final depTime     = (data["departure_time"] ?? "-").toString();

    return pw.Container(
      color: _lightRed,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(origin,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _darkRed)),
                pw.SizedBox(height: 2),
                pw.Text(depDate,
                  style: pw.TextStyle(fontSize: 8, color: _textGrey)),
                pw.Text("$depTime WIB",
                  style: pw.TextStyle(fontSize: 8, color: _textGrey)),
                pw.SizedBox(height: 2),
                pw.Text("Asal", style: pw.TextStyle(fontSize: 7, color: _textLight)),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: pw.Text("->",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _accentRed)),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(destination,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _darkRed)),
                pw.SizedBox(height: 2),
                pw.Text(depDate,
                  style: pw.TextStyle(fontSize: 8, color: _textGrey)),
                pw.Text("${data["arrival_time"] ?? "-"} WIB",
                  style: pw.TextStyle(fontSize: 8, color: _textGrey)),
                pw.SizedBox(height: 2),
                pw.Text("Tujuan", style: pw.TextStyle(fontSize: 7, color: _textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PENTING BANNER ───────────────────────────────────────────────────────

  pw.Widget _buildPentingBanner() {
    return pw.Container(
      color: _warningYellow,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: pw.Row(
        children: [
          pw.Container(width: 3, height: 18, color: _warningBorder),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              "PENTING: Tunjukkan e-tiket ini kepada petugas saat naik bus.",
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF7B5800)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── RINCIAN PERJALANAN ───────────────────────────────────────────────────

  pw.Widget _buildRincianPerjalanan() {
    final origin      = (data["origin"] ?? "-").toString();
    final destination = (data["destination"] ?? "-").toString();
    final busName     = (data["bus_name"] ?? "-").toString();
    final depDate     = (data["departure_date"] ?? "-").toString();
    final depTime     = (data["departure_time"] ?? "-").toString();
    final arrTime     = (data["arrival_time"] ?? "-").toString();

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
              pw.Text("ARMADA", style: pw.TextStyle(fontSize: 7, color: _textLight)),
              pw.SizedBox(height: 2),
              pw.Text(busName,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textDark)),
              pw.SizedBox(height: 10),
              pw.Container(height: 0.5, color: _divider),
              pw.SizedBox(height: 10),
              pw.Text("BERANGKAT DARI",
                style: pw.TextStyle(fontSize: 7, color: _textLight)),
              pw.SizedBox(height: 3),
              pw.Text(origin,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textDark)),
              pw.SizedBox(height: 2),
              pw.Text("$depDate - $depTime WIB",
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _accentRed)),
              pw.SizedBox(height: 10),
              pw.Container(height: 0.5, color: _divider),
              pw.SizedBox(height: 10),
              pw.Text("TUJUAN", style: pw.TextStyle(fontSize: 7, color: _textLight)),
              pw.SizedBox(height: 3),
              pw.Text(destination,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textDark)),
              pw.SizedBox(height: 2),
              pw.Text("$depDate - $arrTime WIB",
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _accentRed)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── QR BLOCK ─────────────────────────────────────────────────────────────

  pw.Widget _buildQrBlock(pw.ImageProvider qrImage, String bookingCode,
      int price, String status, String time) {
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
          pw.Text("VERIFIKASI TIKET",
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _textGrey)),
          pw.SizedBox(height: 8),
          pw.Image(qrImage, width: 90, height: 90),
          pw.SizedBox(height: 6),
          pw.Text(bookingCode,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _accentRed)),
          pw.Text("Scan untuk cek keaslian",
            style: pw.TextStyle(fontSize: 7, color: _textLight)),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: _divider),
          pw.SizedBox(height: 8),
          pw.Text("Total Harga Tiket",
            style: pw.TextStyle(fontSize: 7.5, color: _textGrey)),
          pw.SizedBox(height: 2),
          pw.Text("Rp ${_formatCurrency(price)}",
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _accentRed)),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: _divider),
          pw.SizedBox(height: 8),
          pw.Text("Status: $status",
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _accentRed)),
          pw.Text("Dicetak pada: $time",
            style: pw.TextStyle(fontSize: 7, color: _textGrey)),
        ],
      ),
    );
  }

  // ─── INFO PENUMPANG ───────────────────────────────────────────────────────

  pw.Widget _buildInfoPenumpang() {
    final passengers = data["passengers"];
    final firstPassenger =
        (passengers is List && passengers.isNotEmpty) ? passengers[0] as Map : null;
    final seatNo = firstPassenger?["seat"]?.toString() ??
        data["seat_number"]?.toString() ??
        data["seat"]?.toString() ?? "-";
    final expiredDate = _formatDate(data["expired_at"]?.toString());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle("INFORMASI PENUMPANG"),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _divider),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(child: _labelValueBlock("NAMA PENUMPANG", displayName)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _labelValueBlock("NOMOR KURSI", seatNo)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(child: _labelValueBlock("NO. TELEPON", displayPhone)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _labelValueBlock("TGL KADALUARSA", expiredDate)),
          ],
        ),
      ],
    );
  }

  // ─── DETAIL BUS ───────────────────────────────────────────────────────────

  pw.Widget _buildDetailBus() {
    final busName  = (data["bus_name"] ?? "-").toString();
    final origin   = (data["origin"] ?? "-").toString();
    final dest     = (data["destination"] ?? "-").toString();
    final depDate  = (data["departure_date"] ?? "-").toString();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle("DETAIL BUS & PERJALANAN"),
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
              _tableRow("Nama Bus", busName, isFirst: true),
              _tableRow("Rute", "$origin - $dest"),
              _tableRow("Tanggal", depDate),
              _tableRow("Email", displayEmail, isLast: true),
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
            color: _lightRed,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.only(left: 15, top: 12, right: 12, bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Syarat & Ketentuan:",
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _darkRed)),
              pw.SizedBox(height: 4),
              pw.Text(
                "- Tiket berlaku untuk satu kali perjalanan sesuai jadwal.\n"
                "- Tunjukkan e-tiket kepada petugas sebelum naik bus.\n"
                "- Hubungi CS di (0331) 3068888 jika ada kendala.",
                style: pw.TextStyle(fontSize: 8, color: _darkRed, height: 1.5),
              ),
            ],
          ),
        ),
        pw.Positioned(
          left: 0, top: 0, bottom: 0,
          child: pw.Container(
            width: 4,
            decoration: pw.BoxDecoration(
              color: _borderRed,
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
    return pw.Container(
      color: _darkRed,
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("BUS 88 - Layanan Transportasi Terpercaya",
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _white)),
                pw.Text("Dokumen ini diterbitkan secara digital dan sah tanpa tanda tangan.",
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.red100)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text("Total Pembayaran",
                style: pw.TextStyle(fontSize: 7, color: PdfColors.red100)),
              pw.Text("Rp ${_formatCurrency(price)}",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _white)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  pw.Widget _sectionTitle(String title) {
    return pw.Text(title,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold,
        color: _darkRed, letterSpacing: 0.5));
  }

  pw.Widget _labelValueBlock(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: _textLight)),
        pw.SizedBox(height: 2),
        pw.Text(value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textDark)),
      ],
    );
  }

  pw.Widget _tableRow(String label, String value,
      {bool isFirst = false, bool isLast = false}) {
    return pw.Container(
      decoration: isFirst ? null : pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _divider, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label,
              style: pw.TextStyle(fontSize: 8.5, color: _textGrey)),
          ),
          pw.Expanded(
            child: pw.Text(value,
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _textDark)),
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
    } catch (_) { return raw; }
  }

  String _monthName(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m];
  }
}