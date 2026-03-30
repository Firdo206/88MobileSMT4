import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/api_service.dart';
import '../pesanan/widgets/order_card.dart';
import '../pesanan/detail_pesanan_page.dart';

class RiwayatTiketPage extends StatefulWidget {
  const RiwayatTiketPage({super.key});

  @override
  State<RiwayatTiketPage> createState() => _RiwayatTiketPageState();
}

class _RiwayatTiketPageState extends State<RiwayatTiketPage> {

  List data = [];
  String filter = "completed";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// 🔥 FETCH DATA TIKET
  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("user_id") ?? 0;

      final url = Uri.parse(
        "${ApiService.baseUrl}/my-bookings/$userId"
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final res = json.decode(response.body);

        setState(() {
          data = res["data"];
          isLoading = false;
        });
      } else {
        throw Exception("Gagal ambil data tiket");
      }

    } catch (e) {
      print("ERROR TIKET: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 🔥 FILTER
  List get filteredData {
    return data.where((e) {
      if (filter == "all") return true;
      return e["status_final"] == filter;
    }).toList();
  }

  /// 🔥 FILTER BOTTOM SHEET
  void openFilter() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         filterItem("Selesai", "completed"),
          filterItem("Dibatalkan", "cancelled"),
          filterItem("Expired", "expired"),
        ],
      ),
    );
  }

  Widget filterItem(String title, String value) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() => filter = value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Tiket"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: openFilter,
          )
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? const Center(child: Text("Tidak ada riwayat tiket"))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return OrderCard(
                      type: "ticket",
                      data: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPesananPage(
                              data: item,
                              type: "ticket",
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}