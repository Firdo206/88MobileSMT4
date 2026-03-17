import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'ganti_password_page.dart';

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

  /// CONTROLLER EDIT NAMA
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController =
      TextEditingController(text: "");

  final TextEditingController phoneController =
      TextEditingController(text: "");

  final TextEditingController passwordController =
      TextEditingController(text: "********");

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
      emailController.text = data['data']['email'];
      phoneController.text = data['data']['phone'];
      avatar = data['data']['avatar'] ?? "";
    });
  }

  /// POPUP EDIT NAMA
  void showEditNameDialog() {

    nameController.text = name;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Center(
                  child: Column(
                    children: [

                      Image.asset(
                        'assets/images/logo.png',
                        width: 60,
                        height: 60,
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        "Ganti Nama",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Masukkan nama baru kamu",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// LABEL
                Text(
                  "Nama",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 8),

                /// INPUT
                TextField(
                  controller: nameController,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Masukkan nama baru",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.edit_outlined, color: Colors.grey[400], size: 20),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// TOMBOL
                Row(
                  children: [

                    /// BATAL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Batal",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// SIMPAN
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {

                          final prefs = await SharedPreferences.getInstance();
                          int userId = prefs.getInt("user_id") ?? 0;

                          bool success = await ProfileService.updateName(
                            userId,
                            nameController.text,
                          );

                          if(success){

                            setState(() {
                              name = nameController.text;
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Nama berhasil diupdate"),
                              ),
                            );

                          }else{

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Update gagal"),
                              ),
                            );

                          }

                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
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

  // PILIH FOTO + UPLOAD KE LARAVEL
  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {

      File imageFile = File(pickedFile.path);

      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("user_id") ?? 0;

      bool success =
          await ProfileService.uploadAvatar(userId, imageFile);

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

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload gagal"),
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

                  /// RING LUAR (PUTIH) + SHADOW
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _image != null
                          ? Image.file(
                              _image!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : avatar.isNotEmpty
                              ? Image.network(
                                  "http://192.168.1.10:8000/avatar/$avatar?${DateTime.now().millisecondsSinceEpoch}",
                                  key: ValueKey(avatar),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      "https://randomuser.me/api/portraits/women/44.jpg",
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.network(
                                  "https://randomuser.me/api/portraits/women/44.jpg",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),

                  /// TOMBOL + (HITAM)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  )

                ],
              ),
            ),

            const SizedBox(height: 10),

            /// NAMA (BISA DIKLIK)
            GestureDetector(
              onTap: showEditNameDialog,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isEmpty ? "Loading..." : name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.edit_outlined, size: 16, color: Colors.black54)
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// EMAIL
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Email"),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 15),

            /// NO TELP
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("No Telp"),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 15),

            /// PASSWORD
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Password"),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: passwordController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 10),

            /// UBAH PASSWORD
            Row(
              children: [
                const Text(
                  "Ingin mengubah password?",
                  style: TextStyle(color: Colors.grey),
                ),
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