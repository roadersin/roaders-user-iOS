import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'otp_verification/user_info_save_locally.dart';

// Replace 'YOUR_LAMBDA_URL' with the actual URL of your deployed Lambda function
const lambdaUrl =
    'https://3brpatgui3k4oqvt4c2hkmr7qe0bwazu.lambda-url.ap-south-1.on.aws/';

// Replace 'RECIPIENT_EMAIL' with the email address you want to send the email to
// const recipientEmail = 'akshatparmar78543@gmail.com';

// Construct the URL with the query string parameter

// Function to make the API request
Future<void> requestOtp(String recipientEmail, String phoneNum) async {
  try {
    final apiUrl =
        Uri.parse('$lambdaUrl?email=${Uri.encodeComponent(recipientEmail)}');

    saveKeyLocally("email", recipientEmail);
    saveKeyLocally("phoneNum", phoneNum);
    // Make a GET request to the Lambda function
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      // Successful response
      debugPrint('Lambda Response: ${response.body}');
    } else {
      // Handle error response
      debugPrint('HTTP error! Status: ${response.body}');
    }
  } catch (error) {
    // Handle general error
    debugPrint('Error: $error');
  }
}

// Function to be called when the "Request OTP" button is clicked
void onButtonClicked(String recipientEmail, String phoneNum) {
  requestOtp(recipientEmail, phoneNum);
}

// Usage in your Flutter code
// ElevatedButton(
//   onPressed: onButtonClicked,
//   child: Text("Request OTP"),
// ),
