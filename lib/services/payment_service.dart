import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PaymentService {
  static Future<String?> getSnapToken(int bookingId) async {
    print("=== GET SNAP TOKEN ===");
    print("URL: ${ApiService.midtransPayment}");
    print("BOOKING ID: $bookingId");

    final response = await http.post(
      Uri.parse(ApiService.midtransPayment),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "booking_id": bookingId,
        "type": "bus",
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      return data['snap_token'];
    } else {
      print("ERROR: ${data['message']}");
      return null;
    }
  }

  // pembayaran dengan midtrans
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