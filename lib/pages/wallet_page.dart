// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';
import '../services/read_local.dart';
import 'home_page.dart';
import 'payment.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final DatabaseService _databaseService = DatabaseService();

  double walletBalance = 0.0;
  TextEditingController topupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    String? email = await getEmailFromLocal();

    try {
      double balance = await _databaseService.readWallet(email!, "userDetails");
      setState(() {
        walletBalance = balance;
      });
    } catch (e) {
      debugPrint("Error fetching wallet balance: $e");
      // Handle error
    }
  }

  Future<void> _topupWallet() async {
    try {
      String? email = await getEmailFromLocal();
      String? phoneNum = await getPhoneNumberFromLocal();

      double topupAmount = double.parse(topupController.text);

      Map<String, dynamic> orderData = {
        'email': email!,
        'topupAmount': topupAmount
      };

      final Payment payment = Payment(context, orderData, "wallet");
      payment.initiatePayment(phoneNum, email);

      // Update UI to reflect new wallet balance
      _fetchWalletBalance();

      // Clear input field
      topupController.clear();
    } catch (e) {
      debugPrint("Error topping up wallet: $e");
      // Handle error
    }
  }

  void _navigateToHomePage() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          AppLocalizations.of(context)!.wallet,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToHomePage,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWalletBalance,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.currentWalletBalance,
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(width: 8.0),
                Text(
                  '₹${walletBalance.toStringAsFixed(2)}', // Format to 2 decimal places
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              controller: topupController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.enterTopUpAmount,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.reenterTopUpAmount;
                }
                // Check if the entered value is a valid number and greater than 0
                if (double.tryParse(value)! < 0) {
                  return AppLocalizations.of(context)!
                      .enterNumberGreaterThanZero;
                }
                return null; // Return null if validation succeeds
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _topupWallet,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 255, 102, 0),
                    width: 1.0,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                AppLocalizations.of(context)!.topUpWallet,
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
