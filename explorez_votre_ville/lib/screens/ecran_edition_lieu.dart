import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lieu.dart';
import '../models/lieu_type.dart';
import '../providers/ville_provider.dart';
import '../widgets/ecran_detail/comments_edit_section.dart';
import '../widgets/ecran_detail/lieu_edit_form.dart';

/// Écran d’édition d’un lieu.
/// Objectif :
/// - charger un lieu depuis la base (via lieuId)
/// - afficher un formulaire (description, lat/lon, etc.)
/// - permettre de modifier / supprimer / ajouter des commentaires
/// - sauvegarder les modifications du lieu
///
/// Important :
/// - on renvoie au retour un bool (_changed) pour que l’écran précédent
///   sache s’il doit se rafraîchir ou non.
class EcranEditionLieu extends StatefulWidget {
  /// Id du lieu à éditer (reçu via Navigator arguments)
  final int? lieuId;

  const EcranEditionLieu({super.key, required this.lieuId});

  @override
  State<EcranEditionLieu> createState() => _EcranEditionLieuState();
}

class _EcranEditionLieuState extends State<EcranEditionLieu> {
  // -----------------------------
  // (A) Controllers du formulaire "lieu"
  // -----------------------------
  // Ils servent à lire/modifier le contenu des TextField du formulaire.
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();

  // Type sélectionné (parc, musée, etc.)
  late LieuType _typeSel;

  // Permet d’éviter de réécrire les champs à chaque rebuild du FutureBuilder.
  bool _initialised = false;

  // Flag : indique si quelque chose a changé (lieu ou commentaires).
  // Sert à renvoyer "true" au retour de l’écran.
  bool _changed = false;

  // -----------------------------
  // (B) Commentaires (ajout / note)
  // -----------------------------
  // Controller pour le champ de saisie d’un nouveau commentaire.
  final _commentCtrl = TextEditingController();

  // Note du commentaire (0..5). Valeur par défaut : 3.
  final ValueNotifier<int> _noteNotifier = ValueNotifier<int>(3);

  @override
  void dispose() {
    // Toujours libérer les controllers/notifiers pour éviter des fuites mémoire.
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _commentCtrl.dispose();
    _noteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sécurité : si aucun id n’est reçu, on ne peut pas éditer.
    if (widget.lieuId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Éditer un lieu')),
        body: const Center(child: Text('Aucun identifiant reçu')),
      );
    }

    // Provider principal (read : pas besoin de rebuild automatique ici,
    // le FutureBuilder gère le rendu du lieu).
    final villeProvider = context.read<VilleProvider>();

    // WillPopScope : intercept le bouton retour (Android / back)
    // pour renvoyer _changed au parent.
    return WillPopScope(
      onWillPop: () async {
        // On renvoie au parent si on a modifié quelque chose.
        Navigator.pop(context, _changed);
        return false; // on gère nous-même la navigation
      },
      child: Scaffold(
        // AppBar avec bouton "save" en haut
        appBar: AppBar(
          title: const Text('Éditer le lieu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Enregistrer',
              onPressed: () async => _saveLieu(context, villeProvider),
            ),
          ],
        ),

        // FutureBuilder : charge le lieu depuis la base
        body: FutureBuilder<Lieu?>(
          future: villeProvider.getLieuById(widget.lieuId!),
          builder: (context, snapshot) {
            // 1) Chargement en cours
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2) Erreur de chargement
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erreur : ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            // 3) Résultat
            final lieu = snapshot.data;

            // Si pas trouvé en base
            if (lieu == null) {
              return const Center(child: Text('Lieu introuvable'));
            }

            // -------------------------------------------------
            // Initialisation UNIQUE des champs du formulaire
            // -------------------------------------------------
            // Sans ça, à chaque rebuild, le TextField serait "réécrit"
            // et l’utilisateur perdrait ce qu’il tape.
            if (!_initialised) {
              _nomCtrl.text = lieu.nom;
              _descCtrl.text = lieu.description ?? '';
              _latCtrl.text = lieu.latitude?.toString() ?? '';
              _lonCtrl.text = lieu.longitude?.toString() ?? '';
              _typeSel = lieu.type;
              _initialised = true;
            }

            // UI principale
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------
                  // (1) Formulaire de modification du lieu
                  // -----------------------------
                  // Ici : le nom + type sont figés (readOnlyNameType = true).
                  // L’utilisateur peut modifier la description + coordonnées.
                  LieuEditForm(
                    nomCtrl: _nomCtrl,
                    descCtrl: _descCtrl,
                    latCtrl: _latCtrl,
                    lonCtrl: _lonCtrl,
                    typeSel: _typeSel,
                    readOnlyNameType: true,
                    onTypeChanged: (v) {
                      // non utilisé car readOnlyNameType = true
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // -----------------------------
                  // (2) Commentaires (liste + ajout + édition + suppression)
                  // -----------------------------
                  // Expanded : la section commentaires prend le reste de la hauteur.
                  Expanded(
                    child: CommentsEditSection(
                      lieuId: lieu.id!,
                      commentCtrl: _commentCtrl,
                      noteNotifier: _noteNotifier,

                      // Appelé après CRUD commentaire :
                      // -> on marque la page comme modifiée
                      // -> setState si besoin (ex: rafraîchir indicateurs)
                      onChanged: () {
                        _changed = true;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Sauvegarde les modifications du lieu (en base) via le provider.
  /// Étapes :
  /// 1) vérifier les champs (nom obligatoire)
  /// 2) parser lat/lon
  /// 3) recharger l’objet existant (source de vérité)
  /// 4) copyWith -> update
  /// 5) snackBar + retour avec "true"
  Future<void> _saveLieu(BuildContext context, VilleProvider provider) async {
    // Nom obligatoire
    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le nom est obligatoire')));
      return;
    }

    // lat/lon : facultatifs (si impossible à parser => null)
    final lat = double.tryParse(_latCtrl.text.trim());
    final lon = double.tryParse(_lonCtrl.text.trim());

    // On recharge l’objet existant pour être sûr d’avoir la bonne version
    final existing = await provider.getLieuById(widget.lieuId!);
    if (existing == null) return;

    // On crée un nouvel objet (immutabilité)
    final updated = existing.copyWith(
      nom: nom,
      type: _typeSel,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      latitude: lat,
      longitude: lon,
    );

    // Mise à jour en base
    await provider.mettreAJourLieu(updated);

    // Indique au parent qu'il faudra refresh
    _changed = true;

    // Sécurité après await : l’écran est-il encore monté ?
    if (!mounted) return;

    // Feedback
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Lieu mis à jour')));

    // Retour vers l’écran précédent (true => "ça a changé")
    Navigator.pop(context, true);
  }
}
