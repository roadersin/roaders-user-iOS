// ignore_for_file: file_names
import 'dart:convert';
import 'package:http/http.dart' as http;

class DistanceMatrixService {
  final String apiKey = 'AIzaSyBl7DPAOITMXQfvD9c1D87UaZTJ2vjYwq4';

  Future<double> getDistanceInKm({
    required String origin,
    required String destination,
  }) async {
    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanceInMeters =
          data['rows'][0]['elements'][0]['distance']['value'];
      return distanceInMeters / 1000; // Convert meters to kilometers
    } else {
      throw Exception('Failed to load distance matrix');
    }
  }
}
