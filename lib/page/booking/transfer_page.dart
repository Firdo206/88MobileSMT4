import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../navigation/main_page.dart';

class TransferPage extends StatefulWidget {
  final int bookingId;
  final int total;
  final String bookingCode;

  const TransferPage({
    super.key,
    required this.bookingId,
    required this.total,
    required this.bookingCode,
  });

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  File? image;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    print("=== DEBUG TRANSFER PAGE ===");
    print("bookingId: ${widget.bookingId}");
    print("bookingCode: ${widget.bookingCode}");
    print("total: ${widget.total}");
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  String formatPrice(int price) {
    return "Rp ${price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ".",
    )}";
  }

  Future uploadPayment() async {
    if (widget.bookingId == 0 && widget.bookingCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking tidak valid")),
      );
      return;
    }
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload bukti dulu")),
      );
      return;
    }
    setState(() => loading = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiService.baseUrl}/upload-payment"),
      );
      request.headers['Accept'] = 'application/json';
      request.fields['booking_id'] = widget.bookingId.toString();
      request.fields['booking_code'] = widget.bookingCode;
      request.files.add(
        await http.MultipartFile.fromPath('payment_proof', image!.path),
      );
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      print("=== DEBUG UPLOAD ===");
      print("BOOKING ID: ${widget.bookingId}");
      print("BOOKING CODE: ${widget.bookingCode}");
      print("STATUS: ${response.statusCode}");
      print("BODY: $respStr");
      setState(() => loading = false);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bukti berhasil dikirim")),
        );
         Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const MainPage(initialIndex: 2), // ✅ langsung ke tab Pesanan
            ),
            (route) => false, // ✅ hapus semua route
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload gagal (${response.statusCode})")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Transfer Bank",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ── Info Rekening ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2D2D), Color(0xFFB23A3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B2D2D).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance, color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  const Text(
                    "Transfer ke Rekening",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "BCA - 1234567890",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "a.n 88 Trans",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Kode Booking & Total ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  // Kode Booking
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Kode Booking",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.bookingCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B2D2D),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                  ),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Pembayaran",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Text(
                        formatPrice(widget.total),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B2D2D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Upload Bukti ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bukti Transfer",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Area upload
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: double.infinity,
                      height: image != null ? null : 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: image != null
                              ? const Color(0xFF7B2D2D)
                              : const Color(0xFFDDDDDD),
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(image!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 40, color: Color(0xFFBDBDBD)),
                                SizedBox(height: 8),
                                Text(
                                  "Tap untuk pilih foto",
                                  style: TextStyle(
                                      color: Color(0xFFBDBDBD), fontSize: 13),
                                ),
                              ],
                            ),
                    ),
                  ),

                  if (image != null) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: pickImage,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh,
                              size: 14, color: Color(0xFF7B2D2D)),
                          SizedBox(width: 4),
                          Text(
                            "Ganti foto",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7B2D2D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Kirim ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : uploadPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2D2D),
                  disabledBackgroundColor: const Color(0xFFBDBDBD),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Kirim Bukti Pembayaran",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}