import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/widgets/ecran_principal/info/carte_meteo.dart';

// WeatherSection
// Cette section regroupe deux choses
// - la carte météo de la ville courante
// - des boutons d action pour marquer la ville en favori visitée ou explorée
// Les couleurs viennent uniquement du thème pour rester cohérent clair sombre
class WeatherSection extends StatelessWidget {
  // Indique si la ville est en favori
  final bool isFavori;

  // Indique si la ville est marquée comme visitée
  final bool isVisitee;

  // Indique si la ville est marquée comme explorée
  final bool isExploree;

  // Callbacks appelés quand on clique sur les boutons
  final VoidCallback onToggleFavori;
  final VoidCallback onToggleVisitee;
  final VoidCallback onToggleExploree;

  // Carte météo déjà construite par le parent
  // On l injecte ici pour garder une séparation claire des responsabilités
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
    // On récupère les couleurs du thème courant
    final cs = Theme.of(context).colorScheme;

    // Container principal pour encadrer la section
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.tertiary, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // La carte météo prend la majorité de la place
          Expanded(child: meteoCard),

          const SizedBox(width: 3),

          // Colonne de boutons d action
          // Chaque bouton correspond à un état de la ville
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton favori
              _actionButton(
                context: context,
                active: isFavori,
                tooltip: isFavori
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                icon: isFavori ? Icons.favorite : Icons.favorite_border,
                onPressed: onToggleFavori,
              ),

              // Bouton visitée
              _actionButton(
                context: context,
                active: isVisitee,
                tooltip: isVisitee ? 'Marquée non visitée' : 'Marquer visitée',
                icon: isVisitee
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                onPressed: onToggleVisitee,
              ),

              // Bouton explorée
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

  // Bouton d action rond réutilisable
  // active permet de changer la couleur quand l état est actif
  Widget _actionButton({
    required BuildContext context,
    required bool active,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    // On récupère le thème pour les couleurs
    final cs = Theme.of(context).colorScheme;

    // Couleur de l icône selon l état
    // Si actif on met la couleur primaire sinon une couleur neutre
    final fg = active ? cs.primary : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        // Décoration pour donner un effet bouton flottant
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
