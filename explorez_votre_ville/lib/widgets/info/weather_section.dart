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
  final VoidCallback onToggleFavori;
  final MeteoCard meteoCard;

  const WeatherSection({
    super.key,
    required this.isFavori,
    required this.onToggleFavori,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: meteoCard),
          const SizedBox(width: 3),
          // Bouton favori avec marge tout autour
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
                  size: 28,
                ),
                onPressed: onToggleFavori,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
