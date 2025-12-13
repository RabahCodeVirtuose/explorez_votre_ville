import 'package:explorez_votre_ville/db/repository/lieu_repository.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

/// Section UI qui affiche la liste des lieux favoris de la ville courante.
/// - Tap court  : ouvre l'écran de détail du lieu (route '/details_lieu', arg id).
/// - Appui long : demande confirmation puis supprime le lieu favori de la base.
/// - Hero sur l'icône pour animer la transition vers la page détail.
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
          height: 130, // un peu plus haut pour éviter tout overflow
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceVariant : cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.tertiary, width: 1.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                final heroTag = 'lieu-hero-${lieu.id}';

                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details_lieu',
                        arguments: lieu.id,
                      );
                    },
                    onLongPress: () => _confirmAndDelete(lieu),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant.withOpacity(
                          isDark ? 0.4 : 0.6,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.tertiary, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: heroTag,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: cs.tertiary.withOpacity(0.9),
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 95,
                            child: Text(
                              lieu.nom,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            LieuTypeHelper.label(lieu.type),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: iconColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
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
