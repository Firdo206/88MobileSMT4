import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/promo_model.dart';
import 'payment_page.dart';

class PassengerPage extends StatefulWidget {
  final int scheduleId;
  final List selectedSeats;
  final dynamic price;
  final String? origin;
  final String? destination;
  final String? departureDate;
  final Promo? promo;

  const PassengerPage({
    super.key,
    required this.scheduleId,
    required this.selectedSeats,
    this.price,
    this.origin,
    this.destination,
    this.departureDate,
    this.promo,
  });

  @override
  State<PassengerPage> createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
  late List<TextEditingController> nameControllers;
  late List<TextEditingController> ktpControllers;
  late List<TextEditingController> phoneControllers;
  final TextEditingController _promoController = TextEditingController();

  int? userId;
  bool isLoading = false;
  bool isCheckingPromo = false;
  Promo? _appliedPromo; // promo yang berhasil divalidasi
  String? _promoError;

  static const Color _primary = Color(0xFF7B2D2D);

  double get pricePerSeat =>
      double.tryParse(widget.price?.toString() ?? '0') ?? 0;

  // Gunakan _appliedPromo jika ada, fallback ke widget.promo
  Promo? get activePromo => _appliedPromo ?? widget.promo;

  double get discountPerSeat {
    if (activePromo == null) return 0;
    if (activePromo!.discountType.trim().toLowerCase() == 'percentage') {
      return pricePerSeat * (activePromo!.discountValue / 100);
    }
    return activePromo!.discountValue;
  }

  double get finalPricePerSeat =>
      (pricePerSeat - discountPerSeat).clamp(0, double.infinity);

  double get totalFinalPrice =>
      finalPricePerSeat * widget.selectedSeats.length;

  @override
  void initState() {
    super.initState();
    nameControllers = List.generate(
        widget.selectedSeats.length, (_) => TextEditingController());
    ktpControllers = List.generate(
        widget.selectedSeats.length, (_) => TextEditingController());
    phoneControllers = List.generate(
        widget.selectedSeats.length, (_) => TextEditingController());

    // Jika sudah ada promo dari halaman sebelumnya, isi otomatis
    if (widget.promo?.promoCode != null) {
      _promoController.text = widget.promo!.promoCode!;
    }

    loadUser();
  }

