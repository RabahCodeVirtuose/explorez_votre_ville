// lib/models/ville.dart

/// Modèle aligné avec la table `ville`
class Ville {
  final int? id;
  final String nom;
  final String? pays;
  final double? latitude;
  final double? longitude;

  /// 0 / 1 en base, bool dans le code
  final bool isFavorie;
  final bool isVisitee;
  final bool isExploree;

  Ville({
    this.id,
    required this.nom,
    this.pays,
    this.latitude,
    this.longitude,
    this.isFavorie = false,
    this.isVisitee = false,
    this.isExploree = false,
  });

  Ville copyWith({
    int? id,
    String? nom,
    String? pays,
    double? latitude,
    double? longitude,
    bool? isFavorie,
    bool? isVisitee,
    bool? isExploree,
  }) {
    return Ville(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      pays: pays ?? this.pays,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorie: isFavorie ?? this.isFavorie,
      isVisitee: isVisitee ?? this.isVisitee,
      isExploree: isExploree ?? this.isExploree,
    );
  }

  /// Conversion Map -> Ville (lecture SQLite)
  factory Ville.fromMap(Map<String, dynamic> map) {
    return Ville(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      pays: map['pays'] as String?,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      isFavorie: (map['is_favorie'] ?? 0) == 1,
      isVisitee: (map['is_visitee'] ?? 0) == 1,
      isExploree: (map['is_exploree'] ?? 0) == 1,
    );
  }

  /// Conversion Ville -> Map (écriture SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'pays': pays,
      'latitude': latitude,
      'longitude': longitude,
      'is_favorie': isFavorie ? 1 : 0,
      'is_visitee': isVisitee ? 1 : 0,
      'is_exploree': isExploree ? 1 : 0,
    };
  }
}
