import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'api_service.dart'; 


class NotificationService {
  
  // GET NOTIF
  static Future<List<NotificationModel>> getNotifications(int userId) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/notifications/$userId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List list = data['data']['data'];
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil notifikasi");
    }
  }

  // UNREAD COUNT
  static Future<int> getUnreadCount(int userId) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/notifications/$userId/unread-count"),
    );

    final data = jsonDecode(response.body);
    return data['count'];
  }

  // MARK AS READ
  static Future<void> markAsRead(int id) async {
    await http.post(
      Uri.parse("${ApiService.baseUrl}/notifications/$id/read"),
    );
  }

  // READ ALL
  static Future<void> markAll(int userId) async {
    await http.post(
      Uri.parse("${ApiService.baseUrl}/notifications/$userId/read-all"),
    );
  }
}