  @override
  void dispose() {
    for (var c in nameControllers) c.dispose();
    for (var c in ktpControllers) c.dispose();
    for (var c in phoneControllers) c.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("user_id");
      nameControllers[0].text = prefs.getString("name") ?? "";
      phoneControllers[0].text = prefs.getString("phone") ?? "";
    });
  }

  // Validasi kode promo ke API
 Future<void> _applyPromoCode() async {
  final code = _promoController.text.trim().toUpperCase();
  if (code.isEmpty) {
    setState(() => _promoError = "Masukkan kode promo terlebih dahulu");
    return;
  }

  setState(() {
    isCheckingPromo = true;
    _promoError = null;
    _appliedPromo = null;
  });

  try {
    // Step 1: Ambil semua promo aktif, cari yang cocok dengan kode
    final listResponse = await http.get(
      Uri.parse("${ApiService.baseUrl}/promo/active"),
      headers: {"Accept": "application/json"},
    );

    print("PROMO LIST STATUS: ${listResponse.statusCode}");
    print("PROMO LIST BODY: ${listResponse.body}");

    if (listResponse.statusCode != 200) {
      setState(() => _promoError = "Gagal mengambil data promo");
      return;
    }

    final listData = jsonDecode(listResponse.body);
    final List promos = listData['data'] ?? [];

    // Cari promo by kode
    final matched = promos.firstWhere(
      (p) => (p['promo_code'] ?? '').toString().toUpperCase() == code,
      orElse: () => null,
    );

    if (matched == null) {
      setState(() => _promoError = "Kode promo tidak ditemukan");
      return;
    }

    final promoId = matched['id'];
    final originalPrice = pricePerSeat * widget.selectedSeats.length;

    // Step 2: Apply promo
    final applyResponse = await http.post(
      Uri.parse("${ApiService.baseUrl}/promo/apply"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "promo_id": promoId,
        "original_price": originalPrice,
        "user_id": userId,
      }),
    );

    print("APPLY STATUS: ${applyResponse.statusCode}");
    print("APPLY BODY: ${applyResponse.body}");

    final applyData = jsonDecode(applyResponse.body);

    if (applyResponse.statusCode == 200 && applyData['success'] == true) {
      // Buat objek Promo dari data matched
      final promo = Promo.fromJson(matched);
      setState(() {
        _appliedPromo = promo;
        _promoError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo "${promo.title}" berhasil diterapkan! Hemat ${promo.discountLabel}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _promoError = applyData['message'] ?? "Promo tidak dapat diterapkan";
        _appliedPromo = null;
      });
    }
  } catch (e) {
    print("ERROR: $e");
    setState(() => _promoError = "Terjadi kesalahan, coba lagi");
  } finally {
    setState(() => isCheckingPromo = false);
  }
}

  void _removePromo() {
    setState(() {
      _appliedPromo = null;
      _promoController.clear();
      _promoError = null;
    });
  }

  Future<void> bookSeats() async {
    for (int i = 0; i < widget.selectedSeats.length; i++) {
      if (nameControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Nama penumpang kursi ${widget.selectedSeats[i]} wajib diisi")),
        );
        return;
      }
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
      final List passengers =
          List.generate(widget.selectedSeats.length, (i) => {
                "seat": widget.selectedSeats[i],
                "passenger_name": nameControllers[i].text,
                "phone": phoneControllers[i].text,
                "ktp": ktpControllers[i].text,
              });

      final Map<String, dynamic> requestBody = {
        "user_id": userId,
        "schedule_id": widget.scheduleId,
        "seats": widget.selectedSeats,
        "passenger_name": nameControllers[0].text,
        "phone": phoneControllers[0].text,
        "passengers": passengers,
      };

      if (activePromo != null) {
        requestBody["promo_id"] = activePromo!.id;
        requestBody["promo_title"] = activePromo!.title; 
        requestBody["final_price"] = totalFinalPrice;
        requestBody["discount_amount"] = discountPerSeat * widget.selectedSeats.length;
      }

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/book-seats"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(requestBody),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (activePromo != null) {
          try {
            await http.post(
              Uri.parse("${ApiService.baseUrl}/promo/confirm"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "promo_id": activePromo!.id,
                "user_id": userId,
              }),
            );
          } catch (_) {}
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Booking berhasil")),
        );

        final apiData = Map<String, dynamic>.from(data['data'] ?? {});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              bookingData: {
                ...apiData,
                'origin': apiData['origin'] ?? widget.origin,
                'destination': apiData['destination'] ?? widget.destination,
                'departure_date':
                    apiData['departure_date'] ?? widget.departureDate,
                'passenger_name': nameControllers[0].text,
                'passengers': List.generate(
                    widget.selectedSeats.length,
                    (i) => {
                          'seat': widget.selectedSeats[i],
                          'passenger_name': nameControllers[i].text,
                          'phone': phoneControllers[i].text,
                        }),
                if (activePromo != null) 'promo_title': activePromo!.title,
                if (activePromo != null)
                  'discount_amount':
                      discountPerSeat * widget.selectedSeats.length,
                if (activePromo != null) 'final_price': totalFinalPrice,
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
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(widget.selectedSeats.length, (i) {
                    final seat = widget.selectedSeats[i];
                    final isFirst = i == 0;

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
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
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _primary,
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
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Penumpang Kursi $seat",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (isFirst)
                                    const Text(
                                      "Otomatis dari akun kamu",
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _FormLabel(label: "Nama lengkap", required: true),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: nameControllers[i],
                            hint: "Sesuai KTP",
                            readOnly: false,
                          ),
                          const SizedBox(height: 14),
                          _FormLabel(
                              label: "No.KTP/Identitas", required: false),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: ktpControllers[i],
                            hint: "Opsional",
                          ),
                          const SizedBox(height: 14),
                          _FormLabel(label: "No. Telepon", required: false),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: phoneControllers[i],
                            hint: "08xxxxxxxxxx",
                            readOnly: isFirst,
                          ),
                        ],
                      ),
                    );
                  }),

                  // ── Kolom Input Kode Promo ──────────────────────────────
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_offer_outlined,
                                color: _primary, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Kode Promo",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Jika promo sudah diterapkan
                        if (activePromo != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activePromo!.title,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Hemat ${activePromo!.discountLabel}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _removePromo,
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.red, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Input + tombol pakai
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2),
                                  decoration: InputDecoration(
                                    hintText: "Contoh: DINERY",
                                    hintStyle: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal,
                                        letterSpacing: 0),
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F7),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: _primary),
                                    ),
                                    errorText: _promoError,
                                    errorStyle: const TextStyle(
                                        fontSize: 11, color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isCheckingPromo
                                      ? null
                                      : _applyPromoCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                  ),
                                  child: isCheckingPromo
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : const Text(
                                          "Pakai",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  _PriceSummaryCard(
                    selectedSeats: widget.selectedSeats,
                    pricePerSeat: widget.price,
                    finalPricePerSeat:
                        activePromo != null ? finalPricePerSeat : null,
                    discountAmount: activePromo != null
                        ? discountPerSeat * widget.selectedSeats.length
                        : null,
                    promo: activePromo,
                    origin: widget.origin,
                    destination: widget.destination,
                    departureDate: widget.departureDate,
                    formatPrice: formatPrice,
                  ),
                ],
              ),
            ),
          ),

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
                      borderRadius: BorderRadius.circular(12)),
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
                                color: Colors.white),
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
              child: Container(height: 1.5, color: const Color(0xFF7B2D2D))),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: Color(0xFF7B2D2D), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              "$currentStep",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Data Penumpang",
            style: TextStyle(
                color: Color(0xFF7B2D2D),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          Expanded(
              child: Container(height: 1.5, color: Colors.grey.shade300)),
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
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
        children: required
            ? const [
                TextSpan(
                    text: " *", style: TextStyle(color: Color(0xFF7B2D2D)))
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
        fillColor:
            readOnly ? const Color(0xFFEEEEEE) : const Color(0xFFF7F7F7),
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
  final double? finalPricePerSeat;
  final double? discountAmount;
  final Promo? promo;
  final String? origin;
  final String? destination;
  final String? departureDate;
  final String Function(dynamic) formatPrice;

  const _PriceSummaryCard({
    required this.selectedSeats,
    required this.formatPrice,
    this.pricePerSeat,
    this.finalPricePerSeat,
    this.discountAmount,
    this.promo,
    this.origin,
    this.destination,
    this.departureDate,
  });

  @override
  Widget build(BuildContext context) {
    final int price =
        double.tryParse(pricePerSeat?.toString() ?? '0')?.toInt() ?? 0;
    final int totalNormal = price * selectedSeats.length;
    final int totalFinal = finalPricePerSeat != null
        ? (finalPricePerSeat! * selectedSeats.length).toInt()
        : totalNormal;

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
              Text(origin ?? '-',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward,
                    size: 14, color: Colors.black54),
              ),
              Text(destination ?? '-',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(departureDate ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (promo != null)
                    Text(
                      formatPrice(totalNormal),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (discountAmount != null)
                    Text(
                      '- ${formatPrice(discountAmount!.toInt())}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.green),
                    ),
                  Text(
                    formatPrice(totalFinal),
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
        ],
      ),
    );
  }
}