// ignore_for_file: file_names
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, double>> getLatLngFromAddress(String address) async {
  const String apiKey =
      'AIzaSyBl7DPAOITMXQfvD9c1D87UaZTJ2vjYwq4'; // Replace with your Google Maps API key
  final String url =
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final Map<String, dynamic> location =
          data['results'][0]['geometry']['location'];
      final double lat = location['lat'];
      final double lng = location['lng'];
      return {'latitude': lat, 'longitude': lng};
    } else {
      throw Exception(
          'Failed to get latitude and longitude: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch data from Google Maps API');
  }
}
