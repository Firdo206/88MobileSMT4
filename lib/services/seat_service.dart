import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class SeatService {

  // ambil layout kursi
  static Future<Map<String, dynamic>> getSeatLayout(int scheduleId) async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/seat-layout/$scheduleId"),
      headers: {
        "Accept": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil kursi");
    }

  }


  // booking kursi
  static Future<Map<String, dynamic>> bookSeat({
    required int scheduleId,
    required List seats,
    required String passengerName
  }) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/book-seats"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "schedule_id": scheduleId,
        "seats": seats,
        "passenger_name": passengerName
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Booking kursi gagal");
    }

  }

}