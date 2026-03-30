import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../pesanan/pesanan_page.dart';
import '../paket_wisata/paket_wisata_page.dart';
import '../profil/profil_page.dart';
import '../profil/input_phone_page.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    // 🔥 FIX: pindah ke dalam build() biar PesananPage rebuild setiap MainPage rebuild
    final List<Widget> pages = [
      const DashboardPage(),
      const PaketWisataPage(),
      const PesananPage(),
      const ProfilPage(),
    ];

    return Scaffold(

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,

        selectedItemColor: const Color(0xFF1A1A2E),
        unselectedItemColor: const Color(0xFFBEB8B0),

        backgroundColor: Colors.white,
        elevation: 12,
        type: BottomNavigationBarType.fixed,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: "Beranda",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore_outlined),
            activeIcon: Icon(Icons.travel_explore),
            label: "Paket Wisata",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number_rounded),
            label: "Pesanan",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: "Akun",
          ),

        ],
      ),
    );
  }
}