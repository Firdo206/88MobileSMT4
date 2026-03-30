import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promo_model.dart';
import '../models/promo_model.dart';
import 'api_service.dart'; 

class PromoService {
  static Future<List<Promo>> getPromo() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/promo/active"),    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List list = data['data'];

      return list.map((e) => Promo.fromJson(e)).toList();
    } else {
      throw Exception('Gagal ambil promo');
    }
  }
}