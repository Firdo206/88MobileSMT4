import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/profile_service.dart';
import '../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'ganti_password_page.dart';
import 'widgets/edit_phone_dialog.dart';

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
  final TextEditingController passwordController =
      TextEditingController(text: "********");

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

  /// =========================
  /// POPUP EDIT NAMA
  /// =========================
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

  /// =========================
  /// UPLOAD FOTO
  /// =========================
  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      bool success = await ProfileService.uploadAvatar(userId, imageFile);

      if (success) {
        setState(() {
          _image = imageFile;
        });

        loadProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto berhasil diupdate"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Akun & keamanan",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// FOTO PROFILE
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : avatar.isNotEmpty
                              ? Image.network(
                                  "${ApiService.storageUrl}/avatar/$avatar?${DateTime.now().millisecondsSinceEpoch}",
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  "https://randomuser.me/api/portraits/women/44.jpg",
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// NAMA
            GestureDetector(
              onTap: showEditNameDialog,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isEmpty ? "Loading..." : name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.edit_outlined, size: 16)
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// EMAIL
            const Align(
                alignment: Alignment.centerLeft, child: Text("Email")),
            const SizedBox(height: 5),

            TextField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 15),

            /// NO TELP
            const Align(
                alignment: Alignment.centerLeft, child: Text("No Telp")),
            const SizedBox(height: 5),

            TextField(
              controller: phoneController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText:
                    phoneController.text.isEmpty ? "Tambah" : "Ubah",
                suffixStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => EditPhoneDialog(userId: userId),
                );

                if (result != null) {
                  loadProfile();
                }
              },
            ),

            const SizedBox(height: 15),

            /// PASSWORD
            const Align(
                alignment: Alignment.centerLeft, child: Text("Password")),
            const SizedBox(height: 5),

            TextField(
              controller: passwordController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Text("Ingin mengubah password?",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GantiPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Ubah",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}