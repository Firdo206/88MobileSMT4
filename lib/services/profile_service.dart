import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile(int id) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/profile/$id"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data profil");
    }
  }

  // TAMBAHAN: UPDATE NOMOR (FIRST TIME - TANPA OTP)
  static Future<Map<String, dynamic>> updatePhone(
    int userId,
    String phone,
  ) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/update-phone"),
      headers: {"Accept": "application/json"},
      body: {"user_id": userId.toString(), "phone": phone},
    );

    // DEBUG
    print("UPDATE PHONE STATUS: ${response.statusCode}");
    print("UPDATE PHONE BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  // UPLOAD AVATAR
  static Future<bool> uploadAvatar(int userId, File imageFile) async {
    var uri = Uri.parse("${ApiService.baseUrl}/upload-avatar");

    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();

    request.files.add(
      await http.MultipartFile.fromPath('avatar', imageFile.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // UPDATE NAMA
  static Future<bool> updateName(int userId, String name) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/update-name"),
      headers: {"Accept": "application/json"},
      body: {"user_id": userId.toString(), "name": name},
    );

    // DEBUG RESPONSE
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // UPDATE PASSWORD Baru
  static Future<bool> updatePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/update-password"),
      headers: {"Accept": "application/json"},
      body: {
        "user_id": userId.toString(),
        "old_password": oldPassword,
        "new_password": newPassword,
      },
    );

    // DEBUG RESPONSE
    print("UPDATE PASSWORD STATUS: ${response.statusCode}");
    print("UPDATE PASSWORD BODY: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['status']; 
    } else {
      return false;
    }
  }
}
