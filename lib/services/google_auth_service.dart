import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {

  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> signIn() async {
    try {

      await _googleSignIn.signOut(); // reset akun sebelumnya

      final account = await _googleSignIn.signIn();
      return account;

    } catch (e) {
      print(e);
      return null;
    }
  }

}