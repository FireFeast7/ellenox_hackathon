import 'package:ellenox_hackathon/views/mapview.dart';
import 'package:ellenox_hackathon/views/traffic.dart';
import 'package:ellenox_hackathon/views/traffic_incidents.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ButtonRow extends StatelessWidget {
  final List<double> coordinates;

  const ButtonRow({Key? key, required this.coordinates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#ECC5FF'),
            ),
            onPressed: () {
              print(coordinates);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RouteMap(coordinates: coordinates),
                ),
              );
            },
            child: Text('Check Maps'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#ECC5FF'),
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TrafficFlowPage()));
            },
            child: Text('Get Traffic Information'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#ECC5FF'),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TrafficIncidentPage()));
            },
            child: Text('Get Incidents Information'),
          ),
        ],
      ),
    );
  }
}
