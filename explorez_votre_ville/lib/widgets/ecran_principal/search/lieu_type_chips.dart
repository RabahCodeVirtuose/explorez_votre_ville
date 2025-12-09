import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

/// Chips de sélection de type, couleurs dynamiques via ColorScheme.
class LieuTypeChips extends StatelessWidget {
  final LieuType selected;
  final ValueChanged<LieuType> onSelected;

  const LieuTypeChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in LieuType.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(
                  LieuTypeHelper.icon(t),
                  color: LieuTypeHelper.color(t),
                  size: 18,
                ),
                label: Text(
                  LieuTypeHelper.label(t),
                  style: TextStyle(color: cs.onSurface),
                ),
                selected: selected == t,
                selectedColor: LieuTypeHelper.color(t).withOpacity(0.2),
                backgroundColor: cs.surface,
                side: BorderSide(color: LieuTypeHelper.color(t), width: 1.2),
                onSelected: (_) => onSelected(t),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}
