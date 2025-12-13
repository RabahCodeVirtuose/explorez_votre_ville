// lib/api/api_villes.dart
//
// Rassemble tous les appels API liés aux villes et aux lieux :
// - Nominatim (OpenStreetMap) pour trouver une ville + son bounding box
// - Geoapify /places et /geocode/search pour récupérer des lieux (POI)
//
// Modèles internes :
// - BoundingBoxVille : rectangle géographique (latMin/latMax/lonMin/lonMax)
// - VilleApiResult  : ville simplifiée (nom + coords + bbox)
// - LieuApiResult   : lieu simplifié (nom + coords + adresse + catégories)
//
// Fonctions clés :
// - fetchVillesDepuisNominatimList : renvoie plusieurs villes possibles pour un nom
// - fetchVilleDepuisNominatim      : compat, renvoie la première
// - fetchLieuxPourVille            : lieux d’un type donné dans le bbox d’une ville
// - fetchLieuxParNomDansVille      : lieux par nom dans le bbox, avec option de filtre par type

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/lieu_type.dart';
import '../utils/lieu_type_mapper.dart';

/// Clé Geoapify (places) – utilisée pour /places et /geocode/search
const String _geoapifyApiKey = '398f2bfe6c7b42f383d68f82511996d8';

/// User-Agent exigé par Nominatim (respect de la politique d’usage).
const String _nominatimUserAgent =
    'ExploreVille/1.0 (contact: rabah.toubal.etudes@gmail.com)';

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

  /// Factory à partir du JSON Nominatim (un élément de la liste).
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

  /// Factory à partir d’un "feature" Geoapify (endpoint /v2/places).
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

  /// Factory à partir d’un "feature" Geoapify geocode/search (text search).
  factory LieuApiResult.fromGeoapifyGeocodeFeature(
      Map<String, dynamic> json) {
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

/// Classe qui regroupe tous les appels "villes & lieux".
class ApiVillesEtLieux {
  static const String _nominatimBase = 'nominatim.openstreetmap.org';
  static const String _geoapifyBase = 'api.geoapify.com';

  /// Appel Nominatim : renvoie une liste de villes potentielles pour un nom.
  static Future<List<VilleApiResult>> fetchVillesDepuisNominatimList(
      String nomVille,
      {int limit = 5}) async {
    final uri = Uri.https(
      _nominatimBase,
      '/search',
      {
        'q': nomVille,
        'format': 'json',
        'limit': '$limit',
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

    return body
        .map((e) => VilleApiResult.fromNominatim(e as Map<String, dynamic>))
        .toList();
  }

  /// Compatibilité : renvoie uniquement la première ville (usage existant).
  static Future<VilleApiResult> fetchVilleDepuisNominatim(
      String nomVille) async {
    final list = await fetchVillesDepuisNominatimList(nomVille, limit: 1);
    return list.first;
  }

  /// Appel Geoapify : récupère les lieux d’un type donné dans le bounding box d’une ville.
  static Future<List<LieuApiResult>> fetchLieuxPourVille({
    required LieuType type,
    int limit = 15,
    BoundingBoxVille? bboxOverride,
  }) async {
    // a) Bounding box : override fourni ou Nominatim
    final BoundingBoxVille bbox;
      bbox = bboxOverride!;
    
    // Nominatim => bbox [lat_min, lat_max, lon_min, lon_max]
    // Geoapify => filter=rect:lon_min,lat_min,lon_max,lat_max
    final rectFilter =
        'rect:${bbox.lonMin},${bbox.latMin},${bbox.lonMax},${bbox.latMax}';

    // b) Traduire le type métier en catégorie Geoapify.
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

  /// Recherche d’un lieu par son nom à l’intérieur du bounding box d’une ville.
  /// - Si [bboxOverride] est fourni, aucune requête Nominatim n’est refaite.
  /// - Si [type] est fourni, on utilise /v2/places avec categories + filter rect.
  ///   sinon on reste sur geocode/search (bounds + text).
  static Future<List<LieuApiResult>> fetchLieuxParNomDansVille({
    required String nomLieu,
    LieuType? type, // optionnel : filtre par type connu dans l'app
    int limit = 10,
    BoundingBoxVille? bboxOverride,
  }) async {
    // 1) Bounding box : override ou Nominatim
    late final BoundingBoxVille bbox;
      bbox = bboxOverride!;
   

    // 2) Construire "bounds" pour Geoapify
    final bounds =
        '${bbox.lonMin},${bbox.latMin},${bbox.lonMax},${bbox.latMax}';

    // 3) Appel Geoapify : /v2/places si type, sinon geocode/search
    late final Uri uri;
    if (type != null) {
      uri = Uri.https(
        _geoapifyBase,
        '/v2/places',
        {
          'categories': geoapifyCategoryFromLieuType(type),
          'filter': 'rect:$bounds',
          'text': nomLieu,
          'limit': '$limit',
          'lang': 'fr',
          'apiKey': _geoapifyApiKey,
        },
      );
    } else {
      uri = Uri.https(
        _geoapifyBase,
        '/v1/geocode/search',
        {
          'text': nomLieu,
          'bounds': bounds,
          'limit': '$limit',
          'lang': 'fr',
          'apiKey': _geoapifyApiKey,
        },
      );
    }

    final response = await http.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur Geoapify geocoding (${response.statusCode}) : ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final features = json['features'] as List<dynamic>? ?? [];

    return features
        .map(
          (f) => LieuApiResult.fromGeoapifyGeocodeFeature(
            f as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
