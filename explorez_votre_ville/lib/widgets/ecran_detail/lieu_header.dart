import 'package:flutter/material.dart';
import '../../models/lieu.dart';

/// Bloc d’en-tête pour le détail d’un lieu : nom, type, description, coordonnées.
class LieuHeader extends StatelessWidget {
  final Lieu lieu;
  const LieuHeader({super.key, required this.lieu});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lieu.nom,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.category, size: 18),
            const SizedBox(width: 6),
            Text(lieu.type.name),
          ],
        ),
        const SizedBox(height: 8),
        if (lieu.description != null && lieu.description!.isNotEmpty)
          Text(lieu.description!),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.pin_drop, size: 18),
            const SizedBox(width: 6),
            Text(
              'Lat: ${lieu.latitude?.toStringAsFixed(4) ?? '-'} / '
              'Lon: ${lieu.longitude?.toStringAsFixed(4) ?? '-'}',
            ),
          ],
        ),
      ],
    );
  }
}
