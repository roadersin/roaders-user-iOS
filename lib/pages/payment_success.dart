// ignore_for_file: sized_box_for_whitespace
import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'searching_driver.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String paymentId;

  const PaymentSuccessPage({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SearchingDriver()),
        (Route<dynamic> route) => false,
      );
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 150,
              width: 150,
              child: Image.asset(
                "assets/gif/success.gif",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.paymentSuccess,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            // SizedBox(height: 10),
            // Text(
            //   "Payment ID: $paymentId",
            //   style: TextStyle(fontSize: 16),
            // ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //       Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (context) => SearchingDriver(),
            //         ),
            //       );
            //   },
            //   child: Text("Continue"),
            // ),
          ],
        ),
      ),
    );
  }
}
