import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_color.dart';
import '../../models/promo_model.dart';
import '../../services/api_service.dart';
import '../../services/tour_service.dart';
import '../booking/booking_form_page.dart';

class PaketDetailPage extends StatefulWidget {
  final dynamic data;
  final Promo? promo;

  const PaketDetailPage({super.key, required this.data, this.promo});

  @override
  State<PaketDetailPage> createState() => _PaketDetailPageState();
}

class _PaketDetailPageState extends State<PaketDetailPage> {
  late dynamic data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    _refreshData();
  }

  Future<void> _refreshData() async {
    try {
      final fresh = await TourService.getTourDetail(data['id']);
      if (mounted) setState(() => data = fresh);
    } catch (_) {}
  }

  dynamic _getFinalPrice(dynamic originalPrice) {
    if (widget.promo == null || originalPrice == null) return originalPrice;
    final double price = double.tryParse(originalPrice.toString()) ?? 0;
    final double discount = widget.promo!.discountType == 'percentage'
        ? price * (widget.promo!.discountValue / 100)
        : widget.promo!.discountValue;
    return (price - discount).clamp(0, double.infinity).toInt();
  }

  String _getImageUrl(dynamic d) {
    if (d['image'] != null && d['image'].toString().isNotEmpty) {
      return '${ApiService.storageUrl}/storage/${d['image']}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    List<String> destinations = [];
    if (data['destinations'] != null) {
      if (data['destinations'] is List) {
        destinations = List<String>.from(data['destinations']);
      } else if (data['destinations'] is String) {
        destinations = data['destinations'].split(',');
      }
    }

    List<String> inclusions = [];
    if (data['inclusions'] != null) {
      if (data['inclusions'] is List) {
        inclusions = List<String>.from(data['inclusions']);
      } else if (data['inclusions'] is String) {
        inclusions = data['inclusions'].split(',');
      }
    }

    List<String> exclusions = [];
    if (data['exclusions'] != null) {
      if (data['exclusions'] is List) {
        exclusions = List<String>.from(data['exclusions']);
      } else if (data['exclusions'] is String) {
        exclusions = data['exclusions'].split(',');
      }
    }

    final double avgRating =
        double.tryParse(data['reviews_avg_rating']?.toString() ?? '0') ?? 0;
    final int reviewCount = data['reviews_count'] ?? 0;
    final String imageUrl = _getImageUrl(data);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EE),
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

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.07), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final url = Uri.parse("https://wa.me/6285234203707");
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFAF1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF25D366).withOpacity(0.35),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF25D366),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
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
                      builder: (_) =>
                          BookingFormPage(data: data, promo: widget.promo),
                    ),
                  );
                },
                child: const Text(
                  "Pesan Sekarang",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 300,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
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
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B0000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              reviewCount > 0
                                  ? avgRating.toStringAsFixed(1)
                                  : '0.0',
                              style: const TextStyle(
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

                  const SizedBox(height: 5),
                  Text(
                    reviewCount > 0
                        ? "$reviewCount Ulasan"
                        : "Belum ada ulasan",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),

                  const SizedBox(height: 20),

                  widget.promo != null
                      ? _buildPriceWithPromo()
                      : _buildPriceNormal(),

                  const SizedBox(height: 24),

                  _sectionTitle("Deskripsi"),
                  const SizedBox(height: 8),
                  Text(
                    data['description'] ?? '-',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      height: 1.65,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle("Destinasi"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: destinations
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B0000).withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFF8B0000,
                                ).withOpacity(0.25),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF8B0000),
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  e.trim(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B0000),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFasilitasCard(
                          title: "Termasuk",
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: const Color(0xFF2E7D32),
                          iconBg: const Color(0xFFE8F5E9),
                          prefix: "✓",
                          prefixColor: const Color(0xFF2E7D32),
                          items: inclusions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFasilitasCard(
                          title: "Opsional",
                          icon: Icons.add_circle_outline_rounded,
                          iconColor: const Color(0xFFE65100),
                          iconBg: const Color(0xFFFFF3E0),
                          prefix: "+",
                          prefixColor: const Color(0xFFE65100),
                          items: exclusions,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle("Jaminan Perjalanan"),
                  const SizedBox(height: 12),
                  _buildJaminanCard(
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFF8B0000),
                    iconBg: const Color(0xFFFBEAEA),
                    title: "Pasti Berangkat",
                    subtitle: "Garansi Keberangkatan",
                    badgeText: "Garansi",
                    badgeColor: const Color(0xFF2E7D32),
                    badgeBg: const Color(0xFFE8F5E9),
                  ),
                  const SizedBox(height: 10),
                  _buildJaminanCard(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF1565C0),
                    iconBg: const Color(0xFFE3F2FD),
                    title: "Asuransi Trip",
                    subtitle: "Perjalanan Tanpa Khawatir",
                    badgeText: "Included",
                    badgeColor: const Color(0xFF1565C0),
                    badgeBg: const Color(0xFFE3F2FD),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B0000),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ── Fasilitas card ─────────────────────────────────────────────
  Widget _buildFasilitasCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String prefix,
    required Color prefixColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.isNotEmpty
              ? items
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$prefix ",
                              style: TextStyle(
                                color: prefixColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.trim(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList()
              : [
                  const Text(
                    "-",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
        ],
      ),
    );
  }

  // ── Jaminan card ───────────────────────────────────────────────
  Widget _buildJaminanCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Harga normal ───────────────────────────────────────────────
  Widget _buildPriceNormal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B0000).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: Color(0xFF8B0000),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Harga per orang",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Rp ${data['price_per_person'] ?? '-'}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF8B0000),
            ),
          ),
        ],
      ),
    );
  }

  // ── Harga dengan promo ─────────────────────────────────────────
  Widget _buildPriceWithPromo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B0000).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF8B0000),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white70,
                  size: 15,
                ),
                const SizedBox(width: 6),
                const Text(
                  "Promo Aktif",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.promo!.discountLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.remove_circle_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Harga normal",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      "Rp ${data['price_per_person'] ?? '-'}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.grey,
                        decorationThickness: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color(0xFFEEEEEE), height: 1),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEAEA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Kamu hemat!",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color(0xFFEEEEEE), height: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B0000).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sell_outlined,
                        color: Color(0xFF8B0000),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Harga kamu /orang",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp ${_getFinalPrice(data['price_per_person'])}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Color(0xFF8B0000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
