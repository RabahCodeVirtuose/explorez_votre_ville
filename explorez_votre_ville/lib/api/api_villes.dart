// lib/api/api_villes.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/lieu_type.dart';
import '../utils/lieu_type_mapper.dart';

/// Clé Geoapify (places)
const String _geoapifyApiKey = '398f2bfe6c7b42f383d68f82511996d8';

/// User-Agent exigé par Nominatim (respect de la politique d’usage).
const String _nominatimUserAgent =
    'ExploreVille/1.0 (contact: rabah.toubal.etudes@gmail.com)';

/// ---
///  DTO internes pour isoler les réponses API
/// ---

/// Bounding box d’une ville (rectangle géographique).
class BoundingBoxVille {
  final double latMin;
  final double latMax;
  final double lonMin;
  final double lonMax;

  const BoundingBoxVille({
    required this.latMin,
    required this.latMax,
    required this.lonMin,
    required this.lonMax,
  });
}

/// Résultat Nominatim simplifié pour une ville.
class VilleApiResult {
  final String name;
  final double lat;
  final double lon;
  final BoundingBoxVille bbox;

  VilleApiResult({
    required this.name,
    required this.lat,
    required this.lon,
    required this.bbox,
  });

  /// Factory à partir du JSON Nominatim (1 élément de la liste).
  factory VilleApiResult.fromNominatim(Map<String, dynamic> json) {
    final bbox = json['boundingbox'] as List<dynamic>;
    // Nominatim renvoie [lat_min, lat_max, lon_min, lon_max] (en chaînes)
    final latMin = double.parse(bbox[0] as String);
    final latMax = double.parse(bbox[1] as String);
    final lonMin = double.parse(bbox[2] as String);
    final lonMax = double.parse(bbox[3] as String);

    return VilleApiResult(
      name: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
      bbox: BoundingBoxVille(
        latMin: latMin,
        latMax: latMax,
        lonMin: lonMin,
        lonMax: lonMax,
      ),
    );
  }
}

/// Résultat Geoapify simplifié pour un lieu.
class LieuApiResult {
  final String name;
  final double lat;
  final double lon;
  final String formattedAddress;
  final List<String> categories;

  LieuApiResult({
    required this.name,
    required this.lat,
    required this.lon,
    required this.formattedAddress,
    required this.categories,
  });

  /// Factory à partir d’un "feature" Geoapify.
  factory LieuApiResult.fromGeoapifyFeature(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>;

    return LieuApiResult(
      name: (props['name'] ?? '') as String,
      lat: (props['lat'] as num).toDouble(),
      lon: (props['lon'] as num).toDouble(),
      formattedAddress: (props['formatted'] ?? '') as String,
      categories: (props['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// ---
///  Classe qui regroupe tous les appels "villes & lieux"
/// ---
class ApiVillesEtLieux {
  static const String _nominatimBase = 'nominatim.openstreetmap.org';
  static const String _geoapifyBase = 'api.geoapify.com';

  /// 1) Appel Nominatim : récupère une ville + son bounding box
  /// à partir du nom saisi par l’utilisateur.
  ///
  /// Exemple Postman :
  /// https://nominatim.openstreetmap.org/search?q=Orleans&format=json&limit=5
       static Future<VilleApiResult> fetchVilleDepuisNominatim(
      String nomVille) async {
    final uri = Uri.https(
      _nominatimBase,
      '/search',
      {
        'q': nomVille,
        'format': 'json',
        'limit': '1', // on ne garde que le meilleur résultat
      },
    );

          final response = await http.get(
      uri,
      headers: {
        'User-Agent': _nominatimUserAgent,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur Nominatim (${response.statusCode}) : ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    if (body.isEmpty) {
      throw Exception('Aucune ville trouvée pour "$nomVille"');
    }

    return VilleApiResult.fromNominatim(
      body.first as Map<String, dynamic>,
    );
  }

  /// 2) Appel Geoapify : récupère les lieux d’un type donné
  /// dans le bounding box d’une ville.
  ///
  /// - [nomVille] : chaîne saisie (ex. "Orléans")
  /// - [type] : type métier (enum LieuType)
  /// - [limit] : nombre max de lieux à retourner
  static Future<List<LieuApiResult>> fetchLieuxPourVille({
    required String nomVille,
    required LieuType type,
    int limit = 15,
  }) async {
    // a) On commence par récupérer la ville et son bbox via Nominatim.
    final ville = await fetchVilleDepuisNominatim(nomVille);
    final bbox = ville.bbox;

    // Nominatim => bbox [lat_min, lat_max, lon_min, lon_max]
    // Geoapify => filter=rect:lon_min,lat_min,lon_max,lat_max
    final rectFilter =
        'rect:${bbox.lonMin},${bbox.latMin},${bbox.lonMax},${bbox.latMax}';

    // b) On traduit le type métier en catégorie Geoapify.
    final categories = geoapifyCategoryFromLieuType(type);

    final uri = Uri.https(
      _geoapifyBase,
      '/v2/places',
      {
        'categories': categories,
        'filter': rectFilter,
        'limit': '$limit',
        'apiKey': _geoapifyApiKey,
      },
    );

    final response = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur Geoapify (${response.statusCode}) : ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? [];

    return features
        .map(
          (f) => LieuApiResult.fromGeoapifyFeature(
            f as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
