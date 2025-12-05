import 'package:flutter/material.dart';

class FavoriteCardsBar extends StatelessWidget {
  const FavoriteCardsBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste statique des lieux favoris (maquette)
    final List<Map<String, dynamic>> staticFavorites = [
      {'name': 'Musée', 'icon': Icons.museum, 'color': Colors.purple},
      {'name': 'Restaurant', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'name': 'Parc Central', 'icon': Icons.park, 'color': Colors.green},
      {'name': 'Théatre', 'icon': Icons.theater_comedy, 'color': Colors.red},
      {'name': 'Cinéma', 'icon': Icons.movie, 'color': Colors.blue},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: staticFavorites.length,
        itemBuilder: (context, index) {
          final favorite = staticFavorites[index];

          return Padding(
            padding: EdgeInsets.fromLTRB(index == 0 ? 16 : 4, 8, 4, 8),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  // Future logique de navigation/filtre
                  // ignore: avoid_print
                  print('Clic sur favori: ${favorite['name']}');
                },
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        favorite['icon'] as IconData,
                        color: favorite['color'] as Color,
                        size: 35,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        favorite['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
