import 'dart:convert';
import 'package:http/http.dart' as http;
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

    return jsonDecode(response.body);
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

}