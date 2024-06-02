import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getCurrentLocation() async {
  const String url = 'http://ip-api.com/json/';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var locationData = {
        'lat': data['lat'],
        'lon': data['lon'],
        'city': data['city'],
      };
      print('Location Data: $locationData'); 

      return {
        'lat': data['lat'],
        'lon': data['lon'],
        'city': data['city'],
      };
    } else {
      print('Failed to load location data');
      return {
        'lat': 0,
        'lon': 0,
        'city': 'unknown',
      };
    }
  } catch (e) {
    print('Error fetching current location: $e');
    return {
      'lat': 0,
      'lon': 0,
      'city': 'unknown',
    };
  }
}

Future<void> resetContext() async {
  try {
    final response = await http.post(
      Uri.parse('https://travelbot-a2mf.onrender.com/reset_context/'),
    );
    if (response.statusCode == 200) {
      print('Context reset successfully');
    } else {
      print('Failed to reset context: ${response.statusCode}');
    }
  } catch (e) {
    print('Error resetting context: $e');
  }
}

Future<List<List<double>>> fetchRouteCoordinates() async {
  final String uri =
      "https://trueway-directions2.p.rapidapi.com/FindDrivingRoute?stops=19.0760%2C72.8777%3B18.5204%2C73.8567";

  final Map<String, String> headers = {
    'x-rapidapi-key': "ec9e433778msh32261a3977361bbp1372abjsn997471d1a0ca",
    'x-rapidapi-host': "trueway-directions2.p.rapidapi.com",
  };

  try {
    final response = await http.get(Uri.parse(uri), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      final List<dynamic> coordinates =
          jsonData['route']['geometry']['coordinates'] as List<dynamic>;

      final List<List<double>> routeCoordinates =
          coordinates.map<List<double>>((coord) {
        return [
          (coord[0] as num).toDouble(),
          (coord[1] as num).toDouble(),
        ];
      }).toList();
      print(coordinates);
      return routeCoordinates;
    } else {
      print('Error: ${response.statusCode}');
      return []; // Return an empty list in case of error
    }
  } catch (error) {
    // Handle errors related to the HTTP request
    print('Error: $error');
    return []; // Return an empty list in case of error
  }
}


