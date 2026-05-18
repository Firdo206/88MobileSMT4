import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

class NotificationService {
  static Future<void> saveFcmToken(int userId, {String? token}) async {
  try {
    token ??= await FirebaseMessaging.instance.getToken();

    if (token == null) {
      print("TOKEN NULL, GAGAL KIRIM");
      return;
    }

    print("KIRIM TOKEN KE SERVER: $token");

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/save-fcm-token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "fcm_token": token,
      }),
    );

    print("RESPONSE TOKEN: ${response.body}");
  } catch (e) {
    print("ERROR KIRIM TOKEN: $e");
  }
}
  static void listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("TOKEN REFRESH: $newToken");

      try {
      } catch (e) {
        print("ERROR REFRESH TOKEN: $e");
      }
    });
  }
}