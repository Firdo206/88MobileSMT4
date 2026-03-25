import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class TourService {

  static Future<List<dynamic>> getTours() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/tour-packages"),
      headers: {
        "Accept": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception("Gagal ambil data");
    }
  }
}