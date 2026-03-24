import 'package:flutter/material.dart';

class SeatItem extends StatelessWidget {
  final int seatNumber;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback onTap;

  const SeatItem({
    super.key,
    required this.seatNumber,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isBooked) {
      bgColor = const Color(0xFFE0E0E0);
      borderColor = const Color(0xFFBDBDBD);
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = const Color(0xFF7B2D2D);
      borderColor = const Color(0xFF5C1E1E);
      textColor = Colors.white;
    } else {
      bgColor = Colors.white;
      borderColor = const Color(0xFFBDBDBD);
      textColor = const Color(0xFF333333);
    }

    return GestureDetector(
      onTap: isBooked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Kursi sudah terisi"),
                  duration: Duration(milliseconds: 800),
                ),
              );
            }
          : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.2),
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7B2D2D).withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: isBooked
            ? Icon(Icons.close_rounded, color: Colors.grey[500], size: 16)
            : Text(
                "$seatNumber",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}