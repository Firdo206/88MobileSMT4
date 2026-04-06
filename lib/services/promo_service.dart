import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/promo_model.dart';
import 'api_service.dart';

class PromoService {
  // ✅ Sudah ada
  static Future<List<Promo>> getPromo() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/promo/active'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List list = data['data'];
      return list.map((e) => Promo.fromJson(e)).toList();
    } else {
      throw Exception('Gagal ambil promo');
    }
  }

  // 🆕 Ambil detail target (jadwal/paket/rental)
  static Future<Map<String, dynamic>> getPromoDetail(int promoId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/promo/detail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'promo_id': promoId}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body['data'];
    throw Exception(body['message'] ?? 'Gagal ambil detail promo');
  }

  // 🆕 Validasi & hitung diskon
  static Future<Map<String, dynamic>> applyPromo({
    required int promoId,
    required int userId,
    required double originalPrice,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/promo/apply'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'promo_id':       promoId,
        'user_id':        userId,
        'original_price': originalPrice,
      }),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body;
    throw Exception(body['message'] ?? 'Promo tidak valid');
  }

  // 🆕 Confirm promo setelah transaksi berhasil
  static Future<void> confirmPromo({
    required int promoId,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/promo/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'promo_id': promoId, 'user_id': userId}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal konfirmasi promo');
    }
  }
}