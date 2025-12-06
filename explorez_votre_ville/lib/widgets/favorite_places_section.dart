import 'package:flutter/material.dart';

import '../models/lieu.dart';
import '../models/lieu_type.dart';

class FavoritePlacesSection extends StatelessWidget {
  final List<Lieu> lieux;

  const FavoritePlacesSection({super.key, required this.lieux});

  @override
  Widget build(BuildContext context) {
    if (lieux.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Lieux favoris',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lieux.length,
            itemBuilder: (context, index) {
              final lieu = lieux[index];
              final icon = LieuTypeHelper.icon(lieu.type);
              final color = LieuTypeHelper.color(lieu.type);
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 8, right: 8),
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
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
