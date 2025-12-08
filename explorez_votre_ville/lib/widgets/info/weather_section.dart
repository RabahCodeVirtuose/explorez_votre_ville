// ignore_for_file: deprecated_member_use

import 'package:explorez_votre_ville/widgets/info/carte_meteo.dart';
import 'package:flutter/material.dart';

/// Section météo + bouton favori (palette alignée sur MeteoCard).
class WeatherSection extends StatelessWidget {
  // Palette (identique à MeteoCard)
  static const Color _deepGreen = Color(0xFF18534F);
  static const Color _teal = Color(0xFF226D68);
  static const Color _mint = Color(0xFFECF8F6);
  static const Color _amber = Color(0xFFFEEAA1);

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
    return Container(
      decoration: BoxDecoration(
        color: _mint,
        border: Border.all(color: _deepGreen, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        // On centre verticalement la colonne de boutons par rapport à la carte météo
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: meteoCard),
          const SizedBox(width: 3),
          // Boutons d'action (favori / visitée / explorée), centrés verticalement
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isFavori ? _amber.withOpacity(0.8) : _mint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip:
                        isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
                    icon: Icon(
                      isFavori ? Icons.favorite : Icons.favorite_border,
                      color: isFavori ? _deepGreen : _teal,
                      size: 26,
                    ),
                    onPressed: onToggleFavori,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isVisitee ? _amber.withOpacity(0.8) : _mint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip:
                        isVisitee ? 'Marquée non visitée' : 'Marquer visitée',
                    icon: Icon(
                      isVisitee
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: isVisitee ? _deepGreen : _teal,
                      size: 24,
                    ),
                    onPressed: onToggleVisitee,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isExploree ? _amber.withOpacity(0.8) : _mint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip:
                        isExploree ? 'Marquée non explorée' : 'Marquer explorée',
                    icon: Icon(
                      isExploree ? Icons.explore : Icons.explore_outlined,
                      color: isExploree ? _deepGreen : _teal,
                      size: 24,
                    ),
                    onPressed: onToggleExploree,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
