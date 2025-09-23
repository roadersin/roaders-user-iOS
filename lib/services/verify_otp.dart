// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'database.dart';
import 'read_local.dart';

// Replace 'YOUR_LAMBDA_URL' with the actual URL of your deployed Lambda function
const lambdaUrl =
    'https://gaqjyqhexaqsegidaoxm3dwx4i0blxwx.lambda-url.ap-south-1.on.aws/';

// Replace 'RECIPIENT_EMAIL' with the email address you want to send the email to
// const recipientEmail = 'akshatparmar78543@gmail.com';

// Construct the URL with the query string parameter

// Function to make the API request
Future<String> VerifyOtpApi(String recipientEmail, String otpEntered) async {
  try {
    Map<String, dynamic> orderData = {
      'email': recipientEmail,
      'phoneNum': await getPhoneNumberFromLocal(),
    };

    final apiUrl = Uri.parse(
        '$lambdaUrl?email=${Uri.encodeComponent(recipientEmail)}&otp=${Uri.encodeComponent(otpEntered)}');

    // Make a GET request to the Lambda function
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      // Successful response

      final DatabaseService databaseService = DatabaseService();

      // Add order
      await databaseService.addOrUpdateUserByEmail(
          recipientEmail, orderData, 'userDetails');
      return response.body; // Return the response here
    } else {
      // Handle error response
      debugPrint('HTTP error! Status: ${response.statusCode}');
      var failureMsg = jsonEncode({'message': "Failed"});
      return failureMsg;
    }
  } catch (error) {
    // Handle general error
    debugPrint('Error: $error');
    throw Exception('Error: $error');
  }
}
