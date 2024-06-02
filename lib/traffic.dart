import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TrafficFlowPage extends StatefulWidget {
  @override
  State<TrafficFlowPage> createState() => _TrafficFlowPageState();
}

class _TrafficFlowPageState extends State<TrafficFlowPage> {
  Map<dynamic, dynamic> map = {};

  Future<Map<String, dynamic>> fetchTrafficFlowData() async {
    const String url =
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
      backgroundColor: HexColor('#FEF9F4'),
      appBar: AppBar(
        title: const Text('Traffic Flow'),
        backgroundColor: HexColor('#FEF9F4'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchTrafficFlowData(),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final Map<String, dynamic> trafficData = snapshot.data!;
              final List<dynamic> results = trafficData['results'];
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.175,
                    child: Image.asset('assets/images/traffic.gif',
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  DataTable(
                    columns: <DataColumn>[
                      DataColumn(
                        label: Container(
                          color: Colors.black,
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Attribute',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          color: Colors.black, // Apply color to the header
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Value',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    rows: <DataRow>[
                      DataRow(
                        cells: [
                          DataCell(Text('Average Speed')),
                          DataCell(Text(
                              '${(avgSpeed * 3.6).toStringAsFixed(2)} km/h')),
                        ],
                        color: WidgetStateProperty.all(
                            HexColor('#B6E0FF')), 
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Average Speed (Uncapped)')),
                          DataCell(Text(
                              '${(avgSpeedUncapped * 3.6).toStringAsFixed(2)} km/h')),
                        ],
                        color: WidgetStateProperty.all(
                            HexColor('#ECC5FF')), 
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Average Free Flow')),
                          DataCell(Text(
                              '${(avgFreeFlow * 3.6).toStringAsFixed(2)} km/h')),
                        ],
                        color: WidgetStateProperty.all(
                            HexColor('#B6E0FF')), 
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Average Jam Factor')),
                          DataCell(Text(avgJamFactor.toStringAsFixed(2))),
                        ],
                        color: WidgetStateProperty.all(
                            HexColor('#ECC5FF')), 
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Average Confidence')),
                          DataCell(Text(avgConfidence.toStringAsFixed(2))),
                        ],
                        color: WidgetStateProperty.all(
                            HexColor('#B6E0FF')), 
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Mode Traversability')),
                          DataCell(Text(modeTraversability)),
                        ],
                        color: WidgetStateProperty.all(HexColor('#ECC5FF')),
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Best Time to Leave')),
                          DataCell(Text('7:00 AM')),
                        ],
                        color: WidgetStateProperty.all(
                            HexColor('#B6E0FF')), 
                      ),
                    ],
                  ),
                  if (map.containsKey('response'))
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HexColor('#D0F065'),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Traffic Summary',
                              style: TextStyle(
                                fontSize: 18.0, // Adjust font size as needed
                                fontWeight:
                                    FontWeight.bold, // Make it bold for heading
                              ),
                            ),
                            Text(
                              map['response'],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
