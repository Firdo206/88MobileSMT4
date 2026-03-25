import 'package:flutter/material.dart';
import '../../utils/app_color.dart';

class PaketDetailPage extends StatelessWidget {
  final dynamic data;

  const PaketDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    /// 🔥 DESTINATIONS
    List<String> destinations = [];
    if (data['destinations'] != null) {
      if (data['destinations'] is List) {
        destinations = List<String>.from(data['destinations']);
      } else if (data['destinations'] is String) {
        destinations = data['destinations'].split(',');
      }
    }

    /// 🔥 INCLUSIONS
    List<String> inclusions = [];
    if (data['inclusions'] != null) {
      if (data['inclusions'] is List) {
        inclusions = List<String>.from(data['inclusions']);
      } else if (data['inclusions'] is String) {
        inclusions = data['inclusions'].split(',');
      }
    }

    /// 🔥 EXCLUSIONS (EKSTENSI)
    List<String> exclusions = [];
    if (data['exclusions'] != null) {
      if (data['exclusions'] is List) {
        exclusions = List<String>.from(data['exclusions']);
      } else if (data['exclusions'] is String) {
        exclusions = data['exclusions'].split(',');
      }
    }

    String imageUrl = data['image_url'] ?? '';

    return Scaffold(
      backgroundColor: AppColor.background,

      appBar: AppBar(
        title: const Text("Paket Wisata"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// 🔥 BOTTOM BAR (WA + PESAN)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [

            /// WA BUTTON
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat, color: Colors.green),
            ),

            const SizedBox(width: 12),

            /// PESAN BUTTON
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
                child: const Text("Pesan"),
              ),
            )
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 IMAGE
            Stack(
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          );
                        },
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),

                Positioned(
                  right: 16,
                  bottom: 16,
                  child: CircleAvatar(
                    backgroundColor: AppColor.primary,
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                )
              ],
            ),

            /// 🔥 CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// DESCRIPTION
                  Text(
                    data['description'] ?? '-',
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  /// DESTINASI
                  const Text(
                    "Destinasi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: destinations.map((e) {
                      return Chip(
                        label: Text(e.trim()),
                        backgroundColor: const Color(0xFFF3E5E5), // warna figma
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 2 KOLOM (FASILITAS + EKSTENSI)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// FASILITAS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Fasilitas Inti",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            ...inclusions.map(
                              (e) => Text("• ${e.trim()}"),
                            ),
                          ],
                        ),
                      ),

                      /// EKSTENSI
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ekstensi/opsional",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            ...exclusions.map(
                              (e) => Text("• ${e.trim()}"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 INVESTASI (DUMMY)
                  const Text(
                    "Investasi Perjalanan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.groups, color: Colors.red),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pasti Berangkat"),
                            Text("Garansi Keberangkatan",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.shield, color: Colors.red),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Asuransi Trip"),
                            Text("Perjalanan Tanpa Khawatir",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}