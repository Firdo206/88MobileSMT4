import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class RefundService {
  /// ================= CHECK REFUND =================
  static Future<Map<String, dynamic>> checkRefund({
    required int bookingId,
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse("${ApiService.refundCheck}/$bookingId?user_id=$userId"),
      headers: {'Accept': 'application/json'},
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
    // ← TAMBAH SEMENTARA
    print("=== SUBMIT REFUND ===");
    print("bookingId: $bookingId");
    print("userId: $userId");
    print("reason: $reason");
    print("====================");

    final response = await http.post(
      Uri.parse("${ApiService.refundSubmit}/$bookingId"),
      headers: {'Accept': 'application/json'},
      body: {
        'user_id': userId.toString(),
        'reason': reason,
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_name': accountName,
      },
    );

    // ← TAMBAH SEMENTARA
    print("=== RESPONSE ===");
    print("status: ${response.statusCode}");
    print("body: ${response.body}");
    print("================");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      final message = data["message"]?.toString() ?? "Refund gagal";
      throw message; // ← casting ke String dulu
    }
  }
}
