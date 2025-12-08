import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

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
                label: Text(LieuTypeHelper.label(t)),
                selected: selected == t,
                selectedColor: LieuTypeHelper.color(t).withOpacity(0.2),
                backgroundColor: Colors.white,
                side: BorderSide(color: LieuTypeHelper.color(t), width: 1.2),
                onSelected: (_) => onSelected(t),
                showCheckmark: false, // pas de check "true" quand sélectionné
              ),
            ),
        ],
      ),
    );
  }
}
