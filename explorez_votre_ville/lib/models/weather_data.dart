// lib/models/weather_data.dart
import 'package:latlong2/latlong.dart';

class WeatherData {
  final String cityName;
  final String description;
  final String icon;
  final double temperature;
  final double temperatureMin;
  final double temperatureMax;
  final int humidity;
  final double windSpeed;
  final LatLng coordonnees;

  WeatherData({
    required this.cityName,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.humidity,
    required this.windSpeed,
    required this.coordonnees,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] as String? ?? '',
      description: (json['weather']?[0]?['description'] as String?) ?? '',
      icon: (json['weather']?[0]?['icon'] as String?) ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      temperatureMin: (json['main']['temp_min'] as num).toDouble(),
      temperatureMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      coordonnees: LatLng(
        (json['coord']['lat'] as num).toDouble(),
        (json['coord']['lon'] as num).toDouble(),
      ),
    );
  }
}
