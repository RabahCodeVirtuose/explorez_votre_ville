//
// Cette classe représente une ville dans l application
// Elle correspond à la table ville dans SQLite
// On garde les mêmes champs pour que ce soit simple à lire et à enregistrer

class Ville {
  // id est null quand la ville n est pas encore enregistrée en base
  final int? id;

  // nom est obligatoire car la table impose NOT NULL
  final String nom;

  // pays et coordonnées peuvent être null
  final String? pays;
  final double? latitude;
  final double? longitude;

  // En base on stocke 0 ou 1
  // Dans le code on préfère utiliser des bool
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

  // On utilise copyWith pour créer une copie modifiée
  // Ça évite de tout reconstruire à la main
  // Exemple on change juste isFavorie sans toucher au reste
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

  // On transforme une ligne SQLite en objet Ville
  // map vient généralement de db query
  factory Ville.fromMap(Map<String, dynamic> map) {
    return Ville(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      pays: map['pays'] as String?,
      latitude: map['latitude'] == null
          ? null
          : (map['latitude'] as num).toDouble(),
      longitude: map['longitude'] == null
          ? null
          : (map['longitude'] as num).toDouble(),
      isFavorie: (map['is_favorie'] ?? 0) == 1,
      isVisitee: (map['is_visitee'] ?? 0) == 1,
      isExploree: (map['is_exploree'] ?? 0) == 1,
    );
  }

  // On transforme un objet Ville en Map pour l insertion ou la mise à jour
  // Les bool deviennent 1 ou 0 car SQLite n a pas de type bool natif
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
