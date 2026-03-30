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

      final bookings = await BookingService.getMyBookings(userId);
      final tours = await BookingPaketService.getMyTours(userId);
      final rentals = await RentalService.getMyRentals(userId);

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

      List activeOrders = temp.where((e) {
        final status = e["data"]["status_final"];

        return [
          "pending_payment",
          "waiting_confirmation",
          "waiting_approval",
          "paid"
        ].contains(status);
      }).toList();

      setState(() {
        orders = activeOrders;
        filteredOrders = activeOrders;
        isLoading = false;
      });

    } catch (e) {
      print("ERROR LOAD: $e");
      setState(() => isLoading = false);
    }
  }

  /// ================= FILTER =================
  void applyFilter(String type){
    setState(() {
      selectedFilter = type;

      if(type == "all"){
        filteredOrders = orders;
      }else{
        filteredOrders =
            orders.where((e) => e["type"] == type).toList();
      }
    });
  }

  /// ================= SEARCH =================
  void applySearch(String query) {
    final q = query.toLowerCase();

    setState(() {
      filteredOrders = orders.where((e) {
        final data = e["data"];

        final code = (data["booking_code"] ??
                data["rental_code"] ??
                "")
            .toString()
            .toLowerCase();

        final name = (data["name"] ?? "").toString().toLowerCase();

        final destination = (data["destination"] ??
                data["package_name"] ??
                "")
            .toString()
            .toLowerCase();

        return code.contains(q) ||
            name.contains(q) ||
            destination.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())

            /// 🔥 EMPTY SEMUA
            : orders.isEmpty
            ? _emptyState(
                title: "Belum Ada Pesanan",
                subtitle: "Yuk mulai rencanakan perjalananmu sekarang!",
                image: "assets/images/empty_all.png",
              )

            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔥 HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Pesanan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Kelola semua pesananmu",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🔍 SEARCH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        onChanged: applySearch,
                        decoration: const InputDecoration(
                          hintText: "Cari pesanan...",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 🔥 FILTER
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        filterChip("Semua", "all"),
                        filterChip("Tiket", "ticket"),
                        filterChip("Sewa", "bus"),
                        filterChip("Paket", "tour"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 📋 LIST / EMPTY FILTER
                  Expanded(
                    child: filteredOrders.isEmpty
                        ? _buildEmptyByFilter()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.only(bottom: 20),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final item =
                                  filteredOrders[index];
                              final type = item["type"];
                              final data = item["data"];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16),
                                child: OrderCard(
                                  type: type,
                                  data: data,
                                  onTap: () async {
                                    final result =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailPesananPage(
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

  /// ================= EMPTY STATE =================
  Widget _emptyState({
    required String title,
    required String subtitle,
    required String image,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 140),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// ================= EMPTY FILTER =================
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

  /// ================= CHIP =================
  Widget filterChip(String title, String value) {
    bool isActive = selectedFilter == value;

    return GestureDetector(
      onTap: () => applyFilter(value),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF8B2E2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive
                ? const Color(0xFF8B2E2E)
                : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}