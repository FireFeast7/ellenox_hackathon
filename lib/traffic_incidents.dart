import 'package:ellenox_hackathon/incident_model.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TrafficIncidentPage extends StatefulWidget {
  @override
  State<TrafficIncidentPage> createState() => _TrafficIncidentPageState();
}

class _TrafficIncidentPageState extends State<TrafficIncidentPage> {
  Future<Map<String, dynamic>> fetchTrafficIncidentData() async {
    final String url =
        "https://data.traffic.hereapi.com/v7/incidents?locationReferencing=shape&in=circle:51.50643,-0.12719;r=100&apiKey=LDqTvoCf_-jBLRKJaQgdldgPolbOf4Tj4cKM17Nt3BU";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load traffic incident data');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<List<Incident>> fetchIncidents() async {
    final data = await fetchTrafficIncidentData();
    final List<dynamic> results = data['results'];
    final incidents = results.map((json) => Incident.fromJson(json)).toList();
    final Map<String, Map<String, dynamic>> incidentMaps = {
      for (var incident in incidents) incident.id: incident.toMap()
    };

    final jsonString = jsonEncode(incidentMaps);

    print(jsonString);

    getTrafficIncidentInformation(jsonString);

    return incidents;
  }

  Future<void> getTrafficIncidentInformation(String data) async {
    if (map.containsKey('response')) {
      return;
    }
    var response = await http.post(
      Uri.parse('https://travelbot-summarizer.onrender.com/incidents'),
      headers: {'Content-Type': 'application/json'},
      body: data,
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

  Map<String, dynamic> map = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#FEF9F4'),
      appBar: AppBar(
        title: Text(
          'Traffic Incidents',
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Incident>>(
        future: fetchIncidents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final incidents = snapshot.data!;
            return IncidentDetailsPage(
                incidents: incidents, response: map['response']);
          }
        },
      ),
    );
  }
}

class IncidentDetailsPage extends StatelessWidget {
  final List<Incident> incidents;
  final String? response;

  IncidentDetailsPage({required this.incidents, this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
            child: Image.asset('assets/images/incident.gif', fit: BoxFit.cover),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: HexColor('#B6E0FF'),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: HexColor('#ECC5FF')),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.summary,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(incident.description),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Type: ${incident.type}'),
                          Text('Criticality: ${incident.criticality}'),
                          Text(
                              'Road Closed: ${incident.roadClosed ? "Yes" : "No"}'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (response != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: HexColor('#D0F065'),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: HexColor('#ECC5FF')),
                ),
                child: Column(
                  children: [
                    Text(
                      'Incidents Summary',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      response!,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
