import 'package:flutter/material.dart';

/// Carte météo utilisant le design existant, mais les couleurs viennent du thème
/// (ColorScheme) pour s’adapter au clair/sombre.
class MeteoCard extends StatelessWidget {
  final String cityName;
  final double temperature;
  final String icon;
  final String description;
  final double temperatureMin;
  final double temperatureMax;
  final int humidity;
  final double windSpeed;

  const MeteoCard({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.icon,
    required this.description,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.humidity,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconUrl = 'https://openweathermap.org/img/w/$icon.png';

    // Choix de couleurs dérivées du thème pour remplacer les anciennes constantes
    final baseText = cs.onSurface;
    final accent = cs.primary; // remplace l’ancien teal
    final highlight = cs.tertiary; // remplace l’ancien amber/sand
    final surface = cs.surface; // remplace l’ancien mint

    return Card(
      color: surface,
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: highlight, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Expanded(
                  child: Text(
                    cityName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: baseText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Température + icône météo
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: highlight.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    iconUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${temperature.toStringAsFixed(1)} °C',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Deux colonnes
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne 1 : météo / humidité
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, size: 16, color: highlight),
                          const SizedBox(width: 6),
                          Text('Météo', style: TextStyle(color: baseText)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: baseText, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.opacity, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Text('Humidité', style: TextStyle(color: baseText)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${humidity.toStringAsFixed(0)}%',
                        style: TextStyle(color: baseText),
                      ),
                    ],
                  ),
                ),
                // Colonne 2 : min/max / vent
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.thermostat, size: 16, color: highlight),
                          const SizedBox(width: 6),
                          Text(
                            'Min/Max',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: baseText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${temperatureMin.toStringAsFixed(1)}°C / ${temperatureMax.toStringAsFixed(1)}°C',
                        style: TextStyle(color: baseText),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.air_sharp, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Text('Vent', style: TextStyle(color: baseText)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${windSpeed.toStringAsFixed(1)} km/h',
                        style: TextStyle(color: baseText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
