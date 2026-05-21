import 'package:flutter/material.dart';
import '../../services/tour_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_color.dart';
import 'widgets/paket_card.dart';
import 'paket_detail_page.dart';

class PaketWisataPage extends StatefulWidget {
  const PaketWisataPage({super.key});

  @override
  State<PaketWisataPage> createState() => _PaketWisataPageState();
}

class _PaketWisataPageState extends State<PaketWisataPage> {
  late Future<List<dynamic>> tours;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allTours = [];
  List<dynamic> _filteredTours = [];

  static const Color _primary = Color(0xFF6B0000);

  @override
  void initState() {
    super.initState();
    tours = TourService.getTours();
    // Simpan data ke _allTours setelah load
    tours.then((data) {
      setState(() {
        _allTours = data;
        _filteredTours = data;
      });
    });
  }

  Future<void> _refreshTours() async {
    final newTours = TourService.getTours();
    setState(() {
      tours = newTours;
      _searchController.clear();
    });
    newTours.then((data) {
      setState(() {
        _allTours = data;
        _filteredTours = data;
      });
    });
  }

  // ✅ Filter berdasarkan nama
  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTours = _allTours;
      } else {
        _filteredTours = _allTours.where((item) {
          final name = item['name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _refreshTours,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar sama, tidak berubah
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: _primary,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30, right: -20,
                        child: Container(width: 160, height: 160,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05))),
                      ),
                      Positioned(
                        top: 40, right: 30,
                        child: Container(width: 80, height: 80,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07))),
                      ),
                      Positioned(
                        bottom: -20, left: -20,
                        child: Container(width: 120, height: 120,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.04))),
                      ),
                      Positioned(
                        bottom: 36, left: 24, right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 13),
                                  const SizedBox(width: 5),
                                  Text('Jelajahi Destinasi',
                                    style: TextStyle(color: Colors.white.withOpacity(0.9),
                                      fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text("Paket Wisata",
                              style: TextStyle(color: Colors.white, fontSize: 26,
                                fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                            const SizedBox(height: 4),
                            Text("Temukan perjalanan impianmu 🌴",
                              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: const Text("Paket Wisata",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              centerTitle: true,
            ),

            // ✅ Search bar — sekarang pakai controller + onChanged
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06),
                        blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch, // ✅ trigger filter
                    decoration: InputDecoration(
                      hintText: "Cari destinasi wisata...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF8B0000), size: 20),
                      // ✅ Tombol clear saat ada teks
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                color: Colors.grey, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // Label — tambah jumlah hasil
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Semua Paket",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                            color: Color(0xFF1A1A1A), letterSpacing: -0.3)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 32, height: 3,
                          decoration: BoxDecoration(color: _primary,
                            borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                    // ✅ Tampilkan jumlah hasil
                    if (_allTours.isNotEmpty)
                      Text(
                        "${_filteredTours.length} paket",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),
            ),

            // ✅ List paket — pakai _filteredTours, bukan FutureBuilder
            SliverToBoxAdapter(
              child: _allTours.isEmpty
                  ? FutureBuilder<List<dynamic>>(
                      future: tours,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Center(child: CircularProgressIndicator(
                              color: _primary, strokeWidth: 2.5)),
                          );
                        }
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Center(
                              child: Column(children: [
                                Container(width: 64, height: 64,
                                  decoration: BoxDecoration(
                                    color: _primary.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(20)),
                                  child: const Icon(Icons.wifi_off_rounded,
                                    size: 30, color: _primary)),
                                const SizedBox(height: 14),
                                const Text('Gagal memuat data',
                                  style: TextStyle(fontSize: 14,
                                    fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                              ]),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    )
                  : _filteredTours.isEmpty
                      // ✅ Tidak ada hasil pencarian
                      ? Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Center(
                            child: Column(children: [
                              Container(width: 64, height: 64,
                                decoration: BoxDecoration(
                                  color: _primary.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.search_off_rounded,
                                  size: 30, color: _primary)),
                              const SizedBox(height: 14),
                              Text('Tidak ada hasil untuk\n"${_searchController.text}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                              const SizedBox(height: 6),
                              Text('Coba kata kunci lain',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ]),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          itemCount: _filteredTours.length,
                          itemBuilder: (context, index) {
                            final item = _filteredTours[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: PaketCard(
                                image: item['image'] != null &&
                                    item['image'].toString().isNotEmpty
                                    ? '${ApiService.storageUrl}/storage/${item['image']}'
                                    : '',
                                title: item['name'] ?? '',
                                price: "Rp ${item['price_per_person']}",
                                rating: double.tryParse(
                                  item['reviews_avg_rating']?.toString() ?? '0') ?? 0,
                                reviewCount: item['reviews_count'] ?? 0,
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                      builder: (_) => PaketDetailPage(data: item)));
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}