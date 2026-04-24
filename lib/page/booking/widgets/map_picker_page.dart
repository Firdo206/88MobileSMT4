import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late final MapController mapController;
  final TextEditingController searchCtrl = TextEditingController();

  LatLng center = const LatLng(-8.4095, 115.1889); // default Bali
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  bool isLoadingAddress = false;
  bool isLoadingLocation = false;
  String? currentAddress;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    if (widget.initialLocation != null) {
      // Kalau sudah ada lokasi sebelumnya, langsung pakai
      center = widget.initialLocation!;
      _reverseGeocode(center);
    } else {
      // Langsung ke lokasi GPS user
      _goToMyLocation();
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  /// 📍 Ambil lokasi GPS user
  Future<void> _goToMyLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      // Cek apakah location service aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack("Aktifkan GPS terlebih dahulu");
        return;
      }

      // Cek & minta permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack("Izin lokasi ditolak");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack("Izin lokasi diblokir, buka pengaturan aplikasi");
        return;
      }

      // Ambil posisi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final myLoc = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() => center = myLoc);

      // Pindah kamera ke lokasi user
      mapController.move(myLoc, 16);

      // Reverse geocode untuk dapat nama alamat
      await _reverseGeocode(myLoc);
    } catch (e) {
      _showSnack("Gagal mendapatkan lokasi");
    } finally {
      if (mounted) setState(() => isLoadingLocation = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Cari lokasi pakai Nominatim (gratis, tanpa API key)
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isSearching = true;
      searchResults = [];
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=5&addressdetails=1',
      );

      final res = await http.get(
        url,
        headers: {'User-Agent': 'App88Trans/1.0'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          searchResults = data
              .map(
                (e) => {
                  'name': e['display_name'] as String,
                  'lat': double.parse(e['lat']),
                  'lon': double.parse(e['lon']),
                },
              )
              .toList();
        });
      }
    } catch (_) {
      // handle error diam-diam
    } finally {
      setState(() => isSearching = false);
    }
  }

  /// Reverse geocode: koordinat → nama alamat
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => isLoadingAddress = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${point.latitude}&lon=${point.longitude}&format=json',
      );

      final res = await http.get(
        url,
        headers: {'User-Agent': 'App88Trans/1.0'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => currentAddress = data['display_name'] as String?);
      }
    } catch (_) {
      setState(() => currentAddress = null);
    } finally {
      setState(() => isLoadingAddress = false);
    }
  }

  void _onMapTap(TapPosition tapPos, LatLng point) {
    setState(() {
      center = point;
      searchResults = [];
    });
    _reverseGeocode(point);
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final loc = LatLng(result['lat'], result['lon']);
    setState(() {
      center = loc;
      currentAddress = result['name'];
      searchResults = [];
      searchCtrl.clear();
    });
    mapController.move(loc, 15);
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': center.latitude,
      'lon': center.longitude,
      'address':
          currentAddress ??
          '${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F0),
      appBar: AppBar(
        title: const Text(
          "Pilih Lokasi Penjemputan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF8B2E2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// 🗺️ MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app88trans',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_pin,
                      color: Color(0xFF8B2E2E),
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// 🔍 SEARCH BAR + RESULTS
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    onSubmitted: _search,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Cari lokasi penjemputan...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF8B2E2E),
                      ),
                      suffixIcon: isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF8B2E2E),
                                ),
                              ),
                            )
                          : searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                searchCtrl.clear();
                                setState(() => searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 4,
                      ),
                    ),
                  ),
                ),

                // Dropdown hasil search
                if (searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: searchResults.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 0, color: Colors.grey.shade100),
                        itemBuilder: (_, i) => ListTile(
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B2E2E).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF8B2E2E),
                              size: 16,
                            ),
                          ),
                          title: Text(
                            searchResults[i]['name'],
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectSearchResult(searchResults[i]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// 💡 HINT TAP
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: currentAddress == null && !isLoadingLocation
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Tap peta untuk pilih lokasi",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),

          /// ⏳ LOADING OVERLAY saat ambil GPS
          if (isLoadingLocation)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Mendapatkan lokasi Anda...",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// 📍 TOMBOL "LOKASI SAYA"
          Positioned(
            bottom: 200,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'myLocation',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: isLoadingLocation ? null : _goToMyLocation,
              child: isLoadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF8B2E2E),
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF8B2E2E),
                      size: 20,
                    ),
            ),
          ),

          /// ✅ BOTTOM CONFIRM PANEL
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Lokasi yang dipilih
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B2E2E).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF8B2E2E),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Lokasi Penjemputan",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            isLoadingAddress || isLoadingLocation
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isLoadingLocation
                                            ? "Mencari lokasi Anda..."
                                            : "Memuat alamat...",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    currentAddress ??
                                        "Tap peta untuk memilih lokasi",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: currentAddress != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: currentAddress != null
                                          ? Colors.black87
                                          : Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tombol konfirmasi
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B2E2E),
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoadingAddress || isLoadingLocation
                          ? null
                          : _confirmLocation,
                      child: isLoadingAddress || isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Konfirmasi Lokasi",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}