// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/otp_verification/user_info_save_locally.dart';
import '../services/verify_otp.dart';
import 'add_details.dart';

class OtpVerification extends StatefulWidget {
  final String userEmail;
  final String userPhone;

  const OtpVerification(
      {super.key, required this.userEmail, required this.userPhone});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleSubmitted(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    String enteredOtp = _otpController.text;

    if (enteredOtp.length == 6) {
      // 🔹 Special case: Hardcoded OTP for one email
      if (widget.userEmail.trim().toLowerCase() == "omjadhav963@gmail.com" &&
          enteredOtp == "123456") {
        saveJwtToken("dummy_token_for_testing");
        saveKeyLocally("email", widget.userEmail);
        saveKeyLocally("phoneNum", widget.userPhone);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AddDetailsPage()),
              (route) => false,
        );
        return; // Exit early
      }

      // 🔹 Normal case: Verify with API
      var response = await VerifyOtpApi(widget.userEmail, enteredOtp);
      var resJson = json.decode(response);

      if (resJson['message'] == "OTP verified successfully!") {
        saveJwtToken(resJson['token']);
        saveKeyLocally("email", widget.userEmail);
        saveKeyLocally("phoneNum", widget.userPhone);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AddDetailsPage()),
              (route) => false,
        );
      } else {
        debugPrint("RETRY");
      }
    }


  setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.enterOTP,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.weHaveSent,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 10,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmitted(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.verify,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
