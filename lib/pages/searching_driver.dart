// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';
import '../services/read_local.dart';
import 'orders_page.dart';

class SearchingDriver extends StatefulWidget {
  const SearchingDriver({super.key});

  @override
  _SearchingDriverState createState() => _SearchingDriverState();
}

class _SearchingDriverState extends State<SearchingDriver> {
  final DatabaseService _databaseService = DatabaseService();
  late Timer _timer;
  bool tripCancelled = false;

  @override
  void initState() {
    super.initState();

    // Start periodic status check every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      String? email = await getEmailFromLocal();
      List<Map<String, dynamic>> dataList =
          await _databaseService.readDataByEmailLimit('booking', email!);

      if (dataList.isNotEmpty) {
        String bookingStatus = dataList[0]['booking_status'];
        if (bookingStatus == 'Driver Assigned') {
          _timer.cancel(); // Stop further checks
          showSuccessPopupAndNavigate();
        } else {
          // After 60 seconds, cancel the trip if still not accepted
          if (timer.tick >= 6) {
            _timer.cancel(); // Stop further checks
            await cancelTripAndNavigate('No Driver Found');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when disposing the widget
    super.dispose();
  }

  Future<void> showSuccessPopupAndNavigate() async {
    // Show success popup
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.success),
        content: Text(
          AppLocalizations.of(context)!.driverFound,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );

    // Navigate to OrdersPage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OrdersPage()),
      (Route<dynamic> route) => false,
    );
  }

// First, add this function to retrieve booking details by email
  Future<Map<String, dynamic>?> getBookingDetails(String email) async {
    try {
      List<Map<String, dynamic>> dataList =
          await _databaseService.readDataByEmailLimit('booking', email);

      if (dataList.isNotEmpty) {
        return dataList[0];
      }
      return null;
    } catch (e) {
      debugPrint("Error getting booking details: $e");
      return null;
    }
  }

// Then modify the cancelTripAndNavigate method to include:
  Future<void> cancelTripAndNavigate(String reason) async {
    // Update booking status to 'cancelled'
    String? email = await getEmailFromLocal();

    // Show failure popup
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.tripCancelled),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () async {
              // First, get the current booking details to access payment information
              Map<String, dynamic>? bookingDetails =
                  await getBookingDetails(email!);

              // Update the booking status to cancelled
              Map<String, dynamic> orderData = {"booking_status": "cancelled"};
              await _databaseService.addOrUpdateBookingByEmail(
                  email, orderData, 'booking');

              // Process the wallet update for online payments
              await _databaseService.updateWalletIfOnline(email, 'booking');

              // Record refund transaction if the payment was online
              if (bookingDetails != null &&
                  bookingDetails['paymentStatus'] == 'online') {
                double refundAmount = 0.0;

                // Handle the amount properly based on type
                if (bookingDetails['estPrice'] is int) {
                  refundAmount = bookingDetails['estPrice'].toDouble();
                } else if (bookingDetails['estPrice'] is double) {
                  refundAmount = bookingDetails['estPrice'];
                }

                // Record the refund transaction
                await recordRefundTransaction(email, refundAmount,
                    bookingDetails['paymentId'] ?? 'unknown');
              }

              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.ok,
            ),
          ),
        ],
      ),
    );

    // Navigate to OrdersPage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OrdersPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.searchingDriver,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset('assets/gif/vehicle_on_road.gif'),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: tripCancelled
                    ? null
                    : () async {
                        _timer.cancel(); // Cancel periodic check
                        await cancelTripAndNavigate(
                            AppLocalizations.of(context)!
                                .tripWasCancelledByYou);
                      },
                child: Text(
                  AppLocalizations.of(context)!.cancelTrip,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
