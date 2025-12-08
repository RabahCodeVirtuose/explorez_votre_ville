import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

/// Section UI qui affiche la liste des lieux favoris de la ville courante.
/// Chaque lieu est présenté avec une icône et une pastille colorée selon son type.
class FavoritePlacesSection extends StatelessWidget {
  // Palette alignée sur le reste de l'UI
  static const Color _deepGreen = Color(0xFF18534F);
  static const Color _mint = Color(0xFFECF8F6);
  static const Color _amber = Color(0xFFFEEAA1);

  /// Lieux favoris à afficher (chargés depuis la base via le provider).
  final List<Lieu> lieux;

  const FavoritePlacesSection({super.key, required this.lieux});

  @override
  Widget build(BuildContext context) {
    // Si aucun favori, on ne rend rien.
    if (lieux.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            'Lieux favoris',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _deepGreen,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _amber, width: 1.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lieux.length,
              itemBuilder: (context, index) {
                final lieu = lieux[index];
                // Icône et couleur dérivées du type de lieu
                final icon = LieuTypeHelper.icon(lieu.type);
                final color = LieuTypeHelper.color(lieu.type);
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pastille circulaire colorée + icône du type
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: color.withOpacity(0.12),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(height: 6),
                      // Nom du lieu (centré, limité à 2 lignes)
                      SizedBox(
                        width: 90,
                        child: Text(
                          lieu.nom,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _deepGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
