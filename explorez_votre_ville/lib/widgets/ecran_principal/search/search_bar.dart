//
// Ce widget représente une barre de recherche simple
// On reçoit un controller pour lire et modifier le texte
// On reçoit onSubmitted pour lancer la recherche quand on valide au clavier
// On utilise les couleurs du thème pour rester cohérent en clair et en sombre

import 'package:flutter/material.dart';

class SearchBarField extends StatelessWidget {
  // Le controller permet de récupérer le texte tapé et de le vider si besoin
  final TextEditingController controller;

  // Fonction appelée quand on appuie sur Entrée ou Valider sur le clavier
  final ValueChanged<String> onSubmitted;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // On prend le ColorScheme du thème pour utiliser les bonnes couleurs
    final cs = Theme.of(context).colorScheme;

    return TextField(
      // On branche le champ au controller reçu du parent
      controller: controller,

      // InputDecoration gère le style du champ
      decoration: InputDecoration(
        // Texte affiché quand le champ est vide
        hintText: 'Rechercher une ville…',

        // filled true permet de mettre une couleur de fond
        filled: true,
        fillColor: cs.surface,

        // Icône de loupe à gauche
        prefixIcon: Icon(Icons.search, color: cs.onSurface),

        // Couleur du hint plus discrète
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),

        // Bordure quand le champ n est pas sélectionné
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.tertiary, width: 1.5),
        ),

        // Bordure quand le champ est sélectionné
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),

      // Quand on valide le texte on appelle la fonction du parent
      // Le parent peut ensuite déclencher la recherche API
      onSubmitted: onSubmitted,
    );
  }
}
