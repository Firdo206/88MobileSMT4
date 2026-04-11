import 'package:flutter/material.dart';
import '../../services/schedule_service.dart';
import 'seat_page.dart';

class SchedulePage extends StatefulWidget {
  final String? origin;
  final String? destination;
  final DateTime? date;

  const SchedulePage({
    super.key,
    this.origin,
    this.destination,
    this.date,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List schedules = [];
  List filteredSchedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      final data = await ScheduleService.getSchedules();
      schedules = data;

      final now = DateTime.now();

      filteredSchedules = schedules.where((item) {
        bool matchOrigin = widget.origin == null ||
            item['origin']
                .toString()
                .toLowerCase()
                .contains(widget.origin!.toLowerCase());
        bool matchDestination = widget.destination == null ||
            item['destination']
                .toString()
                .toLowerCase()
                .contains(widget.destination!.toLowerCase());
        bool matchDate = widget.date == null ||
            item['departure_date'] ==
                widget.date.toString().substring(0, 10);

        // ── Filter jadwal yang sudah lewat ──────────────────────────────
        final depDateStr = item['departure_date']?.toString() ?? '';
        final depTimeStr = item['departure_time']?.toString() ?? '';

        bool isExpired = false;
        if (depDateStr.isNotEmpty && depTimeStr.isNotEmpty) {
          try {
            final parts = depTimeStr.split(':');
            final depDateTime = DateTime(
              int.parse(depDateStr.substring(0, 4)),
              int.parse(depDateStr.substring(5, 7)),
              int.parse(depDateStr.substring(8, 10)),
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
            isExpired = depDateTime.isBefore(now);
          } catch (_) {
            isExpired = false;
          }
        }

        return matchOrigin && matchDestination && matchDate && !isExpired;
      }).toList();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

      String formatPrice(price) {
  // ✅ Gunakan double dulu, baru convert ke int
  final number = double.tryParse(price.toString())?.toInt() ?? 0;
  final formatted = number.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return "Rp. $formatted";
}

  String formatDate(DateTime? date) {
    if (date == null) return '';
    const days = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
    ];
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          "Jadwal Bus",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7B2D2D)),
            )
          : filteredSchedules.isEmpty
              ? const Center(
                  child: Text(
                    "Tidak ada jadwal tersedia",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    // ── Header: tanggal + jumlah jadwal ──────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDate(widget.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${filteredSchedules.length} jadwal Tersedia",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Route title ───────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.origin ?? '-',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.arrow_forward,
                                color: Colors.black54, size: 20),
                          ),
                          Text(
                            widget.destination ?? '-',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Schedule list ─────────────────────────────
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        itemCount: filteredSchedules.length,
                        itemBuilder: (context, index) {
                          final item = filteredSchedules[index];
                          return _ScheduleCard(
                            item: item,
                            formatPrice: formatPrice,
                            onPilihKursi: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SeatPage(
                                    scheduleId: item['id'],
                                    scheduleData: item,
                                  )
                                  ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

// ── Schedule Card ─────────────────────────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  final dynamic item;
  final String Function(dynamic) formatPrice;
  final VoidCallback onPilihKursi;

  const _ScheduleCard({
    required this.item,
    required this.formatPrice,
    required this.onPilihKursi,
  });

  // Hitung durasi dari departure & arrival time
  String _duration(String dep, String arr) {
    try {
      final d = dep.split(':');
      final a = arr.split(':');
      int depMin = int.parse(d[0]) * 60 + int.parse(d[1]);
      int arrMin = int.parse(a[0]) * 60 + int.parse(a[1]);
      if (arrMin < depMin) arrMin += 1440; // overnight
      int diff = arrMin - depMin;
      int h = diff ~/ 60;
      int m = diff % 60;
      if (h > 0 && m > 0) return "${h}j ${m}m";
      if (h > 0) return "${h}j";
      return "${m}m";
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dep = item['departure_time']?.toString() ?? '';
    final arr = item['arrival_time']?.toString() ?? '';
    final duration = _duration(dep, arr);
    final busName = item['bus_name']?.toString() ?? '';
    final busClass = item['class']?.toString() ?? item['bus_class']?.toString() ?? '';
    final availableSeats = item['available_seats']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Time row ───────────────────────────────────
            Row(
              children: [
                Text(
                  dep.length >= 5 ? dep.substring(0, 5) : dep,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Expanded(
                  child: _DurationLine(duration: duration),
                ),
                Text(
                  arr.length >= 5 ? arr.substring(0, 5) : arr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ── Origin / Destination labels ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['origin']?.toString() ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
                Text(
                  item['destination']?.toString() ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Bus name + seats ────────────────────────────
            Row(
              children: [
                Text(
                  busName,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54),
                ),
                if (availableSeats.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$availableSeats kursi tersisa",
                    style: TextStyle(
                      fontSize: 13,
                      color: int.tryParse(availableSeats) != null &&
                              int.parse(availableSeats) <= 5
                          ? const Color(0xFF7B2D2D)
                          : Colors.black54,
                      fontWeight: int.tryParse(availableSeats) != null &&
                              int.parse(availableSeats) <= 5
                          ? FontWeight.w600
                          : FontWeight.normal,
                      decoration: int.tryParse(availableSeats) != null &&
                              int.parse(availableSeats) <= 5
                          ? TextDecoration.underline
                          : null,
                      decorationColor: const Color(0xFF7B2D2D),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // ── Class badge + price + button ────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Class badge
                if (busClass.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECD7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      busClass,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B6914),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(),

                // Price + button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Harga/kursi",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(item['price']),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2D2D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: onPilihKursi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2D2D),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Pilih Kursi",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Duration line widget ──────────────────────────────────────────────────────
class _DurationLine extends StatelessWidget {
  final String duration;
  const _DurationLine({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            duration,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Color(0xFF7B2D2D), shape: BoxShape.circle)),
              Expanded(
                child: Container(
                  height: 1.5,
                  color: const Color(0xFF7B2D2D),
                ),
              ),
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Color(0xFF7B2D2D), shape: BoxShape.circle)),
            ],
          ),
        ],
      ),
    );
  }
}