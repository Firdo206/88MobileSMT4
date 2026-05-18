import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/review_service.dart';

class ReviewPage extends StatefulWidget {
  final int userId;
  final int reviewableId;
  final String type;

  const ReviewPage({
    super.key,
    required this.userId,
    required this.reviewableId,
    required this.type,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int rating = 5;

  final commentController = TextEditingController();

  File? selectedImage;

  bool isLoading = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future submitReview() async {
    setState(() {
      isLoading = true;
    });

    final success = await ReviewService.submitReview(
      userId: widget.userId,
      type: widget.type,
      reviewableId: widget.reviewableId,
      rating: rating,
      comment: commentController.text,
      image: selectedImage,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Review berhasil dikirim"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengirim review"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String get _ratingLabel {
    switch (rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Bagus';
      case 5:
        return 'Luar Biasa!';
      default:
        return '';
    }
  }

  Color get _ratingColor {
    switch (rating) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF22C55E);
      case 5:
        return const Color(0xFF8B0000);
      default:
        return Colors.grey;
    }
  }

  Widget buildStar(int index) {
    final bool isSelected = index <= rating;
    return GestureDetector(
      onTap: () {
        setState(() {
          rating = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB),
          size: isSelected ? 44 : 38,
          shadows: isSelected
              ? [
                  Shadow(
                    color: const Color(0xFFFBBF24).withOpacity(0.5),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        title: const Text(
          "Beri Ulasan",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFCC2222)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rate_review_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Bagaimana pengalamanmu?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Ulasanmu sangat berarti bagi kami",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Star Rating Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => buildStar(index + 1)),
                  ),
                  const SizedBox(height: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ratingColor,
                      letterSpacing: 0.2,
                    ),
                    child: Text(_ratingLabel),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Comment Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: commentController,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: "Tulis ulasan kamu...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Image Preview
            if (selectedImage != null) ...[
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: GestureDetector(
                      onTap: () => setState(() => selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Pick Image Button
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8B0000).withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B0000).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_rounded,
                        color: Color(0xFF8B0000),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      selectedImage != null ? "Ganti Gambar" : "Pilih Gambar",
                      style: const TextStyle(
                        color: Color(0xFF8B0000),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  disabledBackgroundColor: const Color(0xFF8B0000).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFF8B0000).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Kirim Review",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
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