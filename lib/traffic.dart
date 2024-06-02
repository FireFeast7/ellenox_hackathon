import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrafficFlowPage extends StatefulWidget {
  @override
  State<TrafficFlowPage> createState() => _TrafficFlowPageState();
}

class _TrafficFlowPageState extends State<TrafficFlowPage> {
  Map<dynamic, dynamic> map = {};

  Future<Map<String, dynamic>> fetchTrafficFlowData() async {
    final String url =
        "https://data.traffic.hereapi.com/v7/flow?locationReferencing=shape&in=circle:18.5204,73.8567;r=100&apiKey=LDqTvoCf_-jBLRKJaQgdldgPolbOf4Tj4cKM17Nt3BU";
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

  String calculateMode(List<dynamic> flows) {
    Map<String, int> frequencyMap = {};
    for (var flow in flows) {
      String traversability = flow['currentFlow']['traversability'];
      frequencyMap[traversability] = (frequencyMap[traversability] ?? 0) + 1;
    }
    int maxFrequency =
        frequencyMap.values.fold(0, (prev, curr) => prev > curr ? prev : curr);
    List<String> modes = frequencyMap.entries
        .where((entry) => entry.value == maxFrequency)
        .map((entry) => entry.key)
        .toList();
    map['traversability'] = modes[0];
    getTrafficInformation(map);
    return modes.length == 1 ? modes[0] : 'Multiple Modes';
  }

  double calculateAverage(List<dynamic> flows, String attribute) {
    double total = 0.0;
    for (var flow in flows) {
      total += flow['currentFlow'][attribute];
    }
    if (attribute == 'speed' || attribute == 'speedUncapped') {
      map[attribute] = ((total / flows.length) * 3.6).toStringAsFixed(2);
    } else {
      map[attribute] = total / flows.length;
    }
    return total / flows.length;
  }

  Future<void> getTrafficInformation(Map<dynamic, dynamic> map) async {
    if (map.containsKey('response')) {
      return;
    }

    var response = await http.post(
      Uri.parse('https://travelbot-summarizer.onrender.com/traffic'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(map),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      var text = responseBody['summary'];
      print(text);
      setState(() {
        map['response'] = text;
      });
    } else {
      print('Failed to fetch traffic information: ${response.statusCode}');
    }
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
              double avgSpeed = calculateAverage(results, 'speed');
              double avgSpeedUncapped =
                  calculateAverage(results, 'speedUncapped');
              double avgFreeFlow = calculateAverage(results, 'freeFlow');
              double avgJamFactor = calculateAverage(results, 'jamFactor');
              double avgConfidence = calculateAverage(results, 'confidence');
              String modeTraversability = calculateMode(results);
              print(jsonEncode(map));
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      'Average Speed: ${(avgSpeed * 3.6).toStringAsFixed(2)} km/h'),
                  Text(
                      'Average Speed (Uncapped): ${(avgSpeedUncapped * 3.6).toStringAsFixed(2)} km/h'),
                  Text(
                      'Average Free Flow: ${(avgFreeFlow * 3.6).toStringAsFixed(2)} km/h'),
                  Text(
                      'Average Jam Factor: ${avgJamFactor.toStringAsFixed(2)}'),
                  Text(
                      'Average Confidence: ${avgConfidence.toStringAsFixed(2)}'),
                  Text('Mode Traversability: $modeTraversability'),
                  if (map.containsKey('response'))
                    Text('Response: ${map['response']}'),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
