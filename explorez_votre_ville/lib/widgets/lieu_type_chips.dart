import 'package:flutter/material.dart';

import '../models/lieu_type.dart';
import '../utils/lieu_type_mapper.dart';

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
                label: Text(LieuTypeHelper.label(t)),
                selected: selected == t,
                onSelected: (_) => onSelected(t),
              ),
            ),
        ],
      ),
    );
  }
}
