import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class ReviewService {

  static Future<String?> submitReview({
    required int userId,
    required int bookingId,   // ← tambah
    required String type,
    required int reviewableId,
    required int rating,
    required String comment,
    File? image,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var uri = Uri.parse(ApiService.reviewStore);
      var request = http.MultipartRequest("POST", uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields["user_id"] = userId.toString();
      request.fields["booking_reference_id"] = bookingId.toString(); // ← tambah
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
      final json = jsonDecode(resBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        return json['message'] ?? 'Gagal mengirim review';
      }

    } catch (e) {
      return 'Terjadi kesalahan, coba lagi';
    }
  }
}