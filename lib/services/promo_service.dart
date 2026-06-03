import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/promo_model.dart';
import 'api_service.dart';

class PromoService {
  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static Future<List<Promo>> getPromo() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/promo/active'),
      headers: _headers,
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List list = body['data'] ?? [];
      return list.map((e) => Promo.fromJson(e)).toList();
    }

    throw Exception(body['message'] ?? 'Gagal ambil promo');
  }

  static Future<Promo> getPromoDetail(int promoId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/promo/detail'),
      headers: _headers,
      body: jsonEncode({'promo_id': promoId}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Promo.fromJson(body['data']);
    }

    throw Exception(body['message'] ?? 'Gagal ambil detail promo');
  }

  static Future<PromoApplyResult> applyPromo({
    required int promoId,
    required int userId,
    required double originalPrice,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/promo/apply'),
      headers: _headers,
      body: jsonEncode({
        'promo_id': promoId,
        'user_id': userId,
        'original_price': originalPrice,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PromoApplyResult.fromJson(body);
    }

    throw Exception(body['message'] ?? 'Promo tidak valid');
  }

  static Future<void> confirmPromo({
    required int promoId,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/promo/confirm'),
      headers: _headers,
      body: jsonEncode({'promo_id': promoId, 'user_id': userId}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal konfirmasi promo');
    }
  }

  static Future<List<Promo>> getPromoFiltered({
    String filter = '',
    String sort = '',
  }) async {
    final params = <String, String>{};
    if (filter.isNotEmpty) params['filter'] = filter;
    if (sort.isNotEmpty) params['sort'] = sort;

    final uri = Uri.parse(
      '${ApiService.baseUrl}/promos',
    ).replace(queryParameters: params);

    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List list = body['data'] ?? [];
      return list.map((e) => Promo.fromJson(e)).toList();
    }

    throw Exception(body['message'] ?? 'Gagal ambil promo');
  }

  static Future<PromoValidationResult> validatePromoCode({
    required String promoCode,
    required String targetType,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/promos/validate'),
      headers: _headers,
      body: jsonEncode({
        'promo_code': promoCode.trim().toUpperCase(),
        'target_type': targetType,
        'amount': amount,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PromoValidationResult.fromJson(body);
    }

    throw Exception(body['message'] ?? 'Gagal validasi promo');
  }
}

class PromoApplyResult {
  final bool success;
  final int promoId;
  final String title;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final double originalPrice;
  final double finalPrice;

  const PromoApplyResult({
    required this.success,
    required this.promoId,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.originalPrice,
    required this.finalPrice,
  });

  factory PromoApplyResult.fromJson(Map<String, dynamic> json) =>
      PromoApplyResult(
        success: json['success'] ?? false,
        promoId: json['promo_id'] ?? 0,
        title: json['title'] ?? '',
        discountType: json['discount_type'] ?? 'fixed',
        discountValue: (json['discount_value'] ?? 0).toDouble(),
        discountAmount: (json['discount_amount'] ?? 0).toDouble(),
        originalPrice: (json['original_price'] ?? 0).toDouble(),
        finalPrice: (json['final_price'] ?? 0).toDouble(),
      );
  String get discountLabel => discountType == 'percentage'
      ? '${discountValue.toInt()}%'
      : 'Rp ${discountAmount.toInt()}';
}

class PromoValidationResult {
  final bool isValid;
  final String message;
  final int? promoId;
  final String? title;
  final String? discountType;
  final double? discountValue;
  final double discountAmount;
  final double? finalPrice;

  const PromoValidationResult({
    required this.isValid,
    required this.message,
    this.promoId,
    this.title,
    this.discountType,
    this.discountValue,
    required this.discountAmount,
    this.finalPrice,
  });

  factory PromoValidationResult.fromJson(Map<String, dynamic> json) =>
      PromoValidationResult(
        isValid: json['valid'] ?? false,
        message: json['message'] ?? '',
        promoId: json['promo_id'],
        title: json['title'],
        discountType: json['discount_type'],
        discountValue: json['discount_value'] != null
            ? (json['discount_value']).toDouble()
            : null,
        discountAmount: (json['discount_amount'] ?? 0).toDouble(),
        finalPrice: json['final_price'] != null
            ? (json['final_price']).toDouble()
            : null,
      );

  /// Label diskon untuk UI
  String get discountLabel {
    if (!isValid || discountType == null) return '';
    return discountType == 'percentage'
        ? '${discountValue?.toInt()}%'
        : 'Rp ${discountAmount.toInt()}';
  }
}
