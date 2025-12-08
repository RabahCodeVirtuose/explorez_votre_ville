import 'package:explorez_votre_ville/widgets/info/carte_meteo.dart';
import 'package:flutter/material.dart';


class WeatherSection extends StatelessWidget {
  final bool isFavori;
  final VoidCallback onToggleFavori;
  final MeteoCard meteoCard;

  const WeatherSection({
    super.key,
    required this.isFavori,
    required this.onToggleFavori,
    required this.meteoCard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: meteoCard),
        const SizedBox(width: 8),
        IconButton(
          tooltip: isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
          icon: Icon(
            isFavori ? Icons.favorite : Icons.favorite_border,
            color: isFavori ? Colors.red : null,
          ),
          onPressed: onToggleFavori,
        ),
      ],
    );
  }
}
