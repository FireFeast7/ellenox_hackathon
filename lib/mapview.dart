import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteMap extends StatefulWidget {
  final List<double> coordinates;
  RouteMap({super.key, required this.coordinates});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  late Future<List<List<double>>> _routeCoordinatesFuture;
  late LatLng latLng;
  @override
  void initState() {
    super.initState();
    _routeCoordinatesFuture = fetchRouteCoordinates();
  }

  Future<List<List<double>>> fetchRouteCoordinates() async {
    assert(widget.coordinates.length % 2 == 0);

    List<String> stops = [];
    for (int i = 0; i < widget.coordinates.length; i += 2) {
      stops.add("${widget.coordinates[i]}%2C${widget.coordinates[i + 1]}");
    }
    final String stopsString = stops.join('%3B');
    print(stopsString);
    final String uri =
        "https://trueway-directions2.p.rapidapi.com/FindDrivingRoute?stops=$stopsString";

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
        return [];
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Map'),
        centerTitle: true,
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
            double avgLat = 0.0;
            double avgLng = 0.0;
            for (var coord in routeCoordinates) {
              avgLat += coord[0];
              avgLng += coord[1];
            }
            avgLat /= routeCoordinates.length;
            avgLng /= routeCoordinates.length;
            latLng = LatLng(avgLat, avgLng);
            return FlutterMap(
              options: MapOptions(
                center: latLng,
                zoom: 8.0,
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
                      color: Colors.black,
                      strokeWidth: 2.0,
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
