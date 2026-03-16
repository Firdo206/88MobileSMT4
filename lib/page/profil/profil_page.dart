import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/profile_service.dart';
import 'pusat_bantuan_page.dart';
import '../auth/login_page.dart'; // TAMBAHAN

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String name = "";
  String email = "";

  // TAMBAHAN WARNA (TIDAK MENGUBAH YANG LAIN)
  final Color primaryColor = const Color(0xFF8B2635);
  final Color popupBackground = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("user_id") ?? 0;

    var data = await ProfileService.getProfile(userId);

    setState(() {
      name = data['data']['name'];
      email = data['data']['email'];
    });
  }

  // FUNGSI LOGOUT
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  // POPUP KONFIRMASI LOGOUT
  void confirmLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: popupBackground, // TAMBAHAN BACKGROUND
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(
                  Icons.logout,
                  size: 40,
                  color: primaryColor, // ICON WARNA APP
                ),

                const SizedBox(height: 16),

                Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, // JUDUL WARNA APP
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Apakah kamu yakin ingin keluar dari akun ini?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, // TOMBOL WARNA APP
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B2635),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      // Foto Profil
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://randomuser.me/api/portraits/women/44.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Nama dari API
                      Text(
                        name.isEmpty ? "Loading..." : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Email dari API
                      Text(
                        email.isEmpty ? "Loading..." : email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Akun dan keamanan',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16),

                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'Riwayat pesanan',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16),

                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Pusat Bantuan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PusatBantuanPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56, endIndent: 16),

                      // MENU LOGOUT
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: confirmLogout,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isLast == false ? Radius.zero : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}