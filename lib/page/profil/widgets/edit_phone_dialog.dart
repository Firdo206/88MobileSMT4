import 'package:flutter/material.dart';
import '../../../services/otp_service.dart';

class EditPhoneDialog extends StatefulWidget {
  final int userId;

  const EditPhoneDialog({
    super.key,
    required this.userId,
  });

  @override
  State<EditPhoneDialog> createState() => _EditPhoneDialogState();
}

class _EditPhoneDialogState extends State<EditPhoneDialog> {
  int step = 1;

  final TextEditingController otpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  /// =========================
  /// KIRIM OTP
  /// =========================
  Future<void> sendOtp() async {
    setState(() => isLoading = true);

    final result = await OtpService.sendOtp(widget.userId);

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
  }

  /// =========================
  /// STEP 1 - VERIFIKASI OTP
  /// =========================
  void checkOtp() {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP tidak boleh kosong")),
      );
      return;
    }

    setState(() {
      step = 2;
    });
  }

  /// =========================
  /// STEP 2 - UPDATE NOMOR
  /// =========================
  Future<void> updatePhone() async {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor tidak boleh kosong")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await OtpService.verifyOtp(
      widget.userId,
      otpController.text,
      phoneController.text,
    );

    setState(() => isLoading = false);

    if (result['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );

      Navigator.pop(context, phoneController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  @override
  Widget build(BuildContext context) {
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

            Text(
              step == 1 ? "Verifikasi OTP" : "Masukkan Nomor Baru",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              step == 1
                  ? "Masukkan kode OTP yang dikirim"
                  : "Masukkan nomor telepon baru",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// STEP 1 OTP
            if (step == 1)
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Masukkan kode OTP",
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

            /// STEP 2 NOMOR
            if (step == 2)
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "08xxxxxxxxxx",
                  prefixIcon: const Icon(Icons.phone),
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
                    onPressed: isLoading
                        ? null
                        : step == 1
                            ? checkOtp
                            : updatePhone,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(step == 1 ? "Verifikasi" : "Simpan"),
                  ),
                ),
              ],
            ),

            /// RESEND OTP
            if (step == 1)
              TextButton(
                onPressed: isLoading ? null : sendOtp,
                child: const Text("Kirim ulang kode"),
              ),
          ],
        ),
      ),
    );
  }
}