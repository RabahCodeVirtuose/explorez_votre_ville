import 'package:explorez_votre_ville/widgets/info/carte_meteo.dart';
import 'package:flutter/material.dart';

/*final VoidCallback onToggleFavori; déclare un callback sans argument (alias de void Function() en Flutter) que le widget appellera pour basculer l’état favori. Il est passé par le parent
  et exécuté, par exemple, quand on appuie sur le bouton cœur.


› VoidCallback ? sert à quoi ?


• VoidCallback est juste un type alias pour void Function(). Il représente un callback sans paramètre qui ne retourne rien. On l’utilise pour des actions simples (bouton, toggle, etc.)
  dans les widgets.


› mais comment il parle avec le provider ?


• Le widget ne connaît pas le provider directement. Le parent ( l’écran) branche le callback vers le provider. Exemple classique dans l’écran :

  WeatherSection(
    weather: provider.weather,
    isFavori: provider.isFavoriActuel,
    onToggleFavori: provider.basculerFavoriActuel, // <- on passe la méthode du provider
  )

  Dans WeatherSection, quand on appuie sur le cœur, il appelle onToggleFavori(), ce qui exécute la méthode du provider, met à jour l’état et déclenche notifyListeners() ; les widgets
  abonnés se reconstruisent ensuite avec le nouveau statut. */
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
