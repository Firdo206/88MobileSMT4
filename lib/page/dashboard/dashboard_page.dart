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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔴 HEADER GRADIENT
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B0000), Color(0xFFB22222)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TITLE
                    const Text(
                      "Cari\nDestinasi Kamu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔳 CARD FORM
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [

                          /// KOTA ASAL
                          TextField(
                            controller: originController,
                            decoration: const InputDecoration(
                              labelText: "Kota Asal",
                              hintText: "Pilih kota asal",
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// KOTA TUJUAN
                          TextField(
                            controller: destinationController,
                            decoration: const InputDecoration(
                              labelText: "Kota Tujuan",
                              hintText: "Pilih kota tujuan",
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// DATE
                          InkWell(
                            onTap: pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDate == null
                                        ? "Tanggal Berangkat"
                                        : selectedDate!
                                            .toString()
                                            .substring(0, 10),
                                  ),
                                  const Icon(Icons.calendar_today)
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// 🔴 BUTTON (ADA SHADOW + EFFECT)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SchedulePage(
                                    origin: originController.text,
                                    destination:
                                        destinationController.text,
                                    date: selectedDate,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.red[800],
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "Cari Jadwal",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔘 MENU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _menuButton("Cari Tiket", true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _menuButton("Sewa Bus", false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🎁 PROMO TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Promo",
                      style:
                          TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Lihat semua",
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 🎟️ PROMO LIST (DUMMY 3 CARD)
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  padding: const EdgeInsets.only(left: 20),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: const [
                          Text("januaryhappy",
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Saweriaaa097275"),
                          SizedBox(height: 5),
                          Text(
                            "Syarat & ketentuan berlaku",
                            style:
                                TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔘 MENU BUTTON STYLE
  Widget _menuButton(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.red : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}