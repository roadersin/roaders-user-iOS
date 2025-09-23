// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getAddressFromLatLng(double latitude, double longitude) async {
  const String apiKey = 'AIzaSyBl7DPAOITMXQfvD9c1D87UaZTJ2vjYwq4';
  final String url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final String address = data['results'][0]['formatted_address'];
      return address;
    } else {
      throw Exception('Failed to get address: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch data from Google Maps API');
  }
}
