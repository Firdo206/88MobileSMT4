import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/profile_service.dart';

class GantiPasswordPage extends StatefulWidget {
  const GantiPasswordPage({super.key});

  @override
  State<GantiPasswordPage> createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  bool isOldHidden = true;
  bool isNewHidden = true;
  bool isConfirmHidden = true;

  // CONTROLLER (BARU)
  final TextEditingController oldController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  // FUNCTION HANDLE UPDATE PASSWORD
  Future<void> handleChangePassword() async {

    // VALIDASI
    if (oldController.text.isEmpty ||
        newController.text.isEmpty ||
        confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    if (newController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak sama")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("user_id") ?? 0;

    bool success = await ProfileService.updatePassword(
      userId,
      oldController.text,
      newController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password berhasil diubah")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password lama salah / gagal")),
      );
    }
  }

  static const Color _primary      = Color(0xFF8B2E2E);
  static const Color _primaryLight = Color(0xFFB84545);
  static const Color _bgColor      = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Ganti Password",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Hero Banner ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Keamanan Akun",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Gunakan password yang kuat dan unik untuk melindungi akunmu.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Form Card ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Password Lama ──
                  _buildLabel(Icons.lock_outline_rounded, "Password Lama"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: oldController,
                    hint: "Masukkan password lama",
                    isHidden: isOldHidden,
                    onToggle: () => setState(() => isOldHidden = !isOldHidden),
                  ),

                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[100], height: 24),

                  // ── Password Baru ──
                  _buildLabel(Icons.lock_rounded, "Password Baru"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: newController,
                    hint: "Masukkan password baru",
                    isHidden: isNewHidden,
                    onToggle: () => setState(() => isNewHidden = !isNewHidden),
                  ),

                  const SizedBox(height: 16),

                  // ── Konfirmasi ──
                  _buildLabel(Icons.lock_clock_rounded, "Konfirmasi Password Baru"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: confirmController,
                    hint: "Ulangi password baru",
                    isHidden: isConfirmHidden,
                    onToggle: () => setState(() => isConfirmHidden = !isConfirmHidden),
                  ),
                ],
              ),
            ),

            // ─── Tips Card ───────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _primary.withOpacity(0.12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: _primary.withOpacity(0.7), size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tips: Gunakan minimal 8 karakter, kombinasikan huruf besar, huruf kecil, angka, dan simbol.",
                      style: TextStyle(
                        color: _primary.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: handleChangePassword,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text(
                    "Simpan Password Baru",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: _primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isHidden,
    required VoidCallback onToggle,
  }) =>
      TextField(
        controller: controller,
        obscureText: isHidden,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(Icons.lock_outline, size: 18, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: Colors.grey[400],
            ),
            onPressed: onToggle,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
        ),
      );
}