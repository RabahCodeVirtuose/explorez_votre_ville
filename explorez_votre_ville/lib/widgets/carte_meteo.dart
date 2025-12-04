import 'package:flutter/material.dart';

/// Carte d'affichage des informations meteo.
class CarteMeteo extends StatelessWidget {
  const CarteMeteo({super.key, required this.meteo});

  final dynamic meteo; // WeatherData

  @override
  Widget build(BuildContext context) {
    // Affiche un bloc compact : ville + temperature + details
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meteo.cityName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${meteo.temperature.round()}\u00B0C',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meteo.description),
                      Text(
                        'Min/Max : ${meteo.temperatureMin.round()}\u00B0C / ${meteo.temperatureMax.round()}\u00B0C',
                      ),
                      Text('Humidite : ${meteo.humidity}%'),
                      Text('Vent : ${meteo.windSpeed} m/s'),
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
