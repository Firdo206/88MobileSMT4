import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../booking/schedule_page.dart';
import '../promo/widgets/promo_card.dart';
import '../promo/promo_list.dart';

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
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔴 HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8B0000),
                      Color(0xFFB22222),
                      Color(0xFFF5F5F5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Cari\nDestinasi Kamu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔳 CARD FORM
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: [

                          /// KOTA ASAL
                          TextField(
                            controller: originController,
                            decoration: const InputDecoration(
                              labelText: "Kota Asal",
                              hintText: "Pilih kota asal",
                              border: UnderlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// KOTA TUJUAN
                          TextField(
                            controller: destinationController,
                            decoration: const InputDecoration(
                              labelText: "Kota Tujuan",
                              hintText: "Pilih kota tujuan",
                              border: UnderlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// DATE
                          InkWell(
                            onTap: pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
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

                          const SizedBox(height: 20),

                          /// 🔴 BUTTON
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primary.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
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
                    Expanded(child: _menuButton("Cari Tiket", true)),
                    const SizedBox(width: 10),
                    Expanded(child: _menuButton("Sewa Bus", false)),
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
                  children: [
                    const Text(
                      "Promo",
                      style:
                          TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PromoListPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Lihat semua",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 🎟️ PROMO (3 CARD LANGSUNG)
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SizedBox(width: 20),

                    SizedBox(
                      width: 260,
                      child: PromoCard(
                        title: "januaryhappy",
                        code: "Saweriaaa097275",
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: PromoCard(
                        title: "januaryhappy",
                        code: "Saweriaaa097275",
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: PromoCard(
                        title: "januaryhappy",
                        code: "Saweriaaa097275",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: active ? AppColor.primary : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}