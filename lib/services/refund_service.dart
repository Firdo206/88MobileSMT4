import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class RefundService {

  /// ================= CHECK REFUND =================
  static Future<Map<String, dynamic>> checkRefund({
    required int bookingId,
    required int userId,
  }) async {

    final response = await http.get(
      Uri.parse(
        "${ApiService.refundCheck}/$bookingId?user_id=$userId",
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw data["message"] ?? "Gagal check refund";
    }
  }

  /// ================= SUBMIT REFUND =================
  static Future<Map<String, dynamic>> submitRefund({
    required int bookingId,
    required int userId,
    required String reason,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {

    final response = await http.post(
      Uri.parse(
        "${ApiService.refundStore}/$bookingId",
      ),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'user_id': userId.toString(),
        'reason': reason,
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_name': accountName,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw data["message"] ?? "Refund gagal";
    }
  }
}