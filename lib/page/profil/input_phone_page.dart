import 'package:app_88trans/page/navigation/main_page.dart';
import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class InputPhonePage extends StatefulWidget {
  final int userId;

  const InputPhonePage({super.key, required this.userId});

  @override
  State<InputPhonePage> createState() => _InputPhonePageState();
}

class _InputPhonePageState extends State<InputPhonePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool isValidPhone(String phone) {
    return phone.length >= 10 && phone.startsWith("08");
  }

  Future<void> savePhone() async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor wajib diisi")),
      );
      return;
    }

    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format nomor tidak valid")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ProfileService.updatePhone(widget.userId, phone);

      setState(() => isLoading = false);

      if (res['status'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal menyimpan nomor")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(
                      left: 28,
                      right: 28,
                      top: 20,
                      bottom: 28,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── LOGO ──────────────────────────────────
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'assets/images/logo88.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // ── JUDUL ─────────────────────────────────
                        const Text(
                          "Lengkapi Nomor HP",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Masukkan nomor HP aktif kamu\nuntuk melanjutkan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF8A8FAB),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 14),

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

                        const SizedBox(height: 14),

                        // ── LABEL ─────────────────────────────────
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "NOMOR HP",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E).withOpacity(0.4),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── INPUT NOMOR ───────────────────────────
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
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "08xxxxxxxxxx",
                              hintStyle: const TextStyle(
                                color: Color(0xFFB0B6CC),
                                fontSize: 15,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(
                                  left: 14,
                                  right: 10,
                                ),
                                child: const Icon(
                                  Icons.phone_android_rounded,
                                  color: Color(0xFF6C74A0),
                                  size: 22,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 4,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── TOMBOL SIMPAN ─────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : savePhone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC1F1F),
                              disabledBackgroundColor: const Color(0xFFCC1F1F)
                                  .withOpacity(0.6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Simpan",
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}