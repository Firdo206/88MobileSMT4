import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
                children: [

                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: _image != null
                          ? Image.file(
                              _image!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                          : avatar.isNotEmpty
                              ? Image.network(
                                  "http://192.168.1.10:8000/avatar/$avatar?${DateTime.now().millisecondsSinceEpoch}",
                                    key: ValueKey(avatar),  
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      "https://randomuser.me/api/portraits/women/44.jpg",
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.network(
                                  "https://randomuser.me/api/portraits/women/44.jpg",
                                  width: 90,
                                  height: 90,
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
                        color: Colors.red,
                        shape: BoxShape.circle,
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

            /// NAMA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name.isEmpty ? "Loading..." : name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.edit, size: 16, color: Colors.red)
              ],
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
                  onTap: () {},
                  child: const Text(
                    "Ubah",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}