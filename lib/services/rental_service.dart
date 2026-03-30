import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class RentalService {

  /// ================= GET MY RENTALS =================
  static Future<List> getMyRentals(int userId) async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/my-rentals/$userId"),
      headers: {
        "Accept": "application/json"
      }
    );

    print("RENTAL RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["data"] != null) {
      return data["data"];
    }

    return [];
  }

  /// ================= CREATE RENTAL =================
  static Future<bool> createRental({
    required int userId,
    required String startDate,
    required String endDate,
    required String pickup,
    required String destination,
    required String contactName,
    required String phone,
    required String purpose,
    required int passengerCount,
    int? busId, // 🔥 TAMBAHAN (nullable)
  }) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/rentals/store"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "user_id": userId,
        "start_date": startDate,
        "end_date": endDate,
        "pickup_location": pickup,
        "destination": destination,
        "contact_name": contactName,
        "contact_phone": phone,
        "purpose": purpose,
        "passenger_count": passengerCount,
        "bus_id": busId, // 🔥 KIRIM KE BACKEND
      }),
    );

    print("CREATE RENTAL RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    return data["status"] == true;
  }

  /// ================= CANCEL RENTAL =================
  static Future cancelRental(int id) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/cancel-rental/$id"),
      headers: {
        "Accept": "application/json"
      }
    );

    return jsonDecode(response.body);
  }

  /// ================= FINISH RENTAL =================
  static Future finish(int id) async {

    final url = Uri.parse("${ApiService.baseUrl}/finish-rental/$id");

    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception("Gagal finish rental");
    }
  }
}