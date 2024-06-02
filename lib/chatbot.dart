import 'dart:convert';

import 'package:ellenox_hackathon/currentLocation.dart';
import 'package:ellenox_hackathon/mapview.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

import 'weather_model.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool showButtons = false;
  List<double> coordinates = [];

  @override
  void initState() {
    resetContext();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeValue = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      backgroundColor: themeValue == Brightness.dark
          ? HexColor('#262626')
          : HexColor('#FFFFFF'),
      appBar: AppBar(
        backgroundColor: themeValue == Brightness.dark
            ? HexColor('#3C3A3A')
            : HexColor('#BFBFBF'),
        title: Center(
          child: Text(
            'Chat Bot',
            style: TextStyle(
                color: themeValue == Brightness.dark
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Body(
                messages: messages,
                showButtons: showButtons,
                coordinates: coordinates, // Pass showButtons state here
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: TextStyle(
                          color: themeValue == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: themeValue == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                            borderRadius: BorderRadius.circular(15)),
                        hintStyle: TextStyle(
                          color: themeValue == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                        labelStyle: TextStyle(
                            color: themeValue == Brightness.dark
                                ? Colors.white
                                : Colors.black),
                        hintText: 'Send a message',
                      ),
                    ),
                  ),
                  IconButton(
                    color: themeValue == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(messageController.text);
                      messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      addMessage({
        'text': text,
        'isUserMessage': true,
      });
      showButtons = false; // Reset button visibility
    });

    Map<String, dynamic> coord = await getCurrentLocation();
    var lat = coord['lat'];
    var long = coord['lon'];
    var response = await http.post(
      Uri.parse('https://travelbot-a2mf.onrender.com/process_prompt/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': text, 'lat': lat, 'lon': long}),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      var resultCode = responseBody['result'][0];

      if (resultCode == 2) {
        var weatherData = WeatherData.fromJson(responseBody['result'][2]);
        setState(() {
          addMessage({
            'text': formatWeatherData(weatherData),
            'isUserMessage': false,
            'isWeatherMessage': true,
          });
        });
      } else {
        var replyText = responseBody['result'][1];
        print(response.body);
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        coordinates = jsonData['result'][2].cast<double>();

        setState(() {
          addMessage({
            'text': replyText,
            'isUserMessage': false,
          });
          showButtons = true;
        });
      }
    }
  }

  String formatWeatherData(WeatherData weatherData) {
    String formatTime(int timestamp) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          .toLocal()
          .toIso8601String()
          .split('T')[1]
          .substring(0, 5);
    }

    String formatTemperature(double value) {
      return (value - 273.15).toStringAsFixed(2);
    }

    final Map<String, dynamic> formattedData = {
      'City': weatherData.cityName,
      'Temperature': '${formatTemperature(weatherData.temp)} °C',
      'Feels Like': '${formatTemperature(weatherData.feelsLike)} °C',
      'Min Temperature': '${formatTemperature(weatherData.tempMin)} °C',
      'Max Temperature': '${formatTemperature(weatherData.tempMax)} °C',
      'Weather':
          '${weatherData.weatherMain} (${weatherData.weatherDescription})',
      'Pressure': '${weatherData.pressure} hPa',
      'Humidity': '${weatherData.humidity}%',
      'Visibility': '${weatherData.visibility} m',
      'Wind Speed': '${weatherData.windSpeed} m/s',
      'Wind Degree': '${weatherData.windDeg}°',
      'Wind Gust': '${weatherData.windGust} m/s',
      'Cloudiness': '${weatherData.cloudiness}%',
      'Sunrise': formatTime(weatherData.sunrise),
      'Sunset': formatTime(weatherData.sunset),
    };

    final jsonString = jsonEncode(formattedData);

    print(jsonString);

    return '''
    City: ${weatherData.cityName},
    Temperature: ${formatTemperature(weatherData.temp)} °C,
    Feels Like: ${formatTemperature(weatherData.feelsLike)} °C,
    Min Temperature: ${formatTemperature(weatherData.tempMin)} °C,
    Max Temperature: ${formatTemperature(weatherData.tempMax)} °C,
    Weather: ${weatherData.weatherMain} (${weatherData.weatherDescription}),
    Pressure: ${weatherData.pressure} hPa,
    Humidity: ${weatherData.humidity}%, 
    Visibility: ${weatherData.visibility} m,
    Wind Speed: ${weatherData.windSpeed} m/s,
    Wind Degree: ${weatherData.windDeg}°,
    Wind Gust: ${weatherData.windGust} m/s,
    Cloudiness: ${weatherData.cloudiness}%, 
    Sunrise: ${formatTime(weatherData.sunrise)},
    Sunset: ${formatTime(weatherData.sunset)},
    ''';
  }

  void addMessage(Map<String, dynamic> message) {
    messages.add(message);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

class Body extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final bool showButtons;
  final List<double> coordinates;

  const Body({
    Key? key,
    this.messages = const [],
    required this.showButtons,
    required this.coordinates,
  }) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, i) {
              var obj = widget.messages[widget.messages.length - 1 - i];
              bool isUserMessage = obj['isUserMessage'] ?? false;
              bool isWeatherMessage = obj['isWeatherMessage'] ?? false;
              return Row(
                mainAxisAlignment: isUserMessage
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MessageContainer(
                    text: obj['text'],
                    isUserMessage: isUserMessage,
                    isWeatherMessage: isWeatherMessage,
                  ),
                ],
              );
            },
            separatorBuilder: (_, i) => Container(height: 10),
            itemCount: widget.messages.length,
            reverse: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
          ),
        ),
        if (widget.showButtons)
          ButtonRow(
            coordinates: widget.coordinates,
          ),
      ],
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  final bool isWeatherMessage;

  const _MessageContainer({
    Key? key,
    required this.text,
    this.isUserMessage = false,
    this.isWeatherMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> lines = text.split(',');

    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constrains) {
          return Container(
            decoration: BoxDecoration(
              color: isUserMessage ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) => Text(line)).toList(),
            ),
          );
        },
      ),
    );
  }
}

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
            onPressed: () {
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
            onPressed: () {},
            child: Text('Get Traffic Information'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            child: Text('Get Incidents Information'),
          ),
        ],
      ),
    );
  }
}
