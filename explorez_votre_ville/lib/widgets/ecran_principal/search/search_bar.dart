import 'package:flutter/material.dart';

/// Barre de recherche avec couleurs issues du thème (colorScheme).
class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Rechercher une ville…',
        filled: true,
        fillColor: cs.surface,
        prefixIcon: Icon(Icons.search, color: cs.onSurface),
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.tertiary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
