import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String type;
  final Map data;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.type,
    required this.data,
    this.onTap,
  });

  final Color primary = const Color(0xFF8B2E2E);

  /// 🔥 STATUS FINAL DARI BACKEND
  String get statusFinal => data["status_final"] ?? "-";

  /// ================= FORMAT DATE =================
  String formatDate(String? date) {
    if (date == null) return "-";
    final dt = DateTime.tryParse(date);
    if (dt == null) return "-";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  /// ================= FORMAT RUPIAH =================
  String formatRupiah(dynamic value) {
    double number = double.tryParse(value.toString()) ?? 0;
    int intValue = number.toInt();

    String result = intValue.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = result.length - 1; i >= 0; i--) {
      buffer.write(result[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return buffer.toString().split('').reversed.join();
  }

  /// ================= STATUS =================
  Color statusColor() {
    switch (statusFinal) {
      case "pending_payment":
        return Colors.orange;
      case "waiting_confirmation":
      case "waiting_approval":
        return Colors.blue;
      case "paid":
        return Colors.green;
      case "completed":
        return Colors.grey;
      case "cancelled":
      case "rejected":
        return Colors.red;
      case "expired":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String statusText() {
    switch (statusFinal) {
      case "pending_payment":
        return "Belum Bayar";
      case "waiting_confirmation":
      case "waiting_approval":
        return "Tertunda";
      case "paid":
        return "Lunas";
      case "completed":
        return "Selesai";
      case "cancelled":
        return "Dibatalkan";
      case "rejected":
        return "Ditolak";
      case "expired":
        return "Kadaluarsa";
      default:
        return "-";
    }
  }

  /// ================= TITLE =================
  String getTitle() {
    if (type == "ticket") {
      return "${data["origin"]} → ${data["destination"]}";
    }
    if (type == "bus") {
      return "${data["pickup_location"]} → ${data["destination"]}";
    }
    return data["package_name"] ?? "Paket Wisata";
  }

  /// ================= DETAIL =================
  Widget buildDetailContent() {
    if (type == "ticket") {
      return Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            formatDate(data["departure_date"]),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      );
    }

    if (type == "bus") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                "${formatDate(data["start_date"])} - ${formatDate(data["end_date"])}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.event, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                "${data["duration_days"] ?? 0} Hari",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      );
    }

    /// TOUR
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              formatDate(data["travel_date"]),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.people, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              "${data["passenger_count"] ?? 0} Orang",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: CustomPaint(
          painter: TicketPainter(primary),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data["booking_code"] ??
                          data["rental_code"] ??
                          "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText(),
                        style: TextStyle(
                          color: statusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  getTitle(),
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 8),

                buildDetailContent(),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${formatRupiah(data["total_price"])}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Detail →",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= PAINTER =================
class TicketPainter extends CustomPainter {
  final Color color;

  TicketPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {

    final fill = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          color.withOpacity(0.85),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final border = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Path path = Path();

    double r = 20;

    path.moveTo(r, 0);

    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);

    /// RIGHT CUT
    path.lineTo(size.width, size.height * 0.25);
    path.arcToPoint(
      Offset(size.width, size.height * 0.45),
      radius: const Radius.circular(18),
      clockwise: false,
    );

    path.lineTo(size.width, size.height * 0.55);
    path.arcToPoint(
      Offset(size.width, size.height * 0.75),
      radius: const Radius.circular(18),
      clockwise: false,
    );

    /// BOTTOM
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(
        size.width, size.height, size.width - r, size.height);

    path.lineTo(r, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - r);

    /// LEFT CUT
    path.lineTo(0, size.height * 0.75);
    path.arcToPoint(
      Offset(0, size.height * 0.55),
      radius: const Radius.circular(18),
      clockwise: false,
    );

    path.lineTo(0, size.height * 0.45);
    path.arcToPoint(
      Offset(0, size.height * 0.25),
      radius: const Radius.circular(18),
      clockwise: false,
    );

    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);

    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}