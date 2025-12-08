import 'package:explorez_votre_ville/db/repository/lieu_repository.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';

/// Affiche le détail d'un lieu favori (nom, type, adresse, coordonnées).
/// Attend un `int` (id du lieu) passé via `Navigator.pushNamed(..., arguments: id)`.
class EcranDetailLieu extends StatelessWidget {
  final int? lieuId;
  const EcranDetailLieu({super.key, required this.lieuId});

  @override
  Widget build(BuildContext context) {
    // Si aucun id n'est fourni, on affiche une erreur simple.
    if (lieuId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail du lieu')),
        body: const Center(
          child: Text('Aucun identifiant de lieu fourni.'),
        ),
      );
    }

    final repo = LieuRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du lieu')),
      body: FutureBuilder<Lieu?>(
        future: repo.getLieuById(lieuId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur lors du chargement : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final lieu = snapshot.data;
          if (lieu == null) {
            return const Center(child: Text('Lieu introuvable.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lieu.nom,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, size: 18),
                    const SizedBox(width: 6),
                    Text(lieu.type.name),
                  ],
                ),
                const SizedBox(height: 8),
                if (lieu.description != null && lieu.description!.isNotEmpty)
                  Text(lieu.description!),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.pin_drop, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Lat: ${lieu.latitude?.toStringAsFixed(4) ?? '-'} / Lon: ${lieu.longitude?.toStringAsFixed(4) ?? '-'}',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
