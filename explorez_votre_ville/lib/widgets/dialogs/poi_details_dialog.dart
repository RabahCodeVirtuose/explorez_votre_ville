import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:flutter/material.dart';

/// Boite de dialogue qui affiche le detail d'un POI et permet de l'ajouter
/// aux favoris locaux via le callback [onAdd].
class PoiDetailsDialog extends StatelessWidget {
  final LieuApiResult poi;
  final VoidCallback onAdd;

  const PoiDetailsDialog({
    super.key,
    required this.poi,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(poi.name),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            if (poi.categories.isNotEmpty)
              Text('Catégorie : ${poi.categories.first}'),
            Text(
              'Coordonnées : ${poi.lat.toStringAsFixed(4)}, ${poi.lon.toStringAsFixed(4)}',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Fermer'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_location_alt),
          label: const Text('Ajouter à mes lieux favoris'),
          onPressed: () {
            onAdd(); // ajoute en base
            Navigator.of(context).pop(); // ferme la boite de dialogue
          },
        ),
      ],
    );
  }
}
