import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/booking_service.dart';
import '../../services/booking_paket_service.dart';
import '../../services/rental_service.dart';
import '../pesanan/detail_pesanan_page.dart';
import 'widgets/order_card.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {

  List orders = [];
  List filteredOrders = [];

  bool isLoading = true;
  String selectedFilter = "all";

  static const Color _primary = Color(0xFF8B2E2E);
  static const Color _primaryLight = Color(0xFFB84545);

  @override
  void initState() {
    super.initState();
    loadAllOrders();
  }

  /// ================= LOAD DATA =================
  Future loadAllOrders() async {
    try {
      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("user_id") ?? 0;

      print("=== USER ID: $userId ===");

      final bookings = await BookingService.getMyBookings(userId);
      print("=== BOOKINGS DONE: ${bookings?.length} ===");

      final tours = await BookingPaketService.getMyTours(userId);
      print("=== TOURS DONE: ${tours?.length} ===");
      print("=== TOURS DATA: $tours ===");

      final rentals = await RentalService.getMyRentals(userId);
      print("=== RENTALS DONE: ${rentals?.length} ===");

      List temp = [];

      for (var b in bookings ?? []) {
        temp.add({"type": "ticket", "data": b});
      }
      for (var t in tours ?? []) {
        temp.add({"type": "tour", "data": t});
      }
      for (var r in rentals ?? []) {
        temp.add({"type": "bus", "data": r});
      }

      for (var item in temp) {
        print("STATUS_FINAL: ${item["data"]["status_final"]} | TYPE: ${item["type"]}");
      }

      List activeOrders = temp.where((e) {
        final status = e["data"]["status_final"];
        return [
          "pending_payment",
          "waiting_confirmation",
          "waiting_approval",
          "paid"
        ].contains(status);
      }).toList();

      print("=== ACTIVE ORDERS: ${activeOrders.length} ===");

      setState(() {
        orders = activeOrders;
        filteredOrders = activeOrders;
        isLoading = false;
      });

    } catch (e, stack) {
      print("ERROR LOAD: $e");
      print("STACK: $stack");
      setState(() => isLoading = false);
    }
  }

  /// ================= FILTER =================
  void applyFilter(String type) {
    setState(() {
      selectedFilter = type;
      if (type == "all") {
        filteredOrders = orders;
      } else {
        filteredOrders = orders.where((e) => e["type"] == type).toList();
      }
    });
  }

  /// ================= SEARCH =================
  void applySearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredOrders = orders.where((e) {
        final data = e["data"];
        final code = (data["booking_code"] ?? data["rental_code"] ?? "").toString().toLowerCase();
        final name = (data["name"] ?? "").toString().toLowerCase();
        final destination = (data["destination"] ?? data["package_name"] ?? "").toString().toLowerCase();
        return code.contains(q) || name.contains(q) || destination.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _primary),
              )
            : orders.isEmpty
                ? _emptyState(
                    title: "Belum Ada Pesanan",
                    subtitle: "Yuk mulai rencanakan perjalananmu sekarang!",
                    image: "assets/images/empty_all.png",
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// ===== HEADER =====
                      _buildHeader(),

                      /// ===== SEARCH =====
                      _buildSearch(),

                      const SizedBox(height: 14),

                      /// ===== FILTER CHIPS =====
                      _buildFilterRow(),

                      const SizedBox(height: 14),

                      /// ===== COUNT BADGE =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              "${filteredOrders.length} Pesanan",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            if (selectedFilter != "all")
                              GestureDetector(
                                onTap: () => applyFilter("all"),
                                child: const Text(
                                  "Lihat Semua",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// ===== LIST / EMPTY FILTER =====
                      Expanded(
                        child: filteredOrders.isEmpty
                            ? _buildEmptyByFilter()
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final item = filteredOrders[index];
                                  final type = item["type"];
                                  final data = item["data"];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    child: OrderCard(
                                      type: type,
                                      data: data,
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetailPesananPage(
                                              data: data,
                                              type: type,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          loadAllOrders();
                                        }
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

  /// ===== HEADER WIDGET =====
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Pesanan Saya",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Kelola semua pesananmu di sini",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: loadAllOrders,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: _primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== SEARCH WIDGET =====
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: applySearch,
          decoration: InputDecoration(
            hintText: "Cari kode, nama, atau tujuan...",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  /// ===== FILTER ROW =====
  Widget _buildFilterRow() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _filterChip("Semua", "all", Icons.apps_rounded),
          _filterChip("Tiket", "ticket", Icons.confirmation_number_outlined),
          _filterChip("Sewa Bus", "bus", Icons.directions_bus_rounded),
          _filterChip("Paket Wisata", "tour", Icons.tour_outlined),
        ],
      ),
    );
  }

  /// ===== EMPTY STATE =====
  Widget _emptyState({
    required String title,
    required String subtitle,
    required String image,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Image.asset(image, height: 120),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// ===== EMPTY BY FILTER =====
  Widget _buildEmptyByFilter() {
    if (selectedFilter == "ticket") {
      return _emptyState(
        title: "Belum Ada Tiket",
        subtitle: "Kamu belum memesan tiket bus",
        image: "assets/images/empty_ticket.png",
      );
    }
    if (selectedFilter == "bus") {
      return _emptyState(
        title: "Belum Ada Sewa Bus",
        subtitle: "Belum ada penyewaan bus",
        image: "assets/images/empty_bus.png",
      );
    }
    if (selectedFilter == "tour") {
      return _emptyState(
        title: "Belum Ada Paket Wisata",
        subtitle: "Ayo mulai liburan seru!",
        image: "assets/images/empty_tour.png",
      );
    }
    return _emptyState(
      title: "Tidak Ditemukan",
      subtitle: "Coba kata kunci lain ya",
      image: "assets/images/empty_search.png",
    );
  }

  /// ===== FILTER CHIP =====
  Widget _filterChip(String title, String value, IconData icon) {
    final bool isActive = selectedFilter == value;

    return GestureDetector(
      onTap: () => applyFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? _primary : Colors.grey.shade300,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}