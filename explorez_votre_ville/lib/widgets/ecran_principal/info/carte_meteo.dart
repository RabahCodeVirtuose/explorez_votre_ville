import 'package:flutter/material.dart';

class MeteoCard extends StatelessWidget {
  // Palette dédiée
  static const Color _deepGreen = Color(0xFF18534F);
  static const Color _teal = Color(0xFF226D68);
  static const Color _mint = Color(0xFFECF8F6);
  static const Color _amber = Color(0xFFFEEAA1);
  static const Color _sand = Color(0xFFD6955B);

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
    final String iconUrl = 'https://openweathermap.org/img/w/$icon.png';

    return Card(
      color: _mint,
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _amber, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre + favori en ligne pour compacter
            Row(
              children: [
                Expanded(
                  child: Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _deepGreen,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Température avec icône
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _amber.withOpacity(0.7),
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
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _teal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Deux colonnes : météo/humidité et min/max/vent
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne 1
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny,
                            size: 16,
                            color: _sand,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Météo',
                            style: TextStyle(color: _deepGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(color: _deepGreen, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.opacity,
                            size: 16,
                            color: _teal,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Humidité',
                            style: TextStyle(color: _deepGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${humidity.toStringAsFixed(0)}%',
                        style: const TextStyle(color: _deepGreen),
                      ),
                    ],
                  ),
                ),
                // Colonne 2
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            size: 16,
                            color: _sand,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Min/Max',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _deepGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${temperatureMin.toStringAsFixed(1)}°C / ${temperatureMax.toStringAsFixed(1)}°C',
                        style: const TextStyle(color: _deepGreen),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.air_sharp,
                            size: 16,
                            color: _teal,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Vent',
                            style: TextStyle(color: _deepGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${windSpeed.toStringAsFixed(1)} km/h',
                        style: const TextStyle(color: _deepGreen),
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
