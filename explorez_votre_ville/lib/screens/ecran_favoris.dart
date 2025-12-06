import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ville.dart';
import '../providers/ville_provider.dart';

class EcranFavoris extends StatefulWidget {
  const EcranFavoris({super.key});

  @override
  State<EcranFavoris> createState() => _EcranFavorisState();
}

class _EcranFavorisState extends State<EcranFavoris> {
  late Future<List<Ville>> _favorisFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VilleProvider>();
    provider.chargerPinnedDepuisPrefs();
    _favorisFuture = provider.chargerFavoris();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes villes favorites')),
      body: FutureBuilder<List<Ville>>(
        future: _favorisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur lors du chargement des favoris:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          final favoris = snapshot.data ?? [];
          if (favoris.isEmpty) {
            return const Center(child: Text('Aucune ville favorite.'));
          }
          final pinnedId = context.watch<VilleProvider>().pinnedVilleId;
          return ListView.separated(
            itemCount: favoris.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final v = favoris[index];
              final isPinned = pinnedId != null && v.id == pinnedId;
              return ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(v.nom),
                subtitle: Text(
                  '${v.pays ?? ''} '
                  'Lat:${v.latitude?.toStringAsFixed(4) ?? '-'} '
                  'Lon:${v.longitude?.toStringAsFixed(4) ?? '-'}',
                ),
                trailing: IconButton(
                  tooltip: isPinned ? 'Désépingler' : 'Épingler',
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isPinned ? Colors.orange : null,
                  ),
                  onPressed: () async {
                    final provider = context.read<VilleProvider>();
                    if (isPinned) {
                      await provider.deseEpinglerVille();
                    } else {
                      await provider.epinglerVille(v);
                    }
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
