import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lieu.dart';
import '../models/lieu_type.dart';
import '../providers/ville_provider.dart';
import '../widgets/ecran_detail/comments_edit_section.dart';
import '../widgets/ecran_detail/lieu_edit_form.dart';

/// Écran d’édition d’un lieu :
/// - modification des champs (nom, type, description, lat/lon)
/// - ajout/édition/suppression des commentaires
/// - signale à l’écran précédent qu’il faut rafraîchir si quelque chose a changé.
class EcranEditionLieu extends StatefulWidget {
  final int? lieuId;
  const EcranEditionLieu({super.key, required this.lieuId});

  @override
  State<EcranEditionLieu> createState() => _EcranEditionLieuState();
}

class _EcranEditionLieuState extends State<EcranEditionLieu> {
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  late LieuType _typeSel;
  bool _initialised = false;
  bool _changed = false; // Pour renvoyer un flag au retour

  // Commentaires
  final _commentCtrl = TextEditingController();
  final ValueNotifier<int> _noteNotifier = ValueNotifier<int>(3);

  @override
  void dispose() {
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
    if (widget.lieuId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Éditer un lieu')),
        body: const Center(child: Text('Aucun identifiant reçu')),
      );
    }

    final villeProvider = context.read<VilleProvider>();

    return WillPopScope(
      // Si on revient en arrière, on renvoie _changed pour rafraîchir l’écran précédent si besoin.
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Éditer le lieu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async => _saveLieu(context, villeProvider),
              tooltip: 'Enregistrer',
            ),
          ],
        ),
        body: FutureBuilder<Lieu?>(
          future: villeProvider.getLieuById(widget.lieuId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
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
            final lieu = snapshot.data;
            if (lieu == null) {
              return const Center(child: Text('Lieu introuvable'));
            }

            // Initialisation unique des champs
            if (!_initialised) {
              _nomCtrl.text = lieu.nom;
              _descCtrl.text = lieu.description ?? '';
              _latCtrl.text = lieu.latitude?.toString() ?? '';
              _lonCtrl.text = lieu.longitude?.toString() ?? '';
              _typeSel = lieu.type;
              _initialised = true;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LieuEditForm(
                    nomCtrl: _nomCtrl,
                    descCtrl: _descCtrl,
                    latCtrl: _latCtrl,
                    lonCtrl: _lonCtrl,
                    typeSel: _typeSel,
                    readOnlyNameType: true, // nom + type figés
                    onTypeChanged: (v) {}, // non utilisé car readOnly
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // Section commentaires (liste + ajout/édition/suppression)
                  Expanded(
                    child: CommentsEditSection(
                      lieuId: lieu.id!,
                      commentCtrl: _commentCtrl,
                      noteNotifier: _noteNotifier,
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

  Future<void> _saveLieu(BuildContext context, VilleProvider provider) async {
    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est obligatoire')),
      );
      return;
    }
    final lat = double.tryParse(_latCtrl.text.trim());
    final lon = double.tryParse(_lonCtrl.text.trim());

    final existing = await provider.getLieuById(widget.lieuId!);
    if (existing == null) return;

    final updated = existing.copyWith(
      nom: nom,
      type: _typeSel,
      description: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      latitude: lat,
      longitude: lon,
    );
    await provider.mettreAJourLieu(updated);
    _changed = true; // indique qu'il faudra rafraîchir l'écran précédent
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lieu mis à jour')),
      );
      Navigator.pop(context, true);
    }
  }
}
