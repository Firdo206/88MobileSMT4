import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class OtpService {

  // KIRIM OTP
  static Future<Map<String, dynamic>> sendOtp(int userId) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
      }),
    );

    return jsonDecode(response.body);
  }

  // VERIFY OTP + UPDATE NOMOR
  static Future<Map<String, dynamic>> verifyOtp(
      int userId, String otp, String phone) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "otp": otp,
        "phone": phone,
      }),
    );

    return jsonDecode(response.body);
  }
}