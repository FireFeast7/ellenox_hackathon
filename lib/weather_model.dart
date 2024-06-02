import 'dart:convert';

class WeatherData {
  final double lat;
  final double lon;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int visibility;
  final double windSpeed;
  final int windDeg;
  final double windGust;
  final int cloudiness;
  final int sunrise;
  final int sunset;
  final String cityName;

  WeatherData({
    required this.lat,
    required this.lon,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.windGust,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      lat: json['coord']['lat'],
      lon: json['coord']['lon'],
      weatherMain: json['weather'][0]['main'],
      weatherDescription: json['weather'][0]['description'],
      weatherIcon: json['weather'][0]['icon'],
      temp: json['main']['temp'],
      feelsLike: json['main']['feels_like'],
      tempMin: json['main']['temp_min'],
      tempMax: json['main']['temp_max'],
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      visibility: json['visibility'],
      windSpeed: json['wind']['speed'],
      windDeg: json['wind']['deg'],
      windGust: json['wind']['gust'],
      cloudiness: json['clouds']['all'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      cityName: json['name'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      'temp': temp,
      'feelsLike': feelsLike,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'weatherMain': weatherMain,
      'weatherDescription': weatherDescription,
      'pressure': pressure,
      'humidity': humidity,
      'visibility': visibility,
      'windSpeed': windSpeed,
      'windDeg': windDeg,
      'windGust': windGust,
      'cloudiness': cloudiness,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }
}
