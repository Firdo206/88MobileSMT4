import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'payment_page.dart';

class PassengerPage extends StatefulWidget {
  final int scheduleId;
  final List selectedSeats;
  final dynamic price;
  final String? origin;
  final String? destination;
  final String? departureDate;

  const PassengerPage({
    super.key,
    required this.scheduleId,
    required this.selectedSeats,
    this.price,
    this.origin,
    this.destination,
    this.departureDate,
  });

  @override
  State<PassengerPage> createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ktpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  int? userId;
  bool isLoading = false;

  static const Color _primary = Color(0xFF7B2D2D);

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("user_id");
      nameController.text = prefs.getString("name") ?? "";
      phoneController.text = prefs.getString("phone") ?? "";
    });
  }

  Future<void> bookSeats() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama wajib diisi")),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User tidak ditemukan, silakan login ulang")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/book-seats"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "user_id": userId,
          "schedule_id": widget.scheduleId,
          "seats": widget.selectedSeats,
          "passenger_name": nameController.text,
          "phone": phoneController.text,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Booking berhasil")),
        );

        // ✅ FIXED: Gabungkan data API + data dari widget
        final apiData = Map<String, dynamic>.from(data['data'] ?? {});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              bookingData: {
                ...apiData,
                'origin': apiData['origin'] ?? widget.origin,
                'destination': apiData['destination'] ?? widget.destination,
                'departure_date': apiData['departure_date'] ?? widget.departureDate,
                'passenger_name': apiData['passenger_name'] ?? nameController.text,
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking gagal: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan server")),
      );
    }
  }

  String formatPrice(price) {
    final number = double.tryParse(price.toString())?.toInt() ?? 0;
    final formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return "Rp. $formatted";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
      body: Column(
        children: [
          _StepIndicator(currentStep: 2),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card form ─────────────────────────────
                  Container(
                    width: double.infinity,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Data Penumpang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 14),

                        ...widget.selectedSeats
                            .map((seat) => _SeatBadge(seat: seat))
                            .toList(),

                        const SizedBox(height: 16),

                        _FormLabel(label: "Nama lengkap", required: true),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: nameController,
                          hint: "Sesuai KTP",
                        ),

                        const SizedBox(height: 14),

                        _FormLabel(label: "No.KTP/Identitas", required: false),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: ktpController,
                          hint: "Opsional",
                        ),

                        const SizedBox(height: 14),

                        _FormLabel(label: "No. Telepon", required: false),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: phoneController,
                          hint: "08xxxxxxxxxx",
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Ringkasan harga ───────────────────────
                  _PriceSummaryCard(
                    selectedSeats: widget.selectedSeats,
                    pricePerSeat: widget.price,
                    origin: widget.origin,
                    destination: widget.destination,
                    departureDate: widget.departureDate,
                    formatPrice: formatPrice,
                  ),
                ],
              ),
            ),
          ),

          // ── Tombol Lanjutkan ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : bookSeats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lanjutkan",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(height: 1.5, color: const Color(0xFF7B2D2D)),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF7B2D2D),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "$currentStep",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Data Penumpang",
            style: TextStyle(
              color: Color(0xFF7B2D2D),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Container(height: 1.5, color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }
}

// ── Seat Badge ────────────────────────────────────────────────────────────────
class _SeatBadge extends StatelessWidget {
  final dynamic seat;
  const _SeatBadge({required this.seat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EAEA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7B2D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              seat.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Penumpang Kursi $seat",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Kursi $seat",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Form Label ────────────────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FormLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        children: required
            ? const [
                TextSpan(
                  text: " *",
                  style: TextStyle(color: Color(0xFF7B2D2D)),
                )
              ]
            : [],
      ),
    );
  }
}

// ── Input Field ───────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;

  const _InputField({
    required this.controller,
    required this.hint,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7B2D2D)),
        ),
      ),
    );
  }
}

// ── Price Summary Card ────────────────────────────────────────────────────────
class _PriceSummaryCard extends StatelessWidget {
  final List selectedSeats;
  final dynamic pricePerSeat;
  final String? origin;
  final String? destination;
  final String? departureDate;
  final String Function(dynamic) formatPrice;

  const _PriceSummaryCard({
    required this.selectedSeats,
    required this.formatPrice,
    this.pricePerSeat,
    this.origin,
    this.destination,
    this.departureDate,
  });

  @override
  Widget build(BuildContext context) {
    final int price =
        double.tryParse(pricePerSeat?.toString() ?? '0')?.toInt() ?? 0;
    final int totalPrice = price * selectedSeats.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFD5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${selectedSeats.length} Kursi x ${formatPrice(price)}",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                origin ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, size: 14, color: Colors.black54),
              ),
              Text(
                destination ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                departureDate ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                formatPrice(totalPrice),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B2D2D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}