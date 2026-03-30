import 'package:flutter/material.dart';
import 'register_page.dart';
import '../../services/auth_service.dart';
import '../navigation/main_page.dart';
import '../../services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profil/input_phone_page.dart';
import 'forgot_password_flow_page.dart';

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
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
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
                ],
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
            MaterialPageRoute(builder: (context) => const MainPage()),
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

  /// ORGOT PASSWORD 
  Future<void> forgotPassword() async {
    final TextEditingController emailForgotController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── ICON ──────────────────────────────────
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC1F1F).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFFCC1F1F),
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 14),

                    //JUDUL 
                    const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Masukkan email kamu, kami akan\nmengirimkan kode OTP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8A8FAB),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── DIVIDER ───────────────────────────────
                    Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFFE2E6F0),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── LABEL ─────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "EMAIL",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E).withOpacity(0.45),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── INPUT EMAIL ───────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE2E6F0),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: emailForgotController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "contoh@email.com",
                          hintStyle: const TextStyle(
                            color: Color(0xFFB0B6CC),
                            fontSize: 14,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(left: 14, right: 10),
                            child: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF6C74A0),
                              size: 20,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── TOMBOL KIRIM OTP ──────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCC1F1F),
                          disabledBackgroundColor: const Color(
                            0xFFCC1F1F,
                          ).withOpacity(0.6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setDialogState(() => isSubmitting = true);

                                var res = await AuthService.forgotPassword(
                                  emailForgotController.text,
                                );

                                setDialogState(() => isSubmitting = false);

                                if (res["status"]) {
                                  final String emailToSend =
                                      emailForgotController.text;
                                  final scaffoldCtx = this.context;
                                  Navigator.pop(context);
                                  Navigator.push(
                                    scaffoldCtx,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPasswordFlowPage(
                                        email: emailToSend,
                                      ),
                                    ),
                                  );
                                } else {
                                  showPopup(
                                    "Gagal",
                                    res["message"],
                                    Icons.error,
                                    Colors.red,
                                  );
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Kirim OTP",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── BATAL ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8A8FAB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🔥 LOGIN GOOGLE
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
          prefs.setString("phone", result["data"]["phone"] ?? "");

          showPopup(
            "Login Google Berhasil",
            "Selamat datang di 88Trans",
            Icons.check_circle,
            Colors.green,
            autoClose: true,
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (result["require_phone"] == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      InputPhonePage(userId: result["data"]["id"]),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
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
                      child: Image.asset("assets/images/logo.png", height: 110),
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
                          borderSide: const BorderSide(
                            color: Color(0xFF8B0000),
                          ),
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
                          borderSide: const BorderSide(
                            color: Color(0xFF8B0000),
                          ),
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

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: forgotPassword,
                        child: const Text(
                          "Lupa Password?",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B0000),
                          ),
                        ),
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
                      icon: Image.asset("assets/icons/Symbol.png", height: 22),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.black, fontSize: 15),
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
