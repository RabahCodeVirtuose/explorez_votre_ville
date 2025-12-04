// lib/utils/lieu_type_mapper.dart

import '../models/lieu_type.dart';

/// Traduit notre enumeration `LieuType` en categories Geoapify valides.
String geoapifyCategoryFromLieuType(LieuType type) {
  switch (type) {
    case LieuType.musee:
      return 'entertainment.museum';
    case LieuType.parc:
      return 'leisure.park';
    case LieuType.restaurant:
      return 'catering.restaurant';
    case LieuType.cafe:
      return 'catering.cafe';
    case LieuType.monument:
      return 'tourism.sights';
    case LieuType.stade:
      return 'sport.stadium';
    case LieuType.theatre:
      return 'entertainment.culture.theatre';
    case LieuType.cinema:
      return 'entertainment.cinema';
    case LieuType.salleConcert:
      return 'entertainment.culture.arts_centre';
  }
}
