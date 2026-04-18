import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class BookingPaketService {

  /// CREATE BOOKING PAKET
  static Future createBooking({
    required int userId,
    required int tourId,
    required String date,
    required int qty,
    required double total,
    String? notes,
  }) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/tour-bookings"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "tour_package_id": tourId,
        "travel_date": date,
        "passenger_count": qty,
        "total_price": total,
        "notes": notes
      }),
    );

    return jsonDecode(response.body);
  }

  /// GET DATA PAKET USER
  static Future<List> getMyTours(int userId) async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/my-tour-bookings/$userId"),
      headers: {
        "Accept": "application/json"
      }
    );
    
    final data = jsonDecode(response.body);

    if(data["data"] != null){
      return data["data"];
    }

    return [];
  }

  static Future cancelTour(dynamic id, {String reason = ""}) async {
  final response = await http.post(
    Uri.parse("${ApiService.baseUrl}/cancel-tour-booking/$id"),
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "reason": reason,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode != 200) {
    throw Exception(data["message"] ?? "Gagal membatalkan pesanan");
  }

  return data;
}

static Future finish(int id) async {
  final url = Uri.parse("${ApiService.baseUrl}/finish-tour/$id");

  final res = await http.post(url);

  if (res.statusCode != 200) {
    throw Exception("Gagal finish tour");
  }
}

}