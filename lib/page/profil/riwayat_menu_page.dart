import 'package:flutter/material.dart';
import 'riwayat_tiket_page.dart';
import 'riwayat_bus_page.dart';
import 'riwayat_tour_page.dart';

class RiwayatMenuPage extends StatelessWidget {
  const RiwayatMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pesanan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _item(
              context,
              icon: Icons.confirmation_number,
              title: "Riwayat Tiket",
              page: const RiwayatTiketPage(),
            ),

            const SizedBox(height: 12),

            _item(
              context,
              icon: Icons.directions_bus,
              title: "Riwayat Sewa Bus",
              page: const RiwayatBusPage(),
            ),

            const SizedBox(height: 12),

            _item(
              context,
              icon: Icons.public,
              title: "Riwayat Paket Wisata",
              page: const RiwayatTourPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context,
      {required IconData icon,
      required String title,
      required Widget page}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}