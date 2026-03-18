import 'package:flutter/material.dart';
import 'register_page.dart';
import '../../services/auth_service.dart';
import '../navigation/main_page.dart';
import '../../services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔥 TAMBAHAN IMPORT
import '../profil/input_phone_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// POPUP MODERN
  void showPopup(
    String title,
    String message,
    IconData icon,
    Color color, {
    bool autoClose = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),

                const SizedBox(height: 20),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                if (!autoClose) ...[
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );

    if (autoClose) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  Future<void> loginUser() async {
    try {
      var result = await AuthService.login(
        emailController.text,
        passwordController.text,
      );

      if (result['status'] == true) {
        showPopup(
          "Login Berhasil",
          "Selamat datang 👋",
          Icons.check_circle,
          Colors.green,
          autoClose: true,
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
          );
        });
      } else {
        showPopup(
          "Login Gagal",
          result['message'] ?? "Email atau password salah",
          Icons.error,
          Colors.red,
        );
      }
    } catch (e) {
      showPopup(
        "Server Error",
        "Tidak dapat terhubung ke server",
        Icons.warning,
        Colors.orange,
      );
    }
  }

  /// 🔥 LOGIN GOOGLE (SUDAH DISUPPORT INPUT NOMOR)
  Future<void> loginGoogle() async {
    try {
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

          prefs.setInt("user_id", result["data"]["id"]);
          prefs.setString("name", result["data"]["name"]);
          prefs.setString("email", result["data"]["email"]);

          showPopup(
            "Login Google Berhasil",
            "Selamat datang di 88Trans",
            Icons.check_circle,
            Colors.green,
            autoClose: true,
          );

          Future.delayed(const Duration(seconds: 1), () {

            /// 🔥 CEK NOMOR
            if (result["require_phone"] == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InputPhonePage(
                    userId: result["data"]["id"],
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                ),
              );
            }

          });
        } else {
          showPopup(
            "Login Gagal",
            result["message"] ?? "Login gagal",
            Icons.error,
            Colors.red,
          );
        }
      }
    } catch (e) {
      showPopup(
        "Login Google Gagal",
        "Terjadi kesalahan saat login",
        Icons.warning,
        Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),

                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 110,
                      ),
                    ),

                    const SizedBox(height: 60),

                    const Text(
                      "Email",
                      style: TextStyle(
                        color: Color(0xFF8B0000),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Masukkan email",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF8B0000)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8B0000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Password",
                      style: TextStyle(
                        color: Color(0xFF8B0000),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Masukkan password",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF8B0000)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8B0000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Lupa Password?",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: loginUser,
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDED),
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loginGoogle,
                      icon:
                          Image.asset("assets/icons/Symbol.png", height: 22),
                      label: const Text(
                        "Sign in with Google",
                        style:
                            TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Belum punya akun? ",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Buat akun",
                            style: TextStyle(
                              color: Color(0xFF8B0000),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}