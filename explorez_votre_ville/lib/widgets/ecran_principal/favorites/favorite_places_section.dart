import 'package:explorez_votre_ville/db/repository/lieu_repository.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

/// Section UI qui affiche la liste des lieux favoris de la ville courante.
/// - Tap court  : ouvre l'écran de détail du lieu (route '/details_lieu', arg id).
/// - Appui long : demande confirmation puis supprime le lieu favori de la base.
class FavoritePlacesSection extends StatefulWidget {
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

  /* Synchronise la liste locale si le parent en fournit une nouvelle. */
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

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${lieu.nom} retiré des favoris')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localLieux.isEmpty) return const SizedBox.shrink();

    // Palette dynamique (clair/sombre) issue du thème
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: Text(
            'Lieux favoris',
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.secondary),
          ),
        ),
        SizedBox(
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceVariant : cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.tertiary, width: 1.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _localLieux.length,
              itemBuilder: (context, index) {
                final lieu = _localLieux[index];
                final icon = LieuTypeHelper.icon(lieu.type);
                final typeColor = LieuTypeHelper.color(lieu.type);
                final iconColor = isDark
                    ? typeColor.withOpacity(0.95)
                    : typeColor;
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
                          backgroundColor: cs.tertiary.withOpacity(0.9),
                          child: Icon(icon, color: iconColor),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 90,
                          child: Text(
                            lieu.nom,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: cs.onSurface),
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
