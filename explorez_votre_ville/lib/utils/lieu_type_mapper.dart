//
// Ici on fait la traduction entre notre enum LieuType et les catégories Geoapify
// Geoapify attend des strings précises comme catering cafe ou leisure park
// On centralise ça ici pour éviter de recopier les strings partout

import '../models/lieu_type.dart';

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
