import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../pesanan/pesanan_page.dart';
import '../armada/armada_page.dart';
import '../profil/profil_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(),
    const PesananPage(),
    const ArmadaPage(),
    const ProfilPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,

        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Pesanan",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: "Armada",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Akun",
          ),

        ],
      ),
    );
  }
}