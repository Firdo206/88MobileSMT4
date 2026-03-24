import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class TransferPage extends StatefulWidget {
  final int bookingId;
  final int total;
  final String bookingCode; // 🔥 TAMBAH INI

  const TransferPage({
    super.key,
    required this.bookingId,
    required this.total,
    required this.bookingCode, // 🔥 TAMBAH INI
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

    if(picked != null){
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

    /// VALIDASI - pakai bookingCode sebagai fallback
    if(widget.bookingId == 0 && widget.bookingCode.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking tidak valid"))
      );
      return;
    }

    if(image == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload bukti dulu"))
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiService.baseUrl}/upload-payment"),
      );

      request.headers['Accept'] = 'application/json';

      // 🔥 kirim booking_id DAN booking_code sekaligus
      request.fields['booking_id'] = widget.bookingId.toString();
      request.fields['booking_code'] = widget.bookingCode;

      request.files.add(
        await http.MultipartFile.fromPath(
          'payment_proof',
          image!.path
        )
      );

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      print("=== DEBUG UPLOAD ===");
      print("BOOKING ID: ${widget.bookingId}");
      print("BOOKING CODE: ${widget.bookingCode}");
      print("STATUS: ${response.statusCode}");
      print("BODY: $respStr");

      setState(() {
        loading = false;
      });

      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bukti berhasil dikirim"))
        );
        Navigator.pop(context);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload gagal (${response.statusCode})"))
        );
      }

    } catch (e) {
      setState(() {
        loading = false;
      });
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer Bank"),
        backgroundColor: Colors.red,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// REKENING
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: const [
                  Text("Silakan transfer ke rekening berikut"),
                  SizedBox(height: 10),
                  Text("BCA - 1234567890"),
                  Text("a.n 88 Trans"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 TAMPILKAN BOOKING CODE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kode Booking", style: TextStyle(color: Colors.black54)),
                  Text(
                    widget.bookingCode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// TOTAL
            const Text("Total", style: TextStyle(fontSize: 16)),
            Text(
              formatPrice(widget.total),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red
              ),
            ),

            const SizedBox(height: 20),

            /// UPLOAD
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Upload Bukti Transfer"),
            ),

            const SizedBox(height: 10),

            image != null
              ? Image.file(image!, height: 150)
              : const Text("Belum ada bukti"),

            const Spacer(),

            /// KIRIM
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : uploadPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(15),
                ),
                child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Kirim Bukti"),
              ),
            )
          ],
        ),
      ),
    );
  }
}