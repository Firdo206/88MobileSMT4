import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class RentalService {

  /// GET MY RENTALS
  static Future<List> getMyRentals(int userId) async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/my-rentals/$userId"),
      headers: {
        "Accept": "application/json"
      }
    );

    print("RENTAL RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if(data["data"] != null){
      return data["data"];
    }

    return [];
  }

  /// CANCEL RENTAL
  static Future cancelRental(int id) async {

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/cancel-rental/$id"),
      headers: {
        "Accept": "application/json"
      }
    );

    return jsonDecode(response.body);
  }

  static Future finish(int id) async {
  final url = Uri.parse("${ApiService.baseUrl}/finish-rental/$id");

  final res = await http.post(url);

  if (res.statusCode != 200) {
    throw Exception("Gagal finish rental");
  }
}

}