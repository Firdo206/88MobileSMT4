import 'package:flutter/material.dart';
import '../../../utils/app_color.dart';
import 'widgets/promo_card.dart';
import '../../../services/promo_service.dart';
import '../../models/promo_model.dart';

class PromoListPage extends StatefulWidget {
  const PromoListPage({super.key});

  @override
  State<PromoListPage> createState() => _PromoListPageState();
}

class _PromoListPageState extends State<PromoListPage> {
  List<Promo> promoList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPromo();
  }

  void loadPromo() async {
    try {
      final data = await PromoService.getPromo();
      if (!mounted) return;
      setState(() {
        promoList = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR PROMO LIST: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B0000),
        title: const Text(
          "Diskon Eksklusif",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B0000),
                strokeWidth: 2.5,
              ),
            )
          : promoList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined,
                          color: Colors.grey[400], size: 48),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada diskon aktif",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: promoList.length,
                  itemBuilder: (context, index) {
                    final promo = promoList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PromoCard(
                        title: promo.title,
                        discountType: promo.discountType,
                        discountValue: promo.discountValue,
                        startTime: promo.startTime,
                        endTime: promo.endTime,
                        quota: promo.quota,
                        usedQuota: promo.usedQuota,
                        isActive: promo.isActive,
                      ),
                    );
                  },
                ),
    );
  }
}