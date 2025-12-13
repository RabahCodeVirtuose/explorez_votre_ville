import 'package:flutter/material.dart';
import '../../models/lieu.dart';
import '../../models/lieu_type.dart';

class LieuHeader extends StatelessWidget {
  final Lieu lieu;
  const LieuHeader({super.key, required this.lieu});

  @override
  Widget build(BuildContext context) {
    final icon = LieuTypeHelper.icon(lieu.type);
    final typeLabel = LieuTypeHelper.label(lieu.type);
    final heroTag = 'lieu-hero-${lieu.id ?? lieu.nom}';
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: heroTag,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: cs.tertiary.withOpacity(0.9),
                child: Icon(icon, color: cs.onSurface, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lieu.nom,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16),
                      const SizedBox(width: 6),
                      Text(typeLabel),
                    ],
                  ),
                ],
              ),
            ),
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
