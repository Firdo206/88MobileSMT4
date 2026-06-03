import 'package:flutter/material.dart';
import '../../../services/booking_service.dart';
import '../../../services/booking_paket_service.dart';
import '../../../services/rental_service.dart';
import '../../../services/payment_service.dart';

class DetailPesananService {
  /// Cancel pesanan berdasarkan type
  static Future<void> cancelOrder(
    BuildContext context, {
    required Map data,
    required String type,
    String reason = "",
  }) async {
    try {
      if (type == "ticket") {
        await BookingService.cancelBooking(data["id"], reason: reason);
      } else if (type == "tour") {
        await BookingPaketService.cancelTour(data["id"], reason: reason);
      } else {
        await RentalService.cancelRental(data["id"], reason: reason);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Pesanan berhasil dibatalkan"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Gagal membatalkan: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Selesaikan pesanan berdasarkan type
  static Future<void> finishOrder({
    required BuildContext context,
    required Map data,
    required String type,
  }) async {
    if (type == "ticket") {
      await BookingService.finish(data["id"]);
    } else if (type == "tour") {
      await BookingPaketService.finish(data["id"]);
    } else {
      await RentalService.finish(data["id"]);
    }
    Navigator.pop(context, true);
  }

  /// Cek status pembayaran Midtrans
  static Future<void> checkPaymentStatus(BuildContext context, Map data) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final bookingId = int.tryParse(data["id"]?.toString() ?? "0") ?? 0;
    final status = await PaymentService.checkStatus(bookingId);

    Navigator.pop(context);

    if (status == 'settlement') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("✅ Pembayaran berhasil dikonfirmasi!"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true);
    } else if (status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("⏳ Pembayaran masih pending, harap tunggu..."),
        backgroundColor: Colors.orange,
      ));
    } else if (status != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: $status")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Belum ada pembayaran via Midtrans"),
      ));
    }
  }
}