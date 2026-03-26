import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/booking_service.dart';
import '../booking/payment_page.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {

  List bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future loadBookings() async {

    try {

      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("user_id") ?? 0;

      final data = await BookingService.getMyBookings(userId);

      // DEBUG - cek apakah passengers ada di response API
      if (data != null && data.isNotEmpty) {
        print("BOOKING DATA: ${jsonEncode(data[0])}");
      }

      setState(() {
        bookings = data ?? [];
        isLoading = false;
      });

    } catch (e) {

      print("ERROR LOAD BOOKING : $e");

      setState(() {
        bookings = [];
        isLoading = false;
      });

    }

  }

  /// WARNA STATUS
  Color getStatusColor(Map booking){

    String status = booking["payment_status"] ?? "pending";
    String proof = booking["payment_proof"] ?? "";

    if(status == "pending" && proof == ""){
      return Colors.orange;
    }

    if(status == "pending" && proof != ""){
      return Colors.blue;
    }

    if(status == "paid"){
      return Colors.green;
    }

    if(status == "expired"){
      return Colors.grey;
    }

    if(status == "cancelled"){
      return Colors.red;
    }

    if(status == "refund"){
      return Colors.purple;
    }

    return Colors.grey;
  }

  /// TEXT STATUS
  String getStatusText(Map booking){

    String status = booking["payment_status"] ?? "pending";
    String proof = booking["payment_proof"] ?? "";

    if(status == "pending" && proof == ""){
      return "BELUM BAYAR";
    }

    if(status == "pending" && proof != ""){
      return "MENUNGGU KONFIRMASI";
    }

    if(status == "paid"){
      return "SELESAI";
    }

    if(status == "expired"){
      return "KADALUARSA";
    }

    if(status == "cancelled"){
      return "DIBATALKAN";
    }

    if(status == "refund"){
      return "REFUND";
    }

    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan"),
        backgroundColor: Colors.red,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : bookings.isEmpty
          ? const Center(
              child: Text(
                "Belum ada pesanan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            )

          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index){

                final booking = bookings[index];

                String status = booking["payment_status"] ?? "pending";
                String proof = booking["payment_proof"] ?? "";

                return GestureDetector(

                  onTap: () async {

                    if(status == "pending" && proof == ""){

                      // Ambil passengers dari API, fallback ke data booking utama
                      final rawPassengers = booking['passengers'];
                      List passengerList = [];

                      if (rawPassengers != null && rawPassengers is List && rawPassengers.isNotEmpty) {
                        passengerList = List<Map<String, dynamic>>.from(rawPassengers);
                      } else {
                        passengerList = [
                          {
                            'seat': booking['seat_number'] ?? booking['seats'] ?? '-',
                            'passenger_name': booking['passenger_name'] ?? '-',
                            'phone': booking['phone'] ?? '-',
                          }
                        ];
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(
                            bookingData: {
                              ...Map<String, dynamic>.from(booking),
                              'total_price': int.tryParse(
                                double.tryParse(booking['total_price']?.toString() ?? '0')
                                    ?.toStringAsFixed(0) ?? '0'
                              ) ?? 0,
                              'passengers': passengerList,
                              'passenger_name': booking['passenger_name'] ?? "-",
                              'expired_at': booking['expired_at'],  // ← tambah ini
                            },
                          ),
                        ),
                      );

                      loadBookings();

                    }

                  },

                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// BOOKING CODE
                        Text(
                          "Kode : ${booking["booking_code"] ?? "-"}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),

                        const SizedBox(height: 5),

                        /// RUTE
                        Text(
                          "${booking["origin"] ?? "-"} → ${booking["destination"] ?? "-"}"
                        ),

                        const SizedBox(height: 5),

                        /// TANGGAL
                        Text(
                          "Tanggal : ${booking["departure_date"] ?? "-"}"
                        ),

                        const SizedBox(height: 5),

                        /// TOTAL HARGA
                        Text(
                          "Rp ${booking["total_price"] ?? 0}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// STATUS
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(booking),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            getStatusText(booking),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                );

              }
          ),
    );
  }
}