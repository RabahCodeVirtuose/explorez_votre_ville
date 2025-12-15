//
// Ce widget affiche une rangée de ChoiceChip pour choisir un type de lieu
// On lui donne
// selected le type actuellement sélectionné
// onSelected la fonction à appeler quand on change de type
//
// L UI reste simple
// On scrolle horizontalement si ça ne rentre pas

import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

class LieuTypeChips extends StatelessWidget {
  // Type actuellement sélectionné
  final LieuType selected;

  // Fonction appelée quand on clique sur une chip
  final ValueChanged<LieuType> onSelected;

  const LieuTypeChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // On récupère le ColorScheme du thème pour rester cohérent avec le mode clair ou sombre
    final cs = Theme.of(context).colorScheme;

    // SingleChildScrollView permet de scroller horizontalement si on a trop de chips
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // On parcourt tous les types possibles définis dans l enum LieuType
          for (final t in LieuType.values)
            Padding(
              // Petite marge à droite pour séparer les chips entre elles
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                // On affiche une petite icône à gauche du label
                // La couleur dépend du type
                avatar: Icon(
                  LieuTypeHelper.icon(t),
                  color: LieuTypeHelper.color(t),
                  size: 18,
                ),

                // Le texte affiché dans la chip
                // label est un texte lisible pour l utilisateur
                label: Text(
                  LieuTypeHelper.label(t),
                  style: TextStyle(color: cs.onSurface),
                ),

                // selected vaut true si cette chip correspond au type actuellement sélectionné
                selected: selected == t,

                // On colore légèrement l arrière plan quand la chip est sélectionnée
                selectedColor: LieuTypeHelper.color(t).withOpacity(0.2),

                // Couleur de fond quand la chip n est pas sélectionnée
                backgroundColor: cs.surface,

                // Bordure colorée selon le type
                side: BorderSide(color: LieuTypeHelper.color(t), width: 1.2),

                // Quand on clique on renvoie le type t au parent
                // Le parent mettra à jour son état et rappellera ce widget avec un nouveau selected
                onSelected: (_) => onSelected(t),

                // On enlève le checkmark par défaut pour garder un style plus simple
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}
