import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/api_service.dart';

class NotifPage extends StatefulWidget {
  final int userId;

  const NotifPage({super.key, required this.userId});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotif();
  }

  Future<void> fetchNotif() async {
    print("=== FETCH NOTIF userId: ${widget.userId} ===");

    try {
      // ✅ DEBUG: raw http langsung
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/notifications/${widget.userId}"),
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      final data = jsonDecode(response.body);
      List list = data['data']['data'];

      setState(() {
        notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  void markAsRead(int id) async {
    await NotificationService.markAsRead(id);
    fetchNotif();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await NotificationService.markAll(widget.userId);
              fetchNotif();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                return ListTile(
                  title: Text(notif.title),
                  subtitle: Text(notif.message),
                  trailing: notif.isRead
                      ? null
                      : const Icon(Icons.circle, color: Colors.red, size: 10),
                  onTap: () => markAsRead(notif.id),
                );
              },
            ),
    );
  }
}