import 'package:app_88trans/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/google_auth_service.dart';
import '../../services/api_service.dart';
import '../navigation/main_page.dart';
import '../profil/input_phone_page.dart'; // 🔥 TAMBAHAN

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // 🔥 GOOGLE LOGIN + VALIDASI NOMOR
  Future loginGoogle(BuildContext context) async {
    var account = await GoogleAuthService.signIn();

    if (account != null) {
      var result = await AuthService.googleLogin(
        account.id,
        account.displayName ?? "",
        account.email,
        account.photoUrl ?? "",
      );

      if (result["status"] == true) {
        final prefs = await SharedPreferences.getInstance();

        var user = result["data"];

        prefs.setInt("user_id", user["id"]);
        prefs.setString("name", user["name"]);
        prefs.setString("email", user["email"]);

        print("Login Google berhasil");
        print("DATA USER: $user");

        // 🔥 CEK NOMOR
        if (user["phone"] == null || user["phone"] == "") {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InputPhonePage(
                userId: user["id"],
              ),
            ),
          );

        } else {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );

        }

      } else {
        print("Login gagal");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login gagal")),
        );
      }
    } else {
      print("User batal login Google");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 254, 254, 1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOMBOL MASUK (POJOK KIRI ATAS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Masuk",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// GAMBAR
            Center(
              child: Image.asset(
                "assets/images/fotologin.png",
                height: MediaQuery.of(context).size.height * 0.55,
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),

            /// BAGIAN BAWAH (BUTTON)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// BUTTON BUAT AKUN BARU
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Buat akun baru",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Or",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// GOOGLE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: () {
                        loginGoogle(context);
                      },

                      icon: Image.asset("assets/icons/Symbol.png", height: 22),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}