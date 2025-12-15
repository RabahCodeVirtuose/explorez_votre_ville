import 'package:flutter/material.dart';
import '../../models/lieu.dart';
import '../../models/lieu_type.dart';

// LieuHeader
// Ici on affiche l en tête de la page détail d un lieu
// On montre
// - une icône avec Hero pour l animation
// - le nom du lieu
// - le type
// - la description si elle existe
// - les coordonnées si elles existent
class LieuHeader extends StatelessWidget {
  // Le lieu à afficher
  final Lieu lieu;

  const LieuHeader({super.key, required this.lieu});

  @override
  Widget build(BuildContext context) {
    // On récupère l icône et le label du type via nos helpers
    final icon = LieuTypeHelper.icon(lieu.type);
    final typeLabel = LieuTypeHelper.label(lieu.type);

    // On construit un tag stable pour le Hero
    // Si on a un id on l utilise
    // Sinon on fallback sur le nom pour éviter null
    final heroTag = 'lieu-hero-${lieu.id ?? lieu.nom}';

    // On récupère les couleurs du thème
    final cs = Theme.of(context).colorScheme;

    // On prépare les textes pour éviter de répéter des conditions dans l UI
    final hasDescription =
        lieu.description != null && lieu.description!.isNotEmpty;
    final latText = lieu.latitude != null
        ? lieu.latitude!.toStringAsFixed(4)
        : '-';
    final lonText = lieu.longitude != null
        ? lieu.longitude!.toStringAsFixed(4)
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ligne principale avec avatar et infos
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero pour animer l icône entre la liste et le détail
            Hero(
              tag: heroTag,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: cs.tertiary.withOpacity(0.9),
                child: Icon(icon, color: cs.onSurface, size: 28),
              ),
            ),

            const SizedBox(width: 12),

            // On met le texte dans Expanded pour éviter les overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du lieu
                  Text(
                    lieu.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Type du lieu
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          typeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Description optionnelle
        if (hasDescription) Text(lieu.description!),

        const SizedBox(height: 12),

        // Coordonnées
        Row(
          children: [
            const Icon(Icons.pin_drop, size: 18),
            const SizedBox(width: 6),
            Text('Lat: $latText / Lon: $lonText'),
          ],
        ),
      ],
    );
  }
}
