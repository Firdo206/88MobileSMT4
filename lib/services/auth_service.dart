import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {

  // LOGIN
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

    // simpan user_id jika login berhasil
    if (data['status'] == true) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt("user_id", data['data']['id']);
    }

    return data;
  }


  // REGISTER
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


  // TAMBAHAN GOOGLE LOGIN (INI YANG MEMPERBAIKI ERROR)
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

    // simpan user_id jika berhasil login
    if (data['status'] == true) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt("user_id", data['data']['id']);
    }

    return data;
  }

}