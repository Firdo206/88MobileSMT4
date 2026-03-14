import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ProfileService {

  static Future<Map<String, dynamic>> getProfile(int id) async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/profile/$id"),
      headers: {
        "Accept": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data profil");
    }

  }

}
