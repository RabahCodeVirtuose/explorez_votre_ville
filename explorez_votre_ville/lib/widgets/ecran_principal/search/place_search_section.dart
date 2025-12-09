import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/search/lieu_type_chips.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/search/search_bar.dart';
import 'package:explorez_votre_ville/widgets/status/error_banner.dart';
import 'package:flutter/material.dart';

class PlaceSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final bool loading;
  final String? error;
  final LieuType selectedType;
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
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBarField(
          controller: controller,
          onSubmitted: onSubmit,
        ),
        const SizedBox(height: 8),
        if (loading)
          LinearProgressIndicator(
            color: cs.primary,
            backgroundColor: cs.surfaceVariant,
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ErrorBanner(
              message: error!,
            ),
          ),
        const SizedBox(height: 8),
        LieuTypeChips(
          selected: selectedType,
          onSelected: onTypeChanged,
        ),
      ],
    );
  }
}
