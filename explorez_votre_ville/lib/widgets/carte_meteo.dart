import 'package:flutter/material.dart';

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
    final String iconUrl = 'https://openweathermap.org/img/w/$icon.png';

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la ville
            Text(
              cityName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Température avec icône
            Row(
              children: [
                Image.network(
                  iconUrl,
                  height: 60, // Définissez une taille appropriée
                  width: 60,

                  // Optionnel: Ajouter un placeholder ou une gestion d'erreur
                  /*errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.cloud_off, size: 60);
                  },*/
                ),
                const SizedBox(width: 12),
                Text(
                  '${temperature.toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Deux colonnes : météo/humidité et min/max/vent
            Row(
              children: [
                // Colonne 1
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Météo
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, size: 18, color: Colors.orange),

                          /*Image.network(
                            iconUrl,
                            height: 60, // Définissez une taille appropriée
                            width: 60,
                            // Optionnel: Ajouter un placeholder ou une gestion d'erreur
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.cloud_off, size: 60);
                            },
                          ),*/
                          SizedBox(width: 6),
                          Text('Météo'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(description), // description en dessous

                      const SizedBox(height: 8),

                      // Humidité
                      Row(
                        children: [
                          Icon(Icons.opacity, size: 18, color: Colors.blue),

                          /*Image.network(
                            iconUrl,
                            height: 60, // Définissez une taille appropriée
                            width: 60,
                            // Optionnel: Ajouter un placeholder ou une gestion d'erreur
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.cloud_off, size: 60);
                            },
                          ),*/
                          SizedBox(width: 6),
                          Text('Humidité'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${humidity.toStringAsFixed(0)}%'),
                    ],
                  ),
                ),

                // Colonne 2
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne Min/Max
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.thermostat,
                                size: 18,
                                color: Colors.red,
                              ),
                              SizedBox(width: 6),
                              const Text(
                                'Min/Max',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${temperatureMin.toStringAsFixed(1)}°C / ${temperatureMax.toStringAsFixed(1)}°C',
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // Ligne Vent
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.air_sharp, size: 18),

                              /*Image.network(
                                iconUrl,
                                height: 60, // Définissez une taille appropriée
                                width: 60,
                                // Optionnel: Ajouter un placeholder ou une gestion d'erreur
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.cloud_off, size: 60);
                                },
                              ),*/
                              SizedBox(width: 6),
                              Text('Vent'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${windSpeed.toStringAsFixed(1)} km/h'),
                        ],
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
