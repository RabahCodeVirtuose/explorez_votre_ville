// lib/api/api_meteo.dart
//
// Ici on gère uniquement les appels HTTP vers OpenWeatherMap
// On peut récupérer la météo soit par nom de ville soit par coordonnées
// Les données reçues sont transformées en objet WeatherData

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

/// Clé OpenWeatherMap
/// Pour un projet de cours on peut la laisser ici
const String _owmApiKey = '6f898415520ca9f95850d8ce6f43f075';

/// Classe qui s occupe uniquement des appels réseau
/// On utilise des méthodes statiques car on n a pas besoin d état
class ApiMeteo {
  /// Cette méthode construit l URL avec les paramètres nécessaires
  /// On évite de concaténer des strings à la main
  static Uri _buildUri(Map<String, String> query) {
    // Paramètres communs à toutes les requêtes
    final fullQuery = <String, String>{
      ...query,
      'appid': _owmApiKey,
      'units': 'metric', // température en degrés Celsius
      'lang': 'fr', // description en français
    };

    return Uri.https('api.openweathermap.org', '/data/2.5/weather', fullQuery);
  }

  /// Cette méthode envoie la requête HTTP
  /// On vérifie le code retour puis on transforme le JSON
  static Future<WeatherData> _getWeather(Uri uri) async {
    final response = await http.get(uri);

    // Si la requête fonctionne
    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WeatherData.fromJson(json);
    }

    // Sinon on remonte une erreur claire
    throw Exception('Erreur API météo ${response.statusCode} ${response.body}');
  }

  /// Récupère la météo à partir du nom d une ville
  /// Exemple Paris
  static Future<WeatherData> fetchParVille(String city) async {
    // On enlève les espaces inutiles
    final ville = city.trim();

    // On prépare l URL avec le paramètre q
    final uri = _buildUri({'q': ville});

    return _getWeather(uri);
  }

  /// Récupère la météo à partir des coordonnées GPS
  /// latitude et longitude
  static Future<WeatherData> fetchParCoordonnees({
    required double latitude,
    required double longitude,
  }) async {
    // L API attend des chaînes de caractères
    final uri = _buildUri({
      'lat': latitude.toString(),
      'lon': longitude.toString(),
    });

    return _getWeather(uri);
  }
}
