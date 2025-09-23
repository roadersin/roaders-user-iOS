// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Replace 'YOUR_LAMBDA_URL' with the actual URL of your deployed Lambda function
const lambdaUrl =
    'https://z6kyedjimmnygnxlp2koabssny0txxdh.lambda-url.ap-south-1.on.aws/';

Future<bool> saveDetailsToMongoDb(String name, String address, String location,
    String? email, String? phoneNum) async {
  // Determine the URL parameter based on the location
  String addrType;
  if (location == 'Home') {
    addrType = 'homeAddr';
  } else if (location == 'Shop') {
    addrType = 'shopAddr';
  } else {
    addrType = 'otherAddr';
  }

  try {
    Map<String, dynamic> orderData = {
      addrType: address,
      "name": name,
    };

    // Make a POST request to your Lambda function
    final response = await http.post(
      Uri.parse(
          '$lambdaUrl?$addrType=$address&name=$name&email=${email ?? ''}&phoneNum=${phoneNum ?? ''}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          'Failed to save data to MongoDB. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Error occurred while saving data to MongoDB: $e');
    return false;
  }
}
