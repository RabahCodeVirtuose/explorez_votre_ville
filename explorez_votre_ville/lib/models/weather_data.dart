//
// Cette classe représente la météo qu on affiche dans l application
// Elle est construite à partir du JSON de OpenWeatherMap
// On garde seulement les infos utiles pour l écran

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

  // Coordonnées de la ville renvoyées par l API
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

  // On crée un objet WeatherData depuis le JSON de l API
  // Certaines valeurs sont dans main d autres dans wind et coord
  // weather est une liste donc on prend le premier élément
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather0 = (json['weather'] as List?)?.isNotEmpty == true
        ? (json['weather'] as List).first as Map<String, dynamic>
        : <String, dynamic>{};

    final main = (json['main'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final wind = (json['wind'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final coord =
        (json['coord'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return WeatherData(
      cityName: (json['name'] as String?) ?? '',
      description: (weather0['description'] as String?) ?? '',
      icon: (weather0['icon'] as String?) ?? '',
      temperature: ((main['temp'] as num?) ?? 0).toDouble(),
      temperatureMin: ((main['temp_min'] as num?) ?? 0).toDouble(),
      temperatureMax: ((main['temp_max'] as num?) ?? 0).toDouble(),
      humidity: (main['humidity'] as int?) ?? 0,
      windSpeed: ((wind['speed'] as num?) ?? 0).toDouble(),
      coordonnees: LatLng(
        ((coord['lat'] as num?) ?? 0).toDouble(),
        ((coord['lon'] as num?) ?? 0).toDouble(),
      ),
    );
  }
}
