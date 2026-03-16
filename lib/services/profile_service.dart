import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ProfileService {

  static Future<Map<String, dynamic>> getProfile(int id) async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/profile/$id"),
      headers: {
        "Accept": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data profil");
    }

  }
  
  // UPLOAD AVATAR
  static Future<bool> uploadAvatar(int userId, File imageFile) async {

    var uri = Uri.parse("${ApiService.baseUrl}/upload-avatar");

    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
      ),
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
      headers: {
        "Accept": "application/json"
      },
      body: {
        "user_id": userId.toString(),
        "name": name
      },
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

}