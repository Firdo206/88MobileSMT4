import 'package:flutter/material.dart';
import '../../services/refund_service.dart';

class RefundPage extends StatefulWidget {
  final Map booking;

  const RefundPage({
    super.key,
    required this.booking,
  });

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  final reasonController = TextEditingController();
  final bankController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();

  bool isLoading = false;

  Future<void> submitRefund() async {
    setState(() => isLoading = true);

    try {

      final data = await RefundService.submitRefund(
        bookingId: widget.booking["id"],
        userId: widget.booking["user_id"],
        reason: reasonController.text,
        bankName: bankController.text,
        accountNumber: accountNumberController.text,
        accountName: accountNameController.text,
      );

      if (data["success"] == true) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Refund berhasil diajukan"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);

      } else {
        throw data["message"];
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );

    }

    setState(() => isLoading = false);
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Ajukan Refund"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Aturan Refund",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text("• > 24 jam sebelum berangkat → Refund 90%"),
                  Text("• 6 - 24 jam sebelum berangkat → Refund 70%"),
                  Text("• < 6 jam sebelum berangkat → Tidak tersedia"),

                ],
              ),
            ),

            const SizedBox(height: 24),

            inputField(
              label: "Alasan Refund",
              controller: reasonController,
              maxLines: 3,
            ),

            inputField(
              label: "Nama Bank",
              controller: bankController,
            ),

            inputField(
              label: "Nomor Rekening",
              controller: accountNumberController,
            ),

            inputField(
              label: "Nama Pemilik Rekening",
              controller: accountNameController,
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : submitRefund,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Ajukan Refund"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}