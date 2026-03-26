import 'package:flutter/material.dart';
import '../../../utils/app_color.dart';

class PromoCard extends StatelessWidget {
  final String title;
  final String code;

  const PromoCard({
    super.key,
    required this.title,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE + DISC
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Disc 10%",
                  style: TextStyle(
                      color: Colors.white, fontSize: 11),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// CODE BOX
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.softRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(code,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),

                const Icon(Icons.copy, size: 18)
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// SYARAT
          const Text(
            "Syarat & ketentuan\n"
            "• Promo ini hanya berlaku pada bulan januari\n"
            "• Berlaku untuk semua paket wisata",
            style: TextStyle(fontSize: 11),
          ),

          const SizedBox(height: 5),

          const Text(
            "*untuk menggunakan promo ini silahkan isikan kode diatas",
            style: TextStyle(
              fontSize: 10,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}