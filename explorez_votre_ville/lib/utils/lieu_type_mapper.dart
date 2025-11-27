// lib/utils/lieu_type_mapper.dart

import '../models/lieu_type.dart';

/// Traduit notre énumération métier `LieuType`
/// en catégories Geoapify (`categories=`).
///
/// La doc Geoapify autorise plusieurs catégories séparées par des virgules.
/// Ici on commence simple : 1 (ou 2) catégories par type.
String geoapifyCategoryFromLieuType(LieuType type) {
       switch (type) {
    case LieuType.musee:
      // Musées / lieux culturels
      return 'tourism.museum';

    case LieuType.parc:
      // Parcs, jardins…
      return 'leisure.park';

    case LieuType.restaurant:
      // Tous types de restaurants
      return 'catering.restaurant';

    case LieuType.cafe:
      // Cafés, salons de thé, etc.
      return 'catering.cafe';

    case LieuType.monument:
      // Monuments & points d’intérêt
      return 'tourism.sights,heritage';

    case LieuType.stade:
      return 'sport.stadium';

    case LieuType.theatre:
      return 'entertainment.culture.theatre';

    case LieuType.cinema:
      return 'entertainment.cinema';

    case LieuType.salleConcert:
      // Centres / salles culturelles
      return 'entertainment.culture.arts_centre';

  
  }
}
