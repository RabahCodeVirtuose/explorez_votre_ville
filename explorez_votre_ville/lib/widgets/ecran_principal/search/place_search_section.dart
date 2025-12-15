//
// Cette section regroupe tout ce qui concerne la recherche de lieux
// On a
// un champ de recherche pour taper une ville ou un lieu
// un indicateur de chargement quand on attend une réponse
// une zone d erreur si quelque chose se passe mal
// une liste de chips pour choisir le type de lieu

import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/search/lieu_type_chips.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/search/search_bar.dart';
import 'package:explorez_votre_ville/widgets/status/error_banner.dart';
import 'package:flutter/material.dart';

class PlaceSearchSection extends StatelessWidget {
  // Controller du champ de recherche
  final TextEditingController controller;

  // Fonction appelée quand on valide la recherche
  final ValueChanged<String> onSubmit;

  // loading permet d afficher une barre de progression
  final bool loading;

  // error contient le message d erreur à afficher si besoin
  final String? error;

  // Type sélectionné dans les chips
  final LieuType selectedType;

  // Fonction appelée quand on change de type
  final ValueChanged<LieuType> onTypeChanged;

  const PlaceSearchSection({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.loading,
    required this.error,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // On récupère les couleurs du thème pour rester cohérent
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ de recherche
        SearchBarField(controller: controller, onSubmitted: onSubmit),

        const SizedBox(height: 8),

        // Si on charge on affiche une progression fine
        if (loading)
          LinearProgressIndicator(
            color: cs.primary,
            backgroundColor: cs.surfaceVariant,
          ),

        // Si on a une erreur on l affiche sous le champ
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ErrorBanner(message: error!),
          ),

        const SizedBox(height: 8),

        // Chips de sélection du type
        // Quand on clique on appelle onTypeChanged dans le parent
        LieuTypeChips(selected: selectedType, onSelected: onTypeChanged),
      ],
    );
  }
}
