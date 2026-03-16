import 'package:flutter/material.dart';

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pusat bantuan",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView(
        children: const [

          HelpItem(
            question: "Bagaimana memesan tiket perjalanan?",
            answer:
                "Semua tiket dapat dilihat di menu Paket wisata dan Armada, lalu klik booking pada tiket",
          ),

          HelpItem(
            question: "Metode pembayaran apa saja yang tersedia?",
            answer:
                "Metode pembayaran tersedia melalui transfer bank, e-wallet, dan pembayaran langsung.",
          ),

          HelpItem(
            question: "Bagaimana cara melihat pesanan saya?",
            answer:
                "Masuk ke menu Riwayat Pesanan untuk melihat semua pesanan yang telah dibuat.",
          ),

          HelpItem(
            question: "Bagaimana cara melihat riwayat pesanan saya?",
            answer:
                "Riwayat pesanan dapat dilihat pada menu Riwayat Pesanan di halaman akun.",
          ),

          HelpItem(
            question: "Bagaimana cara mendownload tiket saya?",
            answer:
                "Buka detail pesanan lalu tekan tombol download tiket.",
          ),

          HelpItem(
            question: "Bagaimana cara mengubah email & no saya?",
            answer:
                "Perubahan data akun dapat dilakukan pada menu Akun dan Keamanan.",
          ),

          HelpItem(
            question: "Bagaimana cara menggunakan voucher?",
            answer:
                "Masukkan kode voucher saat melakukan pembayaran tiket.",
          ),
        ],
      ),
    );
  }
}

class HelpItem extends StatelessWidget {
  final String question;
  final String answer;

  const HelpItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),

      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}