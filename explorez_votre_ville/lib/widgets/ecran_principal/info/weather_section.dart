// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/info/carte_meteo.dart';

/// Section météo + boutons d’action (palette via ColorScheme pour clair/sombre).
class WeatherSection extends StatelessWidget {
  final bool isFavori;
  final bool isVisitee;
  final bool isExploree;
  final VoidCallback onToggleFavori;
  final VoidCallback onToggleVisitee;
  final VoidCallback onToggleExploree;
  final MeteoCard meteoCard;

  const WeatherSection({
    super.key,
    required this.isFavori,
    required this.isVisitee,
    required this.isExploree,
    required this.onToggleFavori,
    required this.onToggleVisitee,
    required this.onToggleExploree,
    required this.meteoCard,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.tertiary, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: meteoCard),
          const SizedBox(width: 3),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton(
                context: context,
                active: isFavori,
                tooltip: isFavori
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                icon: isFavori ? Icons.favorite : Icons.favorite_border,
                onPressed: onToggleFavori,
              ),
              _actionButton(
                context: context,
                active: isVisitee,
                tooltip: isVisitee ? 'Marquée non visitée' : 'Marquer visitée',
                icon: isVisitee
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                onPressed: onToggleVisitee,
              ),
              _actionButton(
                context: context,
                active: isExploree,
                tooltip: isExploree
                    ? 'Marquée non explorée'
                    : 'Marquer explorée',
                icon: isExploree ? Icons.explore : Icons.explore_outlined,
                onPressed: onToggleExploree,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bouton rond réutilisable avec couleurs issues du thème.
  Widget _actionButton({
    required BuildContext context,
    required bool active,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    final fg = active ? cs.primary : cs.onSurface;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: cs.background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, color: fg, size: 24),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
