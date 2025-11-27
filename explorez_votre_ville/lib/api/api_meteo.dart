// lib/api/api_meteo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

///   clé OpenWeatherMap
const String _owmApiKey = '6f898415520ca9f95850d8ce6f43f075';

/// Classe responsable **uniquement** des appels HTTP vers l'API météo.
/// Toute la logique "réseau" est ici.
class ApiMeteo {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// Récupère la météo par nom de ville.
  ///
  /// Exemple d’URL (à tester dans Postman) :
  /// https://api.openweathermap.org/data/2.5/weather?q=Paris&appid=TA_CLE&units=metric&lang=fr
  static Future<WeatherData> fetchParVille(String city) async {
    final uri = Uri.parse(
      '$_baseUrl?q=$city&appid=$_owmApiKey&units=metric&lang=fr',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } else {
      throw Exception(
        'Erreur API météo (${response.statusCode}) : ${response.body}',
      );
    }
  }

  /// Récupère la météo par coordonnées (latitude / longitude).
  ///
  /// Exemple pour Postman :
  /// https://api.openweathermap.org/data/2.5/weather?lat=48.85&lon=2.35&appid=TA_CLE&units=metric&lang=fr
  static Future<WeatherData> fetchParCoordonnees({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_owmApiKey&units=metric&lang=fr',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } else {
      throw Exception(
        'Erreur API météo (${response.statusCode}) : ${response.body}',
      );
    }
  }
}
