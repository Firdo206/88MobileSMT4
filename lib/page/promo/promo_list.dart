import 'package:flutter/material.dart';
import '../../../utils/app_color.dart';
import 'widgets/promo_card.dart';

class PromoListPage extends StatelessWidget {
  const PromoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Promo", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          PromoCard(title: "januaryhappy", code: "Saweriaaa097275"),
          PromoCard(title: "januaryhappy", code: "Saweriaaa097275"),
          PromoCard(title: "januaryhappy", code: "Saweriaaa097275"),
          PromoCard(title: "januaryhappy", code: "Saweriaaa097275"),
        ],
      ),
    );
  }
}