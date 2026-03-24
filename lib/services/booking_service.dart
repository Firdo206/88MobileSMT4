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

}