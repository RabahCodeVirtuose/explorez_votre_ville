import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

/// Section UI qui affiche la liste des lieux favoris de la ville courante.
/// Chaque lieu est présenté avec une icône et une pastille colorée selon son type.
class FavoritePlacesSection extends StatelessWidget {
  /// Lieux favoris à afficher (chargés depuis la base via le provider).
  final List<Lieu> lieux;

  const FavoritePlacesSection({super.key, required this.lieux});

  @override
  Widget build(BuildContext context) {
    // Si aucun favori, on ne rend rien.
    if (lieux.isEmpty) return const SizedBox.shrink();
    /*• SizedBox.shrink() est un widget qui occupe 0×0 (pas d’espace ni d’affichage). On l’utilise ici pour “ne rien rendre” quand la liste de lieux est vide, tout en restant dans le flux des
  widgets.
 */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la section
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Lieux favoris',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Liste horizontale des favoris
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lieux.length,
            itemBuilder: (context, index) {
              final lieu = lieux[index];
              // Icône et couleur dérivées du type de lieu
              final icon = LieuTypeHelper.icon(lieu.type);
              final color = LieuTypeHelper.color(lieu.type);
              return Padding(
                /*  
  - pour le premier item (index == 0), pas de marge à gauche (0) ;
  - pour les suivants, 8 px à gauche pour espacer ;
  - 8 px à droite pour tous, afin d’aérer les items entre eux. */
                padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: 8),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pastille circulaire colorée + icône du type
                    /*
  CircleAvatar est un widget circulaire souvent utilisé pour afficher des photos ou des icônes dans un rond. Ici, il sert de pastille colorée pour représenter le type du lieu, avec un
  radius de 22 et un backgroundColor légèrement transparent. Un Icon est placé au centre pour l’illustrer. */
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
                        /*
                        overflow: TextOverflow.ellipsis coupe le texte quand il dépasse le nombre de lignes 
                        autorisées (maxLines) et ajoute “…” à la fin au lieu de déborder. */
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
