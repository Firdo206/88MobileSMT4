import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import 'booking_summary_page.dart';

class BookingFormPage extends StatefulWidget {
  final dynamic data;

  const BookingFormPage({super.key, required this.data});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  DateTime? selectedDate;
  final TextEditingController jumlahController = TextEditingController(text: "1");
  final TextEditingController catatanController = TextEditingController();

  /// FORMAT DATE
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  /// PICK DATE
  Future pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,

      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lengkapi data perjalanan anda",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            /// CARD FORM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TANGGAL
                  const Text("Tanggal Keberangkatan*"),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate == null
                                ? "dd/mm/yy"
                                : formatDate(selectedDate!),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// JUMLAH
                  const Text("Jumlah Peserta(Orang)*"),

                  const SizedBox(height: 8),

                  TextField(
                    controller: jumlahController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// CATATAN
                  const Text("Alamat Penjemputan/catatan"),

                  const SizedBox(height: 8),

                  TextField(
                    controller: catatanController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          "Misal: Jemput di hotel Aston Seminyak",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// BUTTON LANJUT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {

                  /// VALIDASI
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pilih tanggal dulu")),
                    );
                    return;
                  }

                  int jumlah = int.parse(jumlahController.text);
                  double harga = double.parse(widget.data['price_per_person'].toString());

                  double total = jumlah * harga;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingSummaryPage(
                        data: widget.data,
                        date: selectedDate!,
                        jumlah: jumlah,
                        total: total,
                        notes: catatanController.text,
                      ),
                    ),
                  );
                },
                child: const Text("Lanjutkan →"),
              ),
            )
          ],
        ),
      ),
    );
  }
}