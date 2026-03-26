import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_color.dart';
import '../booking/booking_form_page.dart';

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

    /// 🔥 EXCLUSIONS
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

      /// 🔥 BOTTOM BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [

            /// WA BUTTON
            GestureDetector(
              onTap: () async {
                final url = Uri.parse("https://wa.me/6285234203707"); // ganti nomor
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat, color: Colors.green),
              ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingFormPage(data: data),
                    ),
                  );
                },
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

                  /// 🔥 RATING + PRICE
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text("4.8 (120 Reviews)",
                          style: TextStyle(fontSize: 12)),

                      const Spacer(),

                      Text(
                        "Rp ${data['price_per_person'] ?? '-'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// 🔥 DURASI
                  Text(
                    "${data['duration_days'] ?? 0} hari",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  /// DESCRIPTION
                  Text(
                    data['description'] ?? '-',
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

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
                        backgroundColor:
                            AppColor.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(fontSize: 12),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 2 KOLOM
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

                            ...inclusions.isNotEmpty
                                ? inclusions.map(
                                    (e) => Text("• ${e.trim()}"),
                                  )
                                : [const Text("-")],
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

                            ...exclusions.isNotEmpty
                                ? exclusions.map(
                                    (e) => Text("• ${e.trim()}"),
                                  )
                                : [const Text("-")],
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