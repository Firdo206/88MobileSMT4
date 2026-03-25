import 'package:flutter/material.dart';
import '../../../utils/app_color.dart';

class PaketCard extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final VoidCallback onTap;

  const PaketCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),

          const SizedBox(height: 10),

          /// RATING (dummy sesuai figma)
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text("4.8 (120 Reviews)", style: TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 6),

          /// TITLE
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          /// PRICE
          Text(
            price,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          /// BUTTON + FAVORITE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Detail",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Icon(Icons.favorite_border, color: Colors.red)
            ],
          )
        ],
      ),
    );
  }
}