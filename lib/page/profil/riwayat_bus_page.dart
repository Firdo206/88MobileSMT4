import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/api_service.dart';
import '../pesanan/widgets/order_card.dart';
import '../pesanan/detail_pesanan_page.dart';

class RiwayatBusPage extends StatefulWidget {
  const RiwayatBusPage({super.key});

  @override
  State<RiwayatBusPage> createState() => _RiwayatBusPageState();
}

class _RiwayatBusPageState extends State<RiwayatBusPage> {
  List data = [];
  String filter = "completed";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("user_id") ?? 0;

      final url = Uri.parse(
        "${ApiService.baseUrl}/my-rentals/$userId"
      );

      final res = await http.get(url);
      final jsonData = json.decode(res.body);

      setState(() {
        data = jsonData["data"];
        isLoading = false;
      });
    } catch (e) {
      print(e);
      isLoading = false;
    }
  }

  List get filteredData {
    return data.where((e) {
      if (filter == "all") return true;
      return e["status_final"] == filter;
    }).toList();
  }

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
        title: const Text("Riwayat Sewa Bus"),
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
              ? const Center(child: Text("Tidak ada riwayat"))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return OrderCard(
                      type: "bus",
                      data: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPesananPage(
                              data: item,
                              type: "bus",
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