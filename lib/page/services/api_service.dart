import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://172.18.174.49:8000/api";

  static Future register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {
        "Accept": "application/json"
      },
      body: {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
      },
    );

    return jsonDecode(response.body);
  }
}