import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';

class ForgotPasswordFlowPage extends StatefulWidget {
  final String email;

  const ForgotPasswordFlowPage({super.key, required this.email});

  @override
  State<ForgotPasswordFlowPage> createState() => _ForgotPasswordFlowPageState();
}

class _ForgotPasswordFlowPageState extends State<ForgotPasswordFlowPage>
    with SingleTickerProviderStateMixin {
  int step = 1;

  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    otpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    _animController.reset();
    setState(() => step = 2);
    _animController.forward();
  }

  // STEP 1 → VERIFY OTP
  void verifyOtp() async {
    setState(() => isLoading = true);

    var res = await AuthService.verifyOtp(
      widget.email,
      otpController.text,
    );

    setState(() => isLoading = false);

    if (res["status"]) {
      _goToStep2();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["message"])));
    }
  }

  // STEP 2 → RESET PASSWORD
  void resetPassword() async {
    setState(() => isLoading = true);

    var res = await AuthService.resetPassword(
      widget.email,
      otpController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (res["status"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password berhasil diubah")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(
          step == 1 ? "Verifikasi OTP" : "Reset Password",
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E6F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  // ── LOGO + ICON ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            'assets/images/logo88.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Step indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StepDot(isActive: step >= 1, label: "1"),
                            _StepLine(isActive: step >= 2),
                            _StepDot(isActive: step >= 2, label: "2"),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          step == 1
                              ? "Masukkan kode OTP"
                              : "Buat password baru",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          step == 1
                              ? "Kode OTP telah dikirim ke email kamu"
                              : "Pastikan password mudah diingat",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8A8FAB),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── EMAIL BADGE ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1A1A2E).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Color(0xFF6C74A0),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.email,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── FORM CARD ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (step == 1) ...[
                          // ── LABEL ───────────────────────────────
                          Text(
                            "KODE OTP",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  const Color(0xFF1A1A2E).withOpacity(0.45),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── OTP INPUT ────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F6FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFE2E6F0), width: 1.5),
                            ),
                            child: TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: 10,
                              ),
                              decoration: const InputDecoration(
                                hintText: "------",
                                hintStyle: TextStyle(
                                  color: Color(0xFFB0B6CC),
                                  fontSize: 22,
                                  letterSpacing: 10,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 16),
                              ),
                            ),
                          ),
                        ],

                        if (step == 2) ...[
                          // ── LABEL ───────────────────────────────
                          Text(
                            "PASSWORD BARU",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  const Color(0xFF1A1A2E).withOpacity(0.45),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── PASSWORD INPUT ───────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F6FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFE2E6F0), width: 1.5),
                            ),
                            child: TextField(
                              controller: passwordController,
                              obscureText: isPasswordHidden,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A2E),
                              ),
                              decoration: InputDecoration(
                                hintText: "Masukkan password baru",
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B6CC),
                                  fontSize: 14,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.only(
                                      left: 14, right: 10),
                                  child: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF6C74A0),
                                    size: 20,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0, minHeight: 0),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordHidden
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF9BA3C2),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => isPasswordHidden = !isPasswordHidden),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 4),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── TOMBOL AKSI ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : (step == 1 ? verifyOtp : resetPassword),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC1F1F),
                        disabledBackgroundColor:
                            const Color(0xFFCC1F1F).withOpacity(0.6),
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
                          : Text(
                              step == 1 ? "Verifikasi OTP" : "Simpan Password",
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── BATAL ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 46,
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
          ),
        ),
      ),
    );
  }
}

// ── STEP DOT WIDGET ────────────────────────────────────────────────────────────
class _StepDot extends StatelessWidget {
  final bool isActive;
  final String label;

  const _StepDot({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFCC1F1F) : const Color(0xFFE2E6F0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFFBEB8B0),
          ),
        ),
      ),
    );
  }
}

// ── STEP LINE WIDGET ───────────────────────────────────────────────────────────
class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFCC1F1F) : const Color(0xFFE2E6F0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}