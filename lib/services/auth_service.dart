import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {

  // REGISTER
  static Future register(
    String name,
    String email,
    String phone,
    String password,
  ) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/register"),
      headers: {"Accept": "application/json"},
      body: {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
      },
    );

    return jsonDecode(response.body);
  }


  // LOGIN
  static Future login(
  String email,
  String password,
) async {

  final response = await http.post(
    Uri.parse("${ApiService.baseUrl}/login"),
    headers: {"Accept": "application/json"},
    body: {
      "email": email,
      "password": password,
    },
  );

  return jsonDecode(response.body);
}
}