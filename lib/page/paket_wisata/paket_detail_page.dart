import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_color.dart';
import '../../models/promo_model.dart';
import '../booking/booking_form_page.dart';

class PaketDetailPage extends StatelessWidget {
  final dynamic data;
  final Promo? promo; // 👈 TAMBAH

  const PaketDetailPage({
    super.key,
    required this.data,
    this.promo, // 👈 TAMBAH
  });

  // 👈 TAMBAH
  dynamic _getFinalPrice(dynamic originalPrice) {
    if (promo == null || originalPrice == null) return originalPrice;
    final double price = double.tryParse(originalPrice.toString()) ?? 0;
    final double discount = promo!.discountType == 'percent'
        ? price * (promo!.discountValue / 100)
        : promo!.discountValue;
    return (price - discount).clamp(0, double.infinity).toInt();
  }

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
      backgroundColor: const Color(0xFFF5F6FA),
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Paket Wisata",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      /// 🔥 BOTTOM BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [

            /// WA BUTTON
            GestureDetector(
              onTap: () async {
                final url = Uri.parse("https://wa.me/6285234203707");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFAF1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 22),
              ),
            ),

            const SizedBox(width: 14),

            /// PESAN BUTTON
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingFormPage(
                          data: data,
                          promo: promo, // 👈 TAMBAH
                        ),
                      ),
                    );
                  },
                child: const Text(
                  "Pesan Sekarang",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.3,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 IMAGE HERO
            Stack(
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          );
                        },
                      )
                    : Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "${data['duration_days'] ?? 0} Hari",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),

            /// 🔥 CONTENT CARD
            Container(
              margin: const EdgeInsets.only(top: 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6FA),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TITLE + RATING ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              SizedBox(width: 3),
                              Text(
                                "4.8",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7B6000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "120 Reviews",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),

                    const SizedBox(height: 16),

                    /// HARGA CARD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primary.withOpacity(0.08),
                            AppColor.primary.withOpacity(0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColor.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer_rounded, color: AppColor.primary, size: 20),
                          const SizedBox(width: 10),
                          const Text(
                            "Mulai dari",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const Spacer(),
                          // 👈 BERUBAH - tampilkan harga coret jika ada promo
                          if (promo != null) ...[
                            Text(
                              "Rp ${data['price_per_person'] ?? '-'}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Rp ${_getFinalPrice(data['price_per_person'])}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColor.primary,
                              ),
                            ),
                          ] else
                            Text(
                              "Rp ${data['price_per_person'] ?? '-'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColor.primary,
                              ),
                            ),
                          const Text(
                            " /orang",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// DESCRIPTION
                    const Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? '-',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// DESTINASI
                    const Text(
                      "Destinasi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: destinations.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColor.primary.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_rounded, color: AppColor.primary, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                e.trim(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    /// 🔥 2 KOLOM - FASILITAS & EKSTENSI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// FASILITAS
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    const Flexible(
                                      child: Text(
                                        "Fasilitas Inti",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...inclusions.isNotEmpty
                                    ? inclusions.map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("✓ ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                              Expanded(child: Text(e.trim(), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                                            ],
                                          ),
                                        ),
                                      )
                                    : [const Text("-", style: TextStyle(color: Colors.grey))],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// EKSTENSI
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add_circle_outline_rounded, color: Colors.orange, size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    const Flexible(
                                      child: Text(
                                        "Opsional",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...exclusions.isNotEmpty
                                    ? exclusions.map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("+ ", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                                              Expanded(child: Text(e.trim(), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                                            ],
                                          ),
                                        ),
                                      )
                                    : [const Text("-", style: TextStyle(color: Colors.grey))],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// 🔥 INVESTASI
                    const Text(
                      "Investasi Perjalanan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.groups_rounded, color: Colors.red, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pasti Berangkat",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Garansi Keberangkatan",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Garansi",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shield_rounded, color: Colors.blue, size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Asuransi Trip",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Perjalanan Tanpa Khawatir",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Included",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}