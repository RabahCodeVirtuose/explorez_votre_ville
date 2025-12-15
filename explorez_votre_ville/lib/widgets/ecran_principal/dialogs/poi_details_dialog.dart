import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';

// PoiDetailsDialog
// On affiche une boite de dialogue quand on tape sur un POI sur la carte
// On montre les infos utiles du lieu
// On laisse l utilisateur soit fermer soit ajouter le lieu aux favoris
class PoiDetailsDialog extends StatelessWidget {
  // Le POI qu on veut afficher
  final LieuApiResult poi;

  // Callback fourni par le parent
  // Le parent décide quoi faire quand on clique sur ajouter
  final VoidCallback onAdd;

  // Le type actuellement sélectionné dans l app
  // On l utilise pour afficher un libellé clair dans la boite de dialogue
  final LieuType currentType;

  const PoiDetailsDialog({
    super.key,
    required this.poi,
    required this.onAdd,
    required this.currentType,
  });

  @override
  Widget build(BuildContext context) {
    // On récupère le libellé lisible du type
    final typeLabel = LieuTypeHelper.label(currentType);

    // On récupère le theme pour éviter de répéter Theme.of(context) partout
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      // Titre principal
      // Si le nom est vide on met un fallback pour éviter un titre vide
      title: Text(poi.name.isEmpty ? '(Sans nom)' : poi.name),

      // Le contenu peut dépasser sur mobile donc on met un scroll
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            // Ligne 1 le type sélectionné dans l app
            Text('Type : $typeLabel'),

            // Ligne 2 coordonnées arrondies pour rester lisibles
            Text(
              'Coordonnées : ${poi.lat.toStringAsFixed(4)}, ${poi.lon.toStringAsFixed(4)}',
            ),

            // Ligne 3 adresse si elle existe
            // On garde un petit style mais simple
            if (poi.formattedAddress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  poi.formattedAddress,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.85)),
                ),
              ),
          ],
        ),
      ),

      // Actions en bas de la boite de dialogue
      actions: [
        // Fermer ne fait rien de spécial
        // On ferme juste la boite de dialogue
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),

        // Ajouter appelle le callback du parent
        // Puis on ferme la boite de dialogue
        ElevatedButton.icon(
          icon: const Icon(Icons.add_location_alt),
          label: const Text('Ajouter à mes lieux favoris'),
          onPressed: () {
            onAdd();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
