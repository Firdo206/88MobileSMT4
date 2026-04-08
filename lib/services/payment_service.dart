import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PaymentService {
  static Future<String?> getSnapToken(int bookingId) async {
    final response = await http.post(
      Uri.parse(ApiService.midtransPayment),
      headers: {
        "Accept": "application/json"
      },
      body: {
        "booking_id": bookingId.toString(),
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      return data['snap_token'];
    } else {
      print("ERROR: ${data['message']}");
      return null;
    }
  }

  // 🔥 TAMBAHAN: Cek status pembayaran langsung ke Midtrans via backend
  static Future<String?> checkStatus(int bookingId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.checkPaymentStatus}/$bookingId"),
        headers: {"Accept": "application/json"},
      );

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        return data['payment_status'];
      }
      return null;
    } catch (e) {
      print("Error cek status: $e");
      return null;
    }
  }
}