import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

// AppMenuDrawer
// On met ici le menu latéral de l application
// L objectif est de réutiliser ce Drawer sur plusieurs écrans
// On garde peu d options pour rester simple
class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // On récupère les couleurs du thème pour que le menu s adapte au mode clair ou sombre
    final cs = Theme.of(context).colorScheme;

    // Drawer est le widget Material prévu pour le menu latéral
    return Drawer(
      // SafeArea évite que le contenu passe sous la barre du haut (encoche etc)
      child: SafeArea(
        // ListView permet de scroller si le menu devient plus long plus tard
        child: ListView(
          // On enlève le padding par défaut
          padding: EdgeInsets.zero,
          children: [
            // En haut on affiche une zone d entête
            // On met un fond coloré et un titre simple
            DrawerHeader(
              decoration: BoxDecoration(color: cs.primaryContainer),
              child: Column(
                // On aligne à gauche
                crossAxisAlignment: CrossAxisAlignment.start,
                // On pousse le texte en bas de l entête
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Titre de l application
                  Text(
                    'Explorez votre ville',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sous titre pour expliquer le rôle du menu
                  Text(
                    'Actions rapides',
                    style: TextStyle(color: cs.onPrimaryContainer),
                  ),
                ],
              ),
            ),

            // Lien vers l écran des favoris
            // On ferme le drawer puis on navigue
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Mes villes favorites'),
              onTap: () {
                // On ferme le drawer pour éviter d empiler deux pages avec le menu ouvert
                Navigator.pop(context);

                // On navigue vers la route favoris définie dans MaterialApp
                Navigator.pushNamed(context, '/favoris');
              },
            ),

            // Option pour basculer clair sombre
            // On appelle ThemeProvider qui gère themeMode
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Basculer theme clair/sombre'),
              onTap: () {
                // On ferme le drawer d abord pour un rendu propre
                Navigator.pop(context);

                // On demande au provider de changer de mode
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }
}
