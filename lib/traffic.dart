import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrafficFlowPage extends StatelessWidget {
  Future<Map<String, dynamic>> fetchTrafficFlowData() async {
    final String url = "https://data.traffic.hereapi.com/v7/flow?locationReferencing=shape&in=circle:18.5204,73.8567;r=100&apiKey=LDqTvoCf_-jBLRKJaQgdldgPolbOf4Tj4cKM17Nt3BU";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load traffic flow data');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  double calculateAverage(List<dynamic> flows, String attribute) {
    double total = 0.0;
    for (var flow in flows) {
      total += flow['currentFlow'][attribute];
    }
    return total / flows.length;
  }

  String calculateMode(List<dynamic> flows) {
    Map<String, int> frequencyMap = {};
    for (var flow in flows) {
      String traversability = flow['currentFlow']['traversability'];
      frequencyMap[traversability] = (frequencyMap[traversability] ?? 0) + 1;
    }
    int maxFrequency = frequencyMap.values.fold(0, (prev, curr) => prev > curr ? prev : curr);
    List<String> modes = frequencyMap.entries.where((entry) => entry.value == maxFrequency).map((entry) => entry.key).toList();
    return modes.length == 1 ? modes[0] : 'Multiple Modes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic Flow'),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchTrafficFlowData(),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final Map<String, dynamic> trafficData = snapshot.data!;
              final List<dynamic> results = trafficData['results'];
              final int numberOfResults = results.length;

              // Calculate averages
              double avgSpeed = calculateAverage(results, 'speed');
              double avgSpeedUncapped = calculateAverage(results, 'speedUncapped');
              double avgFreeFlow = calculateAverage(results, 'freeFlow');
              double avgJamFactor = calculateAverage(results, 'jamFactor');
              double avgConfidence = calculateAverage(results, 'confidence');

              // Calculate mode
              String modeTraversability = calculateMode(results);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Average Speed: ${(avgSpeed * 3.6).toStringAsFixed(2)} km/h'),
                  Text('Average Speed (Uncapped): ${(avgSpeedUncapped * 3.6).toStringAsFixed(2)} km/h'),
                  Text('Average Free Flow: ${(avgFreeFlow * 3.6).toStringAsFixed(2)} km/h'),
                  Text('Average Jam Factor: ${avgJamFactor.toStringAsFixed(2)}'),
                  Text('Average Confidence: ${avgConfidence.toStringAsFixed(2)}'),
                  Text('Mode Traversability: $modeTraversability'),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}