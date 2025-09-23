// ignore_for_file: deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class BookingViewFull extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingViewFull({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = (booking['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.bookingReceipt,
          style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (booking['type'] == "fixed")
                  _buildDetailRow(Icons.description, 'Service Type', "Trip"),
                if (booking['type'] == "rental")
                  _buildDetailRow(Icons.description, 'Service Type', "Rental"),
                if (booking['type'] == "rental")
                  _buildDetailRow(Icons.description, 'Km and Hrs',
                      booking['rentalKmAndTime']),
                _buildDetailRow(
                    Icons.info, 'Booking Status', booking['booking_status']),
                _buildDetailRow(Icons.date_range, 'Date', formattedDate),
                _buildDetailRow(Icons.directions_car, 'Vehicle',
                    booking['vehicleSelected']),
                _buildDetailRow(
                    Icons.money, 'Price', '₹ ${booking['estPrice']}'),
                _buildDetailRow(
                    Icons.payment,
                    'Payment Status',
                    booking['paymentStatus'] == "Unpaid"
                        ? "Cash"
                        : booking['paymentStatus']),
                _buildDetailRow(Icons.drive_eta_sharp, 'Driver Partner',
                    "${booking['driverName']}, ${booking['driverPhoneNum']}"),
                _buildDetailRow(Icons.phone, 'Vehicle Number',
                    booking['driverVehicleNumber'] ?? "Not Available"),
                _buildDetailRow(Icons.location_pin, 'Pickup',
                    "${booking['pickupName']}, ${booking['pickupPhoneNumber']}"),
                _buildDetailRow(Icons.description, 'Pickup Description',
                    booking['pickupDescription']),
                if (booking['stop1'] != "")
                  _buildDetailRow(Icons.description, 'Stop1', booking['stop1']),
                if (booking['stop2'] != "")
                  _buildDetailRow(Icons.description, 'Stop2', booking['stop2']),
                if (booking['stop3'] != "")
                  _buildDetailRow(Icons.description, 'Stop3', booking['stop3']),
                _buildDetailRow(Icons.location_pin, 'Drop',
                    "${booking['dropName']}, ${booking['dropPhoneNumber']}"),
                _buildDetailRow(Icons.description, 'Drop Description',
                    booking['dropDescription']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 255, 154, 52)),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
