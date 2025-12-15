//
// Ici on définit les types possibles pour un lieu
// On utilise un enum pour éviter les fautes de frappe
// En base on stocke une string qui correspond à type name

import 'package:flutter/material.dart';

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
  // On convertit une string venant de la base en enum
  // Si la valeur est inconnue on met un type par défaut
  static LieuType fromDb(String value) {
    return LieuType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => LieuType.musee,
    );
  }

  // On convertit un enum en string pour pouvoir le stocker en base
  static String toDb(LieuType type) {
    return type.name;
  }

  // On retourne un libellé lisible pour l interface
  // Ça permet d afficher autre chose que musee ou salleConcert
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

  // On associe une icône Material à chaque type
  // Ça aide l utilisateur à comprendre vite
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
        return Icons.music_note;
    }
  }

  // On associe une couleur à chaque type
  // On s en sert pour les icônes ou les petits badges
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
