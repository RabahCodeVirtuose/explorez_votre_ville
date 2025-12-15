//
// Ici on regroupe les appels API liés aux villes et aux lieux
// On utilise Nominatim pour trouver une ville et sa bounding box
// On utilise Geoapify pour chercher des lieux dans une zone
//
// On garde des petits modèles simples
// BoundingBoxVille pour la zone
// VilleApiResult pour une ville
// LieuApiResult pour un lieu
//
// Objectif du fichier
// On évite de mélanger l API et l interface
// L écran appelle ces fonctions et récupère des objets faciles à utiliser

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/lieu_type.dart';
import '../utils/lieu_type_mapper.dart';

/// Clé Geoapify utilisée pour les requêtes places et geocode
const String _geoapifyApiKey = '398f2bfe6c7b42f383d68f82511996d8';

/// User Agent imposé par Nominatim
const String _nominatimUserAgent =
    'ExploreVille/1.0 (contact: rabah.toubal.etudes@gmail.com)';

/// Petite classe pour représenter la zone d une ville
/// On utilise latMin latMax lonMin lonMax
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

/// Résultat simplifié d une ville depuis Nominatim
/// On garde le nom les coordonnées et la zone bbox
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

  /// On construit l objet à partir d un élément JSON Nominatim
  /// Nominatim donne boundingbox sous forme de liste de strings
  factory VilleApiResult.fromNominatim(Map<String, dynamic> json) {
    final bbox = json['boundingbox'] as List<dynamic>;

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

/// Résultat simplifié d un lieu depuis Geoapify
/// On garde le nom les coordonnées une adresse lisible et les catégories
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

  /// On construit l objet à partir d un feature Geoapify
  /// Les propriétés importantes sont dans properties
  factory LieuApiResult.fromGeoapifyFeature(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>;

    return LieuApiResult(
      name: (props['name'] ?? '') as String,
      lat: (props['lat'] as num).toDouble(),
      lon: (props['lon'] as num).toDouble(),
      formattedAddress: (props['formatted'] ?? '') as String,
      categories:
          (props['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// Même logique mais pour le endpoint geocode search
  /// La structure est très proche donc on réutilise le même mapping
  factory LieuApiResult.fromGeoapifyGeocodeFeature(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>;

    return LieuApiResult(
      name: (props['name'] ?? '') as String,
      lat: (props['lat'] as num).toDouble(),
      lon: (props['lon'] as num).toDouble(),
      formattedAddress: (props['formatted'] ?? '') as String,
      categories:
          (props['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// Classe qui regroupe les appels villes et lieux
/// On met tout en static car on n a pas besoin de stocker un état ici
class ApiVillesEtLieux {
  static const String _nominatimBase = 'nominatim.openstreetmap.org';
  static const String _geoapifyBase = 'api.geoapify.com';

  /// Helper pour faire un GET et vérifier le code retour
  /// On garde ce code une fois au lieu de le répéter partout
  static Future<dynamic> _getJson(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Erreur API ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body);
  }

  /// Helper pour construire le filtre rect de Geoapify
  /// Geoapify attend lonMin latMin lonMax latMax
  static String _rectFilterFromBbox(BoundingBoxVille bbox) {
    return 'rect:${bbox.lonMin},${bbox.latMin},${bbox.lonMax},${bbox.latMax}';
  }

  /// Appel Nominatim
  /// On demande plusieurs villes possibles car un nom peut être ambigu
  static Future<List<VilleApiResult>> fetchVillesDepuisNominatimList(
    String nomVille, {
    int limit = 5,
  }) async {
    final uri = Uri.https(_nominatimBase, '/search', {
      'q': nomVille.trim(),
      'format': 'json',
      'limit': '$limit',
    });

    final json = await _getJson(
      uri,
      headers: {
        'User-Agent': _nominatimUserAgent,
        'Accept': 'application/json',
      },
    );

    final body = json as List<dynamic>;

    if (body.isEmpty) {
      throw Exception('Aucune ville trouvée pour "$nomVille"');
    }

    return body
        .map((e) => VilleApiResult.fromNominatim(e as Map<String, dynamic>))
        .toList();
  }

  /// Compat
  /// On garde cette méthode car peut être que d autres écrans l utilisent déjà
  /// Ici on prend juste le premier résultat
  static Future<VilleApiResult> fetchVilleDepuisNominatim(
    String nomVille,
  ) async {
    final list = await fetchVillesDepuisNominatimList(nomVille, limit: 1);
    return list.first;
  }

  /// Appel Geoapify places
  /// On récupère des lieux d un type donné dans une zone bbox
  /// Important
  /// Si bboxOverride est null on ne peut pas deviner la zone ici
  /// Donc on exige bboxOverride pour éviter une requête cachée et ambiguë
  static Future<List<LieuApiResult>> fetchLieuxPourVille({
    required LieuType type,
    required BoundingBoxVille bboxOverride,
    int limit = 15,
  }) async {
    final rectFilter = _rectFilterFromBbox(bboxOverride);

    final categories = geoapifyCategoryFromLieuType(type);

    final uri = Uri.https(_geoapifyBase, '/v2/places', {
      'categories': categories,
      'filter': rectFilter,
      'limit': '$limit',
      'lang': 'fr',
      'apiKey': _geoapifyApiKey,
    });

    final json = await _getJson(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    final body = json as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? [];

    return features
        .map(
          (f) => LieuApiResult.fromGeoapifyFeature(f as Map<String, dynamic>),
        )
        .toList();
  }

  /// Recherche par nom dans une ville
  /// On travaille dans les limites de bbox
  /// Si type est donné on passe par places avec categories et rect
  /// Sinon on passe par geocode search avec bounds et text
  static Future<List<LieuApiResult>> fetchLieuxParNomDansVille({
    required String nomLieu,
    required BoundingBoxVille bboxOverride,
    LieuType? type,
    int limit = 10,
  }) async {
    final bounds =
        '${bboxOverride.lonMin},${bboxOverride.latMin},${bboxOverride.lonMax},${bboxOverride.latMax}';

    late final Uri uri;

    if (type != null) {
      uri = Uri.https(_geoapifyBase, '/v2/places', {
        'categories': geoapifyCategoryFromLieuType(type),
        'filter': 'rect:$bounds',
        'text': nomLieu.trim(),
        'limit': '$limit',
        'lang': 'fr',
        'apiKey': _geoapifyApiKey,
      });
    } else {
      uri = Uri.https(_geoapifyBase, '/v1/geocode/search', {
        'text': nomLieu.trim(),
        'bounds': bounds,
        'limit': '$limit',
        'lang': 'fr',
        'apiKey': _geoapifyApiKey,
      });
    }

    final json = await _getJson(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    final body = json as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? [];

    return features
        .map(
          (f) => LieuApiResult.fromGeoapifyGeocodeFeature(
            f as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
