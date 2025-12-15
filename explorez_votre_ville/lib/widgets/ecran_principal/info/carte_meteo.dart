import 'package:flutter/material.dart';

// MeteoCard
// Cette carte affiche les informations météo principales pour une ville
// On utilise uniquement les couleurs du thème pour s adapter au clair et au sombre
// Le but est d avoir une carte lisible, simple et cohérente avec le reste de l application
class MeteoCard extends StatelessWidget {
  // Nom de la ville affichée
  final String cityName;

  // Température actuelle
  final double temperature;

  // Code de l icône météo fourni par OpenWeather
  final String icon;

  // Description textuelle de la météo (ex ciel dégagé)
  final String description;

  // Température minimale
  final double temperatureMin;

  // Température maximale
  final double temperatureMax;

  // Taux d humidité
  final int humidity;

  // Vitesse du vent
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
    // On récupère le ColorScheme du thème courant
    // Comme ça la carte s adapte automatiquement au thème clair ou sombre
    final cs = Theme.of(context).colorScheme;

    // URL de l icône météo fournie par l API OpenWeather
    final iconUrl = 'https://openweathermap.org/img/w/$icon.png';

    // On définit quelques couleurs locales à partir du thème
    // Cela évite de dupliquer Theme.of(context) partout
    final baseText = cs.onSurface;
    final accent = cs.primary;
    final highlight = cs.tertiary;
    final surface = cs.surface;

    // Card est utilisée pour donner un rendu propre et cohérent
    return Card(
      color: surface,
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: highlight, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          // On limite la taille verticale à ce qui est nécessaire
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre avec le nom de la ville
            // Expanded permet d éviter un overflow si le nom est long
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

            // Ligne principale avec l icône météo et la température actuelle
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icône météo dans un cercle légèrement coloré
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

                // Température actuelle mise en valeur
                Expanded(
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

            // Deux colonnes pour afficher les infos complémentaires
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne gauche : description météo et humidité
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Libellé météo
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, size: 16, color: highlight),
                          const SizedBox(width: 6),
                          Text('Météo', style: TextStyle(color: baseText)),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Description textuelle de la météo
                      Text(
                        description,
                        style: TextStyle(color: baseText, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Humidité
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

                // Colonne droite : températures min max et vent
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Températures min et max
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

                      // Vent
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
