import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {

  /// 🔥 LOGIN EMAIL
  static Future<Map<String, dynamic>> login(
      String email,
      String password) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/login"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    var data = jsonDecode(response.body);

    if (data['status'] == true) {
      final prefs = await SharedPreferences.getInstance();

      prefs.setInt("user_id", data['data']['id']);
      prefs.setString("name", data['data']['name'] ?? "");
      prefs.setString("email", data['data']['email'] ?? "");
      prefs.setString("phone", data['data']['phone'] ?? "");

      prefs.setBool("require_phone", data['require_phone'] ?? false);
    }

    return data;
  }


  /// 🔥 REGISTER
  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String phone,
      String password) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/register"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password
      }),
    );

    return jsonDecode(response.body);
  }


  /// 🔥 GOOGLE LOGIN
  static Future<Map<String, dynamic>> googleLogin(
      String googleId,
      String name,
      String email,
      String photo) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/google-login"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "google_id": googleId,
        "name": name,
        "email": email,
        "photo": photo
      }),
    );

    var data = jsonDecode(response.body);

    if (data['status'] == true) {
      final prefs = await SharedPreferences.getInstance();

      prefs.setInt("user_id", data['data']['id']);
      prefs.setString("name", data['data']['name'] ?? "");
      prefs.setString("email", data['data']['email'] ?? "");
      prefs.setString("phone", data['data']['phone'] ?? "");

      prefs.setBool("require_phone", data['require_phone'] ?? false);
    }

    return data;
  }


  // =========================================
  // 🔥 FORGOT PASSWORD (KIRIM OTP)
  // =========================================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/forgot-password"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email
      }),
    );

    return jsonDecode(response.body);
  }


  // =========================================
  // 🔥 VERIFY OTP
  // =========================================
  static Future<Map<String, dynamic>> verifyOtp(
      String email,
      String otp) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/verify-otp-reset"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "otp": otp
      }),
    );

    return jsonDecode(response.body);
  }


  // =========================================
  // 🔥 RESET PASSWORD
  // =========================================
  static Future<Map<String, dynamic>> resetPassword(
      String email,
      String otp,
      String password) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/reset-password"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "password": password
      }),
    );

    return jsonDecode(response.body);
  }

}