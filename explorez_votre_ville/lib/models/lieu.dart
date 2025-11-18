// lib/models/lieu.dart

import 'lieu_type.dart';

/// Modèle aligné avec la table `lieu`
class Lieu {
  final int? id;
  final int villeId;
  final String nom;
  final LieuType type;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? imagePath;

  Lieu({
    this.id,
    required this.villeId,
    required this.nom,
    required this.type,
    this.description,
    this.latitude,
    this.longitude,
    this.imagePath,
  });

  Lieu copyWith({
    int? id,
    int? villeId,
    String? nom,
    LieuType? type,
    String? description,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) {
    return Lieu(
      id: id ?? this.id,
      villeId: villeId ?? this.villeId,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  /// Conversion Map -> Lieu (lecture SQLite)
  factory Lieu.fromMap(Map<String, dynamic> map) {
    return Lieu(
      id: map['id'] as int?,
      villeId: map['ville_id'] as int,
      nom: map['nom'] as String,
      type: LieuTypeHelper.fromDb(map['type'] as String),
      description: map['description'] as String?,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      imagePath: map['image_path'] as String?,
    );
  }

  /// Conversion Lieu -> Map (écriture SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ville_id': villeId,
      'nom': nom,
      'type': LieuTypeHelper.toDb(type),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'image_path': imagePath,
    };
  }
}
