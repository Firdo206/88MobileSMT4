import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ScheduleService {

  // ambil semua jadwal
  static Future<List<dynamic>> getSchedules() async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/schedules"),
      headers: {
        "Accept": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil jadwal bus");
    }

  }

}