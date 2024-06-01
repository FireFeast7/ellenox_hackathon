import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteMap extends StatefulWidget {
  RouteMap({
    Key? key,
  }) : super(key: key);

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  late Future<List<List<double>>> _routeCoordinatesFuture;

  @override
  void initState() {
    super.initState();
    _routeCoordinatesFuture = fetchRouteCoordinates();
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
        return routeCoordinates;
      } else {
        print('Error: ${response.statusCode}');
        return []; // Return an empty list in case of error
      }
    } catch (error) {
      print('Error: $error');
      return []; // Return an empty list in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Map'),
      ),
      body: FutureBuilder(
        future: _routeCoordinatesFuture,
        builder: (context, AsyncSnapshot<List<List<double>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final routeCoordinates = snapshot.data!;
            return FlutterMap(
              options: MapOptions(
                center: LatLng(38.0, -97.0), // Center of the map
                zoom: 5.0, // Initial zoom level
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeCoordinates
                          .map((coord) => LatLng(coord[0], coord[1]))
                          .toList(),
                      color: Colors.black, // Route color
                      strokeWidth: 2.0, // Route width
                    ),
                  ],
                )
              ],
            );
          }
        },
      ),
    );
  }
}
