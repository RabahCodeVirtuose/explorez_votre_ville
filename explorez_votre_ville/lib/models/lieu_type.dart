import 'package:flutter/material.dart';

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

  /// Icône Material associée à chaque type (fallback: location_on).
  static IconData icon(LieuType type) {
    switch (type) {
      case LieuType.musee:
        return Icons.museum;
      case LieuType.parc:
        return Icons.park;
      case LieuType.restaurant:
        return Icons.restaurant;
      case LieuType.cafe:
        return Icons.local_cafe;
      case LieuType.monument:
        return Icons.castle;
      case LieuType.stade:
        return Icons.stadium;
      case LieuType.theatre:
        return Icons.theater_comedy;
      case LieuType.cinema:
        return Icons.movie;
      case LieuType.salleConcert:
        return Icons.church; // proche visuel pour salle de concert
    }
  }

  /// Couleur associée à chaque type (pour les icônes ou chips).
  static Color color(LieuType type) {
    switch (type) {
      case LieuType.musee:
        return Colors.deepPurple;
      case LieuType.parc:
        return Colors.green;
      case LieuType.restaurant:
        return Colors.orange;
      case LieuType.cafe:
        return Colors.brown;
      case LieuType.monument:
        return Colors.indigo;
      case LieuType.stade:
        return Colors.teal;
      case LieuType.theatre:
        return Colors.redAccent;
      case LieuType.cinema:
        return Colors.blueGrey;
      case LieuType.salleConcert:
        return Colors.pinkAccent;
    }
  }
}
