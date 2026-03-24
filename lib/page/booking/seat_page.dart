import 'package:flutter/material.dart';
import '../../services/seat_service.dart';
import 'passenger_page.dart';
import 'widgets/seat_item.dart';

class SeatPage extends StatefulWidget {
  final int scheduleId;
  final dynamic scheduleData; // ✅ tambah: data schedule dari SchedulePage

  const SeatPage({
    super.key,
    required this.scheduleId,
    this.scheduleData, // ✅ tambah
  });

  @override
  State<SeatPage> createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  int capacity = 0;
  List bookedSeats = [];
  List selectedSeats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSeats();
  }

  Future<void> loadSeats() async {
    final data = await SeatService.getSeatLayout(widget.scheduleId);
    setState(() {
      capacity = data['capacity'];
      bookedSeats = List<int>.from(
        data['booked_seats'].map((e) => int.parse(e.toString())),
      );
      isLoading = false;
    });
  }

  void toggleSeat(int seatNumber) {
    if (bookedSeats.contains(seatNumber)) return;
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  void goToPassengerPage() {
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kursi dulu")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PassengerPage(
          scheduleId: widget.scheduleId,
          selectedSeats: selectedSeats,
          price: widget.scheduleData?['price'],                   // ✅ tambah
          origin: widget.scheduleData?['origin'],                 // ✅ tambah
          destination: widget.scheduleData?['destination'],       // ✅ tambah
          departureDate: widget.scheduleData?['departure_date'],  // ✅ tambah
        ),
      ),
    );
  }

  /// Builds the bus seat grid with aisle in the middle (2 + 2 layout)
  Widget _buildBusLayout() {
    int totalRows = (capacity / 4).ceil();

    return Column(
      children: [
        // ── Driver label ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Supir",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Seat rows ─────────────────────────────────────
        ...List.generate(totalRows, (rowIndex) {
          int seat1 = rowIndex * 4 + 1;
          int seat2 = rowIndex * 4 + 2;
          int seat3 = rowIndex * 4 + 3;
          int seat4 = rowIndex * 4 + 4;

          Widget seatWidget(int num) {
            if (num > capacity) return const SizedBox();
            return Expanded(
              child: SeatItem(
                seatNumber: num,
                isBooked: bookedSeats.contains(num),
                isSelected: selectedSeats.contains(num),
                onTap: () => toggleSeat(num),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                seatWidget(seat1),
                const SizedBox(width: 8),
                seatWidget(seat2),
                const SizedBox(width: 20),
                seatWidget(seat3),
                const SizedBox(width: 8),
                seatWidget(seat4),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Pesan Tiket",
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
              child: CircularProgressIndicator(color: Color(0xFF7B2D2D)))
          : Column(
              children: [
                // ── Step indicator ──────────────────────────
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7B2D2D),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "1",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Pilih Kursi",
                        style: TextStyle(
                          color: Color(0xFF7B2D2D),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 10),
                          height: 1.5,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Main content ─────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pilih Nomor Kursi",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Legend ──────────────────────────
                          Row(
                            children: const [
                              _Legend(
                                color: Colors.white,
                                borderColor: Color(0xFFBDBDBD),
                                text: "Tersedia",
                              ),
                              SizedBox(width: 12),
                              _Legend(
                                color: Color(0xFF7B2D2D),
                                borderColor: Color(0xFF7B2D2D),
                                text: "Dipilih",
                              ),
                              SizedBox(width: 12),
                              _Legend(
                                color: Color(0xFFE0E0E0),
                                borderColor: Color(0xFFBDBDBD),
                                text: "Terisi",
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Bus layout ───────────────────────
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildBusLayout(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Bottom button ─────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: ElevatedButton(
                    onPressed: goToPassengerPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2D2D),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      selectedSeats.isEmpty
                          ? "Lanjutkan"
                          : "Lanjutkan (${selectedSeats.length} kursi)",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Legend widget ─────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String text;

  const _Legend({
    required this.color,
    required this.borderColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
        ),
      ],
    );
  }
}