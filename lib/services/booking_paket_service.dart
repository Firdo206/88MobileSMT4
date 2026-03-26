import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class BookingService {
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
}