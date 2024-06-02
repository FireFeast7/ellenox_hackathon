// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:ellenox_hackathon/chatbot.dart';
import 'package:ellenox_hackathon/currentLocation.dart';
import 'package:ellenox_hackathon/mapview.dart';
import 'package:ellenox_hackathon/traffic.dart';
import 'package:ellenox_hackathon/traffic_incidents.dart';
import 'package:ellenox_hackathon/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
