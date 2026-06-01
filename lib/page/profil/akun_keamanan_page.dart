import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/profile_service.dart';
import '../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'ganti_password_page.dart';
import 'widgets/edit_phone_dialog.dart';
import 'package:image_cropper/image_cropper.dart';

class AkunKeamananPage extends StatefulWidget {
  const AkunKeamananPage({super.key});

  @override
  State<AkunKeamananPage> createState() => _AkunKeamananPageState();
}

class _AkunKeamananPageState extends State<AkunKeamananPage> {
  String name = "";
  String avatar = "";

  File? _image;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(
    text: "********",
  );

  int userId = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id") ?? 0;

    var data = await ProfileService.getProfile(userId);

    setState(() {
      name = data['data']['name'] ?? "";
      emailController.text = data['data']['email'] ?? "";
      phoneController.text = data['data']['phone'] ?? "";
      avatar = data['data']['avatar'] ?? "";
    });
  }

  void showEditNameDialog() {
    nameController.text = name;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 60),
                const SizedBox(height: 12),
                const Text(
                  "Ganti Nama",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Masukkan nama baru kamu",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Masukkan nama",
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success = await ProfileService.updateName(
                            userId,
                            nameController.text,
                          );

                          if (success) {
                            setState(() {
                              name = nameController.text;
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Nama berhasil diupdate"),
                              ),
                            );
                          }
                        },
                        child: const Text("Simpan"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ganti Foto Profil",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _imageSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: "Kamera",
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _imageSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: "Galeri",
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

 Future<void> _pickImage(ImageSource source) async {
  final XFile? pickedFile = await _picker.pickImage(source: source);
  if (pickedFile == null) return;

  // Crop setelah pilih gambar
  final CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedFile.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Sesuaikan Foto Profil',
        toolbarColor: _primary,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: _primary,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: 'Sesuaikan Foto Profil',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ],
  );

  if (croppedFile == null) return; // user cancel crop

  File imageFile = File(croppedFile.path);
  bool success = await ProfileService.uploadAvatar(userId, imageFile);

  if (success) {
    setState(() => _image = imageFile);
    loadProfile();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Foto berhasil diupdate")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Gagal upload foto"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  // ── Inisial nama kalau belum ada foto ────────────────────────
  Widget _buildInitialAvatar() {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: const Color(0xFF6B1E1E),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static const Color _primary = Color(0xFF8B2E2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B1E1E), Color(0xFFB84545)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Avatar
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _image != null
                                    ? Image.file(_image!, fit: BoxFit.cover)
                                    : avatar.isNotEmpty
                                    ? Image.network(
                                        "${ApiService.storageUrl}/avatar/$avatar?${DateTime.now().millisecondsSinceEpoch}",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildInitialAvatar(),
                                      )
                                    : _buildInitialAvatar(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: _primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: showEditNameDialog,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name.isEmpty ? "Loading..." : name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        emailController.text.isEmpty
                            ? ""
                            : emailController.text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text(
              "Akun & Keamanan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Informasi Akun"),
                  const SizedBox(height: 10),

                  _infoCard(
                    children: [
                      _fieldTile(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: emailController.text.isEmpty
                            ? "Memuat..."
                            : emailController.text,
                        isReadOnly: true,
                      ),
                      _divider(),
                      _fieldTile(
                        icon: Icons.phone_outlined,
                        label: "No. Telepon",
                        value: phoneController.text.isEmpty
                            ? "Belum diisi"
                            : phoneController.text,
                        trailingText: phoneController.text.isEmpty
                            ? "Tambah"
                            : "Ubah",
                        onTap: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) =>
                                EditPhoneDialog(userId: userId),
                          );
                          if (result != null) loadProfile();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _sectionLabel("Keamanan"),
                  const SizedBox(height: 10),

                  _infoCard(
                    children: [
                      _fieldTile(
                        icon: Icons.lock_outline_rounded,
                        label: "Password",
                        value: "••••••••",
                        isReadOnly: true,
                        trailingText: "Ubah",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GantiPasswordPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _fieldTile({
    required IconData icon,
    required String label,
    required String value,
    bool isReadOnly = false,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isReadOnly && trailingText == null ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: _primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trailingText,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (!isReadOnly)
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }
}
