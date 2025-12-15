//
// Cette classe représente un lieu dans l application
// Elle correspond à la table lieu dans SQLite
// Un lieu appartient toujours à une ville grâce à villeId
// Le type est un enum LieuType mais en base on stocke une string

import 'lieu_type.dart';

class Lieu {
  // id est null tant que le lieu n est pas enregistré en base
  final int? id;

  // villeId est obligatoire car la table impose ville_id NOT NULL
  final int villeId;

  // nom est obligatoire
  final String nom;

  // type est obligatoire aussi
  final LieuType type;

  // Le reste peut être null selon les données qu on a
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

  // copyWith sert à créer une copie avec quelques changements
  // On garde le même objet mais on modifie seulement ce qu on veut
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

  // On transforme une ligne SQLite en objet Lieu
  // Le type est stocké en string donc on le convertit avec LieuTypeHelper
  factory Lieu.fromMap(Map<String, dynamic> map) {
    return Lieu(
      id: map['id'] as int?,
      villeId: map['ville_id'] as int,
      nom: map['nom'] as String,
      type: LieuTypeHelper.fromDb(map['type'] as String),
      description: map['description'] as String?,
      latitude: map['latitude'] == null
          ? null
          : (map['latitude'] as num).toDouble(),
      longitude: map['longitude'] == null
          ? null
          : (map['longitude'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
    );
  }

  // On transforme l objet Lieu en Map pour l insertion ou la mise à jour
  // Le type devient une string pour être stocké dans SQLite
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
