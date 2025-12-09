import 'package:flutter/material.dart';

class SearchBarField extends StatelessWidget {
  // Palette (alignée sur les widgets météo)
  static const Color _deepGreen = Color(0xFF18534F);
  static const Color _teal = Color(0xFF226D68);
  static const Color _mint = Color(0xFFECF8F6);
  static const Color _amber = Color(0xFFFEEAA1);

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Rechercher une ville…',
        filled: true,
        fillColor: _mint,
        prefixIcon: const Icon(Icons.search, color: _deepGreen),
        hintStyle: const TextStyle(color: _deepGreen),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color:_amber, width: 1.5),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
