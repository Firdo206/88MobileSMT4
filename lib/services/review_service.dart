import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'api_service.dart';

class ReviewService {

  static Future<bool> submitReview({
    required int userId,
    required String type,
    required int reviewableId,
    required int rating,
    required String comment,
    File? image,
  }) async {
    try {
      // ambil token dari shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? ''; // sesuaikan key-nya

      var uri = Uri.parse(ApiService.reviewStore);

      var request = http.MultipartRequest("POST", uri);

      // tambahkan header ini
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields["user_id"] = userId.toString();
      request.fields["reviewable_type"] = type;
      request.fields["reviewable_id"] = reviewableId.toString();
      request.fields["rating"] = rating.toString();
      request.fields["comment"] = comment;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      var response = await request.send();
      final resBody = await response.stream.bytesToString();
      print(resBody);

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print(e);
      return false;
    }
  }
}