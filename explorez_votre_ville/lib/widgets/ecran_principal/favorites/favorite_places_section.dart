//
// Ici on affiche les lieux favoris de la ville courante
// On veut des cartes toutes de la même taille
// Même si le nom est long on coupe avec ellipsis
// On réserve une hauteur fixe pour le titre et le type

import 'package:explorez_votre_ville/db/repository/lieu_repository.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

// Widget de section car on garde un petit état local
// On veut pouvoir supprimer un lieu et le retirer tout de suite de l affichage
class FavoritePlacesSection extends StatefulWidget {
  // Liste de lieux favoris fournie par le parent
  // En général elle vient du provider ou d un chargement en base
  final List<Lieu> lieux;

  const FavoritePlacesSection({super.key, required this.lieux});

  @override
  State<FavoritePlacesSection> createState() => _FavoritePlacesSectionState();
}

class _FavoritePlacesSectionState extends State<FavoritePlacesSection> {
  // Copie locale de la liste
  // On s en sert pour faire une suppression optimiste
  // Donc on supprime dans l UI sans attendre de recharger toute la page
  late List<Lieu> _localLieux;

  // Accès à la base SQLite pour supprimer un lieu
  final LieuRepository _lieuRepo = LieuRepository();

  @override
  void initState() {
    super.initState();

    // Au premier affichage on copie la liste reçue
    // Comme ça on peut la modifier localement sans toucher directement au parent
    _localLieux = List<Lieu>.from(widget.lieux);
  }

  @override
  void didUpdateWidget(covariant FavoritePlacesSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si le parent renvoie une nouvelle liste on recopie
    // Ça évite d afficher des favoris périmés si la ville change par exemple
    if (oldWidget.lieux != widget.lieux) {
      _localLieux = List<Lieu>.from(widget.lieux);
    }
  }

  Future<void> _confirmAndDelete(Lieu lieu) async {
    // On demande confirmation à l utilisateur
    // showDialog renvoie true si on confirme
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce lieu ?'),
        content: Text('Voulez-vous retirer "${lieu.nom}" des favoris ?'),
        actions: [
          // Annuler renvoie false
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),

          // Supprimer renvoie true
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    // Si on confirme et que le lieu a bien un id on supprime en base
    if (confirmed == true && lieu.id != null) {
      await _lieuRepo.deleteLieu(lieu.id!);

      // On enlève ensuite dans la liste locale pour mettre l UI à jour
      setState(() {
        _localLieux.removeWhere((l) => l.id == lieu.id);
      });

      // On affiche un message rapide pour informer l utilisateur
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${lieu.nom} retiré des favoris')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si la liste est vide on ne montre pas la section
    if (_localLieux.isEmpty) return const SizedBox.shrink();

    // On récupère la palette du thème pour rester cohérent avec l appli
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            'Lieux favoris',
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.secondary),
          ),
        ),

        // On fixe une hauteur globale pour la liste horizontale
        // Comme ça les cartes rentrent toujours et on évite les overflow
        SizedBox(
          height: 118,
          child: ListView.separated(
            // On fait défiler horizontalement
            scrollDirection: Axis.horizontal,

            // Nombre de cartes à afficher
            itemCount: _localLieux.length,

            // Petit espace constant entre chaque carte
            separatorBuilder: (_, __) => const SizedBox(width: 8),

            // Construction de chaque item
            itemBuilder: (context, index) {
              final lieu = _localLieux[index];

              // On délègue l affichage à un widget de carte
              // Comme ça le build principal reste simple
              return _FavoritePlaceCard(
                lieu: lieu,

                // Tap court ouvre la page détail
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details_lieu',
                    arguments: lieu.id,
                  );
                },

                // Appui long déclenche la suppression
                onLongPress: () => _confirmAndDelete(lieu),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget carte séparé pour isoler la mise en forme
// On le garde en privé car il n est utilisé que dans ce fichier
class _FavoritePlaceCard extends StatelessWidget {
  // Le lieu à afficher
  final Lieu lieu;

  // Callback du tap court
  final VoidCallback onTap;

  // Callback de l appui long
  final VoidCallback onLongPress;

  const _FavoritePlaceCard({
    required this.lieu,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // On récupère le thème
    final cs = Theme.of(context).colorScheme;

    // On calcule l icône et la couleur selon le type du lieu
    final icon = LieuTypeHelper.icon(lieu.type);
    final typeColor = LieuTypeHelper.color(lieu.type);

    // Tag utilisé par Hero pour animer la transition vers la page détail
    // On met l id pour être sûr que chaque tag est unique
    final heroTag = 'lieu-hero-${lieu.id}';

    // On fixe la taille pour que toutes les cartes soient identiques
    // Même si le texte est long la carte ne grandit pas
    const double cardWidth = 132;
    const double cardHeight = 104;

    return AnimatedSwitcher(
      // Petite animation quand la carte apparait ou disparait
      duration: const Duration(milliseconds: 180),

      child: SizedBox(
        // ValueKey aide Flutter à reconnaître quelle carte correspond à quel lieu
        // Ça rend les animations plus propres
        key: ValueKey(lieu.id),

        // Taille fixe de la carte
        width: cardWidth,
        height: cardHeight,

        child: InkWell(
          // Le radius doit correspondre à la Card pour un effet ripple propre
          borderRadius: BorderRadius.circular(12),

          // Tap court
          onTap: onTap,

          // Appui long
          onLongPress: onLongPress,

          child: Card(
            // Un peu d ombre mais on reste sobre
            elevation: 1.0,

            // On arrondit et on met une bordure fine
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.tertiary.withOpacity(0.6), width: 1),
            ),

            child: Padding(
              // Padding réduit pour rentrer dans la hauteur fixée
              padding: const EdgeInsets.all(8),

              child: Column(
                // On centre le contenu verticalement
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hero sur l avatar
                  // Si la page détail a le même tag on aura l animation
                  Hero(
                    tag: heroTag,
                    child: CircleAvatar(
                      // Avatar un peu petit pour éviter les dépassements
                      radius: 16,
                      backgroundColor: typeColor.withOpacity(0.15),
                      child: Icon(icon, color: typeColor, size: 16),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Zone fixe pour le nom
                  // On limite à 2 lignes et on coupe si besoin
                  // On fixe la hauteur pour garder la même taille de carte partout
                  SizedBox(
                    height: 26,
                    child: Center(
                      child: Text(
                        lieu.nom,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          fontSize: 11.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Zone fixe pour le type
                  // Une seule ligne et ellipsis si besoin
                  SizedBox(
                    height: 14,
                    child: Center(
                      child: Text(
                        LieuTypeHelper.label(lieu.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
