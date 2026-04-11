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

  @override
  void initState() {
    super.initState();
    tours = TourService.getTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,

      appBar: AppBar(
        title: const Text("Paket Wisata"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "Search for a destination...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: tours,
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final data = snapshot.data!;

                                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];

                      return PaketCard( 
                       image: item['image'] != null && item['image'].toString().isNotEmpty
                          ? '${ApiService.storageUrl}/storage/${item['image']}'
                          : '',
                        title: item['name'] ?? '',
                        price: "Rp ${item['price_per_person']}",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaketDetailPage(data: item),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}