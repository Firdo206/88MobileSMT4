import 'package:flutter/material.dart';
import '../booking/schedule_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final originController = TextEditingController();
  final destinationController = TextEditingController();

  DateTime? selectedDate;

  Future<void> pickDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.red,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// KOTA ASAL
            TextField(
              controller: originController,
              decoration: const InputDecoration(
                labelText: "Kota Asal",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            /// KOTA TUJUAN
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: "Kota Tujuan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            /// PILIH TANGGAL
            InkWell(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  selectedDate == null
                      ? "Pilih Tanggal"
                      : selectedDate.toString().substring(0,10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTON CARI JADWAL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SchedulePage(
                        origin: originController.text,
                        destination: destinationController.text,
                        date: selectedDate,
                      ),
                    ),
                  );

                },

                child: const Text(
                  "Cari Jadwal",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}