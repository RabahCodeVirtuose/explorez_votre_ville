// lib/api/api_meteo.dart
//
// Encapsule les appels HTTP à l'API OpenWeatherMap :
// - fetchParVille       : météo par nom de ville (requête "q=")
// - fetchParCoordonnees : météo par latitude/longitude
//
// Les données retournées sont converties en WeatherData (modèle interne).

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

/// Clé OpenWeatherMap (remplacer par votre propre clé si besoin)
const String _owmApiKey = '6f898415520ca9f95850d8ce6f43f075';

/// Base d'URL OpenWeather (endpoint météo courante).
const String _owmBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';

/// Classe responsable uniquement des appels réseau vers OpenWeather.
class ApiMeteo {
  /// Récupère la météo par nom de ville.
  ///
  /// Exemple d'URL : https://api.openweathermap.org/data/2.5/weather
  ///   ?q=Paris&appid=VOTRE_CLE&units=metric&lang=fr
  static Future<WeatherData> fetchParVille(String city) async {
    final uri = Uri.parse(
      '$_owmBaseUrl?q=$city&appid=$_owmApiKey&units=metric&lang=fr',
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
  /// Exemple d'URL : https://api.openweathermap.org/data/2.5/weather
  ///   ?lat=48.85&lon=2.35&appid=VOTRE_CLE&units=metric&lang=fr
  static Future<WeatherData> fetchParCoordonnees({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_owmBaseUrl?lat=$latitude&lon=$longitude&appid=$_owmApiKey&units=metric&lang=fr',
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
