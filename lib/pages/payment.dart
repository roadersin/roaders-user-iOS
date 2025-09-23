import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../classes/transaction.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';

class Payment {
  late Razorpay _razorpay;
  final Map<String, dynamic> orderData;
  final String type;

  Payment(context, this.orderData, this.type) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
        (response) => _handlePaymentErrorResponse(context, response));
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (response) => _handlePaymentSuccessResponse(context, response));
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
        (response) => _handleExternalWalletSelected(context, response));
  }

  void initiatePayment(phoneNum, email) {
    var options = {
      'key': 'rzp_live_hse2rfcdaZrewu',
      'amount': orderData['topupAmount'] * 100,
      'name': 'Roaders',
      'description': 'top-up wallet',
      'retry': {'enabled': true, 'max_count': 1},
      "prefill": {"contact": phoneNum, "email": email},
      'send_sms_hash': true,
      'external': {
        'wallets': ['paytm']
      }
    };
    _razorpay.open(options);
  }

  // Update your Payment class in payment.dart
  void _handlePaymentSuccessResponse(
      context, PaymentSuccessResponse response) async {
    final DatabaseService databaseService = DatabaseService();

    // Create transaction record
    final String transactionId =
        DateTime.now().millisecondsSinceEpoch.toString();
    final TransactionModel transaction = TransactionModel(
      id: transactionId,
      email: orderData['email'],
      amount: orderData['topupAmount'],
      status: 'success',
      timestamp: DateTime.now(),
      type: 'topup',
      paymentMethod: 'razorpay',
      transactionId: response.paymentId,
    );

    // Record the transaction
    await recordTransaction(transaction);

    if (type == "wallet") {
      await databaseService.topupWallet(
          orderData['email'], "driverDetails", orderData['topupAmount']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.walletTopUpSuccessful),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handlePaymentErrorResponse(context, PaymentFailureResponse response) {
    // Get a user-friendly error message first
    String userFriendlyMessage =
        _getUserFriendlyErrorMessage(response.code, response.message);

    // Create transaction record with the user-friendly message
    final String transactionId =
        DateTime.now().millisecondsSinceEpoch.toString();
    final TransactionModel transaction = TransactionModel(
      id: transactionId,
      email: orderData['email'],
      amount: orderData['topupAmount'],
      status: 'failed',
      timestamp: DateTime.now(),
      type: 'topup',
      paymentMethod: 'razorpay',
      errorMessage: userFriendlyMessage,
    );

    // Record the transaction
    recordTransaction(transaction);

    // Show the user-friendly error dialog
    _showErrorDialog(context, userFriendlyMessage);
  }

// This function translates technical errors to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic code, dynamic message) {
    // Convert code to string for comparison if it's not already
    String errorCode = code.toString();
    String errorMessage = message.toString().toLowerCase();

    if (errorMessage.contains('network') ||
        errorMessage.contains('connectivity') ||
        errorMessage.contains('timeout')) {
      return 'Connection issue detected';
    } else if (errorMessage.contains('insufficient') ||
        errorMessage.contains('funds') ||
        errorMessage.contains('balance')) {
      return 'Insufficient funds';
    } else if (errorMessage.contains('declined') ||
        errorMessage.contains('rejected') ||
        errorMessage.contains('failed')) {
      return 'Payment declined by bank';
    } else if (errorMessage.contains('authentication') ||
        errorMessage.contains('authorize') ||
        errorMessage.contains('otp')) {
      return 'Authentication failed';
    } else if (errorCode == 'BAD_REQUEST_ERROR') {
      return 'Invalid payment information';
    } else if (errorCode == 'GATEWAY_ERROR') {
      return 'Payment gateway error';
    } else {
      // Generic message for other errors
      return 'Payment processing failed';
    }
  }

  // Enhanced error dialog with better visuals
  void _showErrorDialog(BuildContext context, String message) {
    // Get device screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    // Calculate responsive width constraints
    final double dialogWidth = screenWidth * 0.85;
    const double maxWidth = 450; // Maximum dialog width

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth < 600 ? 16 : 20),
          ),
          // Constrain width for better readability on large screens
          contentPadding: EdgeInsets.all(screenWidth < 600 ? 16.0 : 24.0),
          titlePadding: EdgeInsets.fromLTRB(
            screenWidth < 600 ? 16.0 : 24.0,
            screenWidth < 600 ? 16.0 : 24.0,
            screenWidth < 600 ? 16.0 : 24.0,
            8.0,
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[700],
                size: screenWidth < 600 ? 28 : 32,
              ),
              SizedBox(width: screenWidth < 600 ? 10 : 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.paymentFailed ??
                      'Payment Failed',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: screenWidth < 600 ? 18 : 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth < maxWidth ? dialogWidth : maxWidth,
              maxHeight: screenSize.height * 0.7, // Limit max height
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 16 : 18,
                    ),
                  ),
                  SizedBox(height: screenWidth < 600 ? 16 : 24),
                  Text(
                    'If this problem continues, please contact support.',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14 : 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      AppLocalizations.of(context)?.tryAgain ?? 'Try Again',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: screenWidth < 600 ? 14 : 16,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Optional: re-open payment dialog
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      AppLocalizations.of(context)?.cancel ?? 'Cancel',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 14 : 16,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleExternalWalletSelected(context, ExternalWalletResponse response) {
    _showAlertDialog(
      context,
      AppLocalizations.of(context)!.externalWalletSelected,
      "${response.walletName}",
    );
  }

  void _showAlertDialog(context, String title, String message) {
    Widget continueButton = ElevatedButton(
      child: Text(AppLocalizations.of(context)!.continueS),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
