import 'package:app_88trans/page/navigation/main_page.dart';
import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import '../dashboard/dashboard_page.dart';

class InputPhonePage extends StatefulWidget {
  final int userId;

  const InputPhonePage({super.key, required this.userId});

  @override
  State<InputPhonePage> createState() => _InputPhonePageState();
}

class _InputPhonePageState extends State<InputPhonePage> {

  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  /// 🔥 VALIDASI NOMOR
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
      onWillPop: () async => false, // ❗ gak bisa balik
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lengkapi Nomor"),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 30),

              const Text(
                "Masukkan Nomor HP",
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "08xxxxxxxxxx",
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : savePhone,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Simpan"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}