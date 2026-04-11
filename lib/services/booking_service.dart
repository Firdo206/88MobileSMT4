import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class BookingService {

  static Future<List> getMyBookings(int userId) async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/my-bookings/$userId"),
      headers: {
        "Accept": "application/json"
      }
    );

    print(response.body);

    final data = jsonDecode(response.body);

    if(data["data"] != null){
      return data["data"];
    }

    return [];

  }

    static Future<Map> getBookingDetail(int id) async {
    final res = await http.get(
      Uri.parse("${ApiService.baseUrl}/booking-detail/$id"),
      headers: {"Accept": "application/json"},
    );

    final data = jsonDecode(res.body);
    return data["data"];
  }

  static Future cancelBooking(int id) async {
  final response = await http.post(
    Uri.parse("${ApiService.baseUrl}/booking/cancel/$id"),
    headers: {
      "Accept": "application/json"
    }
  );

  return jsonDecode(response.body);
}

static Future finish(int id) async {
  final url = Uri.parse("${ApiService.baseUrl}/finish-booking/$id");

  final res = await http.post(url);

  if (res.statusCode != 200) {
    throw Exception("Gagal finish booking");
  }
}

} 