
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
