// lib/models/lieu_type.dart

/// Types possibles de lieux dans l'application.
/// Le texte stocké en base sera le name() de l'énum (musee, parc, restaurant, ...).
enum LieuType {
  musee,
  parc,
  restaurant,
  cafe,
  monument,
  stade,
  theatre,
  cinema,
  salleConcert,
}

class LieuTypeHelper {
  /// Convertit une chaîne de la base (ex: "musee") en valeur de l'énumération.
  static LieuType fromDb(String value) {
    return LieuType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => LieuType.musee,
    );
  }

  /// Convertit une valeur de l'énum en chaîne pour la base (ex: "musee").
  static String toDb(LieuType type) => type.name;

  /// Libellé lisible pour l'UI.
  static String label(LieuType type) {
    switch (type) {
      case LieuType.musee:
        return 'Musée';
      case LieuType.parc:
        return 'Parc';
      case LieuType.restaurant:
        return 'Restaurant';
      case LieuType.cafe:
        return 'Café';
      case LieuType.monument:
        return 'Monument';
      case LieuType.stade:
        return 'Stade';
      case LieuType.theatre:
        return 'Théâtre';
      case LieuType.cinema:
        return 'Cinéma';
      case LieuType.salleConcert:
        return 'Salle de concert';
    }
  }
}
