import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_color.dart';
import '../../models/promo_model.dart';
import '../../services/api_service.dart';
import 'booking_summary_page.dart';
import 'widgets/map_picker_page.dart';

class BookingFormPage extends StatefulWidget {
  final dynamic data;
  final Promo? promo;

  const BookingFormPage({
    super.key,
    required this.data,
    this.promo,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  DateTime? selectedDate;
  final TextEditingController jumlahController = TextEditingController(text: "1");
  final TextEditingController catatanController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();

  LatLng? selectedLocation;
  String? selectedAddress;

  // 🔥 Promo state
  int? userId;
  Promo? _appliedPromo;
  String? _promoError;
  bool isCheckingPromo = false;

  // 🚌 Bus state
  List<dynamic> _busList = [];
  dynamic _selectedBus;
  bool _isLoadingBus = false;

  static const Color _primary = Color(0xFF8B2E2E);

  Promo? get activePromo => _appliedPromo ?? widget.promo;

  @override
  void initState() {
    super.initState();
    if (widget.promo?.promoCode != null) {
      _promoController.text = widget.promo!.promoCode!;
    }
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userId = prefs.getInt("user_id"));
  }

  @override
  void dispose() {
    jumlahController.dispose();
    catatanController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  Future pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B2E2E),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _selectedBus = null; // reset bus saat tanggal berubah
      });
      _fetchAvailableBuses();
    }
  }

  // 🚌 Fetch bus tersedia berdasarkan tanggal + durasi paket
  Future<void> _fetchAvailableBuses() async {
    if (selectedDate == null) return;
    setState(() {
      _isLoadingBus = true;
      _busList = [];
      _selectedBus = null;
    });

    final dateStr =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    final duration = widget.data['duration_days'] ?? 1;

    try {
      final res = await http.get(
        Uri.parse("${ApiService.baseUrl}/buses/available?date=$dateStr&duration=$duration"),
        headers: {"Accept": "application/json"},
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['status'] == true) {
        setState(() => _busList = body['data']);
      }
    } catch (e) {
      debugPrint("Gagal fetch bus: $e");
    } finally {
      setState(() => _isLoadingBus = false);
    }
  }

  void _increment() {
    int val = int.tryParse(jumlahController.text) ?? 1;
    if (val < 50) setState(() => jumlahController.text = (val + 1).toString());
  }

  void _decrement() {
    int val = int.tryParse(jumlahController.text) ?? 1;
    if (val > 1) setState(() => jumlahController.text = (val - 1).toString());
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => MapPickerPage(initialLocation: selectedLocation)),
    );
    if (result != null) {
      setState(() {
        selectedLocation = LatLng(result['lat'], result['lon']);
        selectedAddress = result['address'];
        catatanController.text = result['address'];
      });
    }
  }

  // 🔥 Apply promo
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
      final listResponse = await http.get(
        Uri.parse("${ApiService.baseUrl}/promo/active"),
        headers: {"Accept": "application/json"},
      );

      if (listResponse.statusCode != 200) {
        setState(() => _promoError = "Gagal mengambil data promo");
        return;
      }

      final listData = jsonDecode(listResponse.body);
      final List promos = listData['data'] ?? [];

      final matched = promos.firstWhere(
        (p) => (p['promo_code'] ?? '').toString().toUpperCase() == code,
        orElse: () => null,
      );

      if (matched == null) {
        setState(() => _promoError = "Kode promo tidak ditemukan");
        return;
      }

      final promoId = matched['id'];
      double harga = double.parse(widget.data['price_per_person'].toString());
      int jumlah = int.tryParse(jumlahController.text) ?? 1;
      final originalPrice = harga * jumlah;

      final applyResponse = await http.post(
        Uri.parse("${ApiService.baseUrl}/promo/apply"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "promo_id": promoId,
          "original_price": originalPrice,
          "user_id": userId,
        }),
      );

      final applyData = jsonDecode(applyResponse.body);

      if (applyResponse.statusCode == 200 && applyData['success'] == true) {
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

  // 🚌 Dialog bus tidak tersedia
  void _showBusUnavailableDialog(dynamic bus) {
    final duration = widget.data['duration_days'] ?? 1;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.directions_bus_rounded,
                    color: Colors.red.shade400, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                "Bus Tidak Tersedia",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${bus['name']} sudah dipesan pada tanggal yang dipilih hingga $duration hari ke depan.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Mengerti",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B1E1E), Color(0xFFB84545)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30, right: -30,
                    child: Container(
                      width: 150, height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20, left: -20,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24, left: 20, right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "PAKET WISATA",
                            style: TextStyle(color: Colors.white70, fontSize: 11,
                                letterSpacing: 1.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Detail Perjalanan",
                            style: TextStyle(color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("Lengkapi data perjalanan anda",
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// TANGGAL
                  _sectionCard(
                    icon: Icons.calendar_month_rounded,
                    title: "Tanggal Keberangkatan",
                    required: true,
                    child: GestureDetector(
                      onTap: pickDate,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: selectedDate != null
                              ? _primary.withOpacity(0.06)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedDate != null
                                ? _primary.withOpacity(0.4)
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event_rounded,
                                color: selectedDate != null ? _primary : Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? "Pilih tanggal keberangkatan"
                                  : formatDate(selectedDate!),
                              style: TextStyle(
                                color: selectedDate != null ? _primary : Colors.grey,
                                fontWeight: selectedDate != null
                                    ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// JUMLAH PESERTA
                  _sectionCard(
                    icon: Icons.people_alt_rounded,
                    title: "Jumlah Peserta",
                    required: true,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _decrement,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.remove_rounded, color: _primary),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: jumlahController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20,
                                fontWeight: FontWeight.bold, color: _primary),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffix: Text("orang",
                                  style: TextStyle(fontSize: 13, color: Colors.grey,
                                      fontWeight: FontWeight.normal)),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        GestureDetector(
                          onTap: _increment,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 🚌 PILIH BUS
                  _sectionCard(
                    icon: Icons.directions_bus_rounded,
                    title: "Pilih Bus",
                    required: true,
                    child: _isLoadingBus
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(
                                  color: _primary, strokeWidth: 2),
                            ),
                          )
                        : selectedDate == null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        color: Colors.grey, size: 16),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Pilih tanggal keberangkatan terlebih dahulu",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _busList.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.orange.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded,
                                            color: Colors.orange.shade600,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            "Tidak ada bus tersedia pada tanggal ini",
                                            style: TextStyle(
                                                color: Colors.orange, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: _busList.map((bus) {
                                      final bool available =
                                          bus['available'] == true;
                                      final bool isSelected =
                                          _selectedBus?['id'] == bus['id'];
                                      return GestureDetector(
                                        onTap: () {
                                          if (!available) {
                                            _showBusUnavailableDialog(bus);
                                            return;
                                          }
                                          setState(() => _selectedBus = bus);
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: !available
                                                ? Colors.grey.shade100
                                                : isSelected
                                                    ? _primary.withOpacity(0.07)
                                                    : const Color(0xFFF8F8F8),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: !available
                                                  ? Colors.grey.shade300
                                                  : isSelected
                                                      ? _primary
                                                      : Colors.grey.shade200,
                                              width: isSelected ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: !available
                                                      ? Colors.grey.shade200
                                                      : isSelected
                                                          ? _primary
                                                              .withOpacity(0.12)
                                                          : _primary
                                                              .withOpacity(0.07),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.directions_bus_rounded,
                                                  color: !available
                                                      ? Colors.grey.shade400
                                                      : _primary,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      bus['name'] ?? '-',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                        color: !available
                                                            ? Colors.grey
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      "Kapasitas: ${bus['capacity']} kursi",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: !available
                                                            ? Colors.grey.shade400
                                                            : Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!available)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .red.shade200),
                                                  ),
                                                  child: Text(
                                                    "Penuh",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.red.shade400,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                )
                                              else if (isSelected)
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: _primary,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                  ),

                  const SizedBox(height: 14),

                  /// LOKASI PENJEMPUTAN
                  _sectionCard(
                    icon: Icons.location_on_rounded,
                    title: "Lokasi Penjemputan",
                    required: false,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _openMapPicker,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: selectedLocation != null
                                  ? _primary.withOpacity(0.06)
                                  : const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedLocation != null
                                    ? _primary.withOpacity(0.4)
                                    : Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.map_rounded,
                                    color: selectedLocation != null ? _primary : Colors.grey,
                                    size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedAddress ?? "Pilih lokasi di peta",
                                    style: TextStyle(
                                      color: selectedLocation != null ? _primary : Colors.grey,
                                      fontWeight: selectedLocation != null
                                          ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                        if (selectedLocation != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 140,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: selectedLocation!,
                                  initialZoom: 15,
                                  interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.none),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app88trans',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: selectedLocation!,
                                        width: 40, height: 40,
                                        child: const Icon(Icons.location_pin,
                                            color: _primary, size: 40),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        TextField(
                          controller: catatanController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Catatan tambahan (opsional)",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFF8F8F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 🔥 CARD KODE PROMO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.local_offer_outlined,
                                  color: _primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Kode Promo",
                              style: TextStyle(fontWeight: FontWeight.w600,
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (activePromo != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activePromo!.title,
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        'Hemat ${activePromo!.discountLabel}',
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 11),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  textCapitalization: TextCapitalization.characters,
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w600, letterSpacing: 1.2),
                                  decoration: InputDecoration(
                                    hintText: "Contoh: DINERY",
                                    hintStyle: const TextStyle(
                                        fontSize: 13, color: Colors.grey,
                                        fontWeight: FontWeight.normal, letterSpacing: 0),
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F7),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
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
                                      borderSide: const BorderSide(color: _primary),
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
                                  onPressed: isCheckingPromo ? null : _applyPromoCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: isCheckingPromo
                                      ? const SizedBox(
                                          width: 18, height: 18,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text("Pakai",
                                          style: TextStyle(color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BUTTON LANJUT
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pilih tanggal dulu")),
                          );
                          return;
                        }

                        if (_selectedBus == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pilih bus terlebih dahulu")),
                          );
                          return;
                        }

                        int jumlah = int.parse(jumlahController.text);
                        double harga = double.parse(
                            widget.data['price_per_person'].toString());

                        double discount = 0;
                        if (activePromo != null) {
                          discount = activePromo!.discountType.trim().toLowerCase() == 'percent'
                              ? harga * (activePromo!.discountValue / 100)
                              : activePromo!.discountValue;
                        }
                        double hargaFinal =
                            (harga - discount).clamp(0, double.infinity);
                        double total = hargaFinal;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingSummaryPage(
                              data: widget.data,
                              date: selectedDate!,
                              jumlah: jumlah,
                              total: total,
                              notes: catatanController.text,
                              promo: activePromo,
                              busId: _selectedBus!['id'],
                              busName: _selectedBus!['name'],
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Lanjutkan",
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required bool required,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 14, color: Colors.black87)),
              if (required) ...[
                const SizedBox(width: 4),
                const Text("*",
                    style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}