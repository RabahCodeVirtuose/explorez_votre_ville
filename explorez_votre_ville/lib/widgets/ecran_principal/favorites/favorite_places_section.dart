import 'package:explorez_votre_ville/db/repository/lieu_repository.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

/// Section UI qui affiche la liste des lieux favoris de la ville courante.
/// - Tap court  : ouvre l'écran de détail du lieu (route '/details_lieu', arg id).
/// - Appui long : demande confirmation puis supprime le lieu favori de la base.
class FavoritePlacesSection extends StatefulWidget {
  // Palette alignée sur le reste de l'UI
  static const Color _deepGreen = Color(0xFF18534F);
  static const Color _mint = Color(0xFFECF8F6);
  static const Color _amber = Color(0xFFFEEAA1);

  /// Lieux favoris à afficher (chargés depuis la base via le provider).
  final List<Lieu> lieux;

  const FavoritePlacesSection({super.key, required this.lieux});

  @override
  State<FavoritePlacesSection> createState() => _FavoritePlacesSectionState();
}

class _FavoritePlacesSectionState extends State<FavoritePlacesSection> {
  late List<Lieu> _localLieux; // copie locale pour suppression optimiste
  final LieuRepository _lieuRepo = LieuRepository();

  @override
  void initState() {
    super.initState();
    _localLieux = List<Lieu>.from(widget.lieux);
  }

/*didUpdateWidget est appelé quand le parent reconstruit ce widget avec de nouvelles propriétés. Ici :

  - oldWidget.lieux est l’ancienne liste passée.
  - widget.lieux est la nouvelle liste passée.
  - Si elles diffèrent, on met à jour la copie locale _localLieux (utilisée pour l’affichage/suppression optimiste).

  En résumé, ça synchronise l’état interne _localLieux avec les nouvelles données du parent, pour ne pas rester sur une ancienne liste. */
  @override
  void didUpdateWidget(covariant FavoritePlacesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lieux != widget.lieux) {
      _localLieux = List<Lieu>.from(widget.lieux);
    }
  }

  Future<void> _confirmAndDelete(Lieu lieu) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce lieu ?'),
        content: Text('Voulez-vous retirer "${lieu.nom}" des favoris ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && lieu.id != null) {
      await _lieuRepo.deleteLieu(lieu.id!);
      setState(() {
        _localLieux.removeWhere((l) => l.id == lieu.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${lieu.nom} retiré des favoris')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localLieux.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: Text(
            'Lieux favoris',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: FavoritePlacesSection._deepGreen,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              color: FavoritePlacesSection._mint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FavoritePlacesSection._amber, width: 1.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _localLieux.length,
              itemBuilder: (context, index) {
                final lieu = _localLieux[index];
                final icon = LieuTypeHelper.icon(lieu.type);
                final color = LieuTypeHelper.color(lieu.type);
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: 8),
                  child: InkWell(
                    // Tap court : ouvrir la page détail
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details_lieu',
                        arguments: lieu.id,
                      );
                    },
                    // Appui long : confirmation puis suppression
                    onLongPress: () => _confirmAndDelete(lieu),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: color.withOpacity(0.12),
                          child: Icon(icon, color: color),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 90,
                          child: Text(
                            lieu.nom,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: FavoritePlacesSection._deepGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
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
