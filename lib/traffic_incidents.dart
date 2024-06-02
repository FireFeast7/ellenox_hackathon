import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TrafficIncidentPage extends StatelessWidget {
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

  Map<String, dynamic> map = {};
  Future<List<Incident>> fetchIncidents() async {
    final data = await fetchTrafficIncidentData();
    final List<dynamic> results = data['results'];
    final incidents = results.map((json) => Incident.fromJson(json)).toList();
    final Map<String, Map<String, dynamic>> incidentMaps = {
      for (var incident in incidents) incident.id: incident.toMap()
    };

    final jsonString = jsonEncode(incidentMaps);

    print(jsonString);
    return results.map((json) => Incident.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic Incidents'),
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
            return IncidentDetailsPage(incidents: incidents);
          }
        },
      ),
    );
  }
}

class IncidentDetailsPage extends StatelessWidget {
  final List<Incident> incidents;

  IncidentDetailsPage({required this.incidents});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: incidents.length,
        itemBuilder: (context, index) {
          final incident = incidents[index];
          return ListTile(
            title: Text(incident.summary),
            subtitle: Text(incident.description),
            trailing: IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Type: ${incident.type}'),
                  Text('Criticality: ${incident.criticality}'),
                  Text('Road Closed: ${incident.roadClosed ? "Yes" : "No"}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Incident {
  final String id;
  final String description;
  final String summary;
  final String type;
  final String criticality;
  final bool roadClosed;
  final DateTime startTime;
  final DateTime endTime;

  Incident({
    required this.id,
    required this.description,
    required this.summary,
    required this.type,
    required this.criticality,
    required this.roadClosed,
    required this.startTime,
    required this.endTime,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['incidentDetails']['id'],
      description: json['incidentDetails']['description']['value'],
      summary: json['incidentDetails']['summary']['value'],
      type: json['incidentDetails']['type'],
      criticality: json['incidentDetails']['criticality'],
      roadClosed: json['incidentDetails']['roadClosed'],
      startTime: DateTime.parse(json['incidentDetails']['startTime']),
      endTime: DateTime.parse(json['incidentDetails']['endTime']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'summary': summary,
      'type': type,
      'criticality': criticality,
      'roadClosed': roadClosed,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
