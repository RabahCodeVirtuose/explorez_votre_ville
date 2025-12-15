//
// Point d entrée de l application
// Ici on démarre Flutter et on place les providers au niveau racine
// Comme ça tous les écrans peuvent accéder aux données et au thème

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/ville_provider.dart';
import 'providers/commentaire_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/ecran_acceuil.dart';
import 'screens/ecran_liste_villes.dart';
import 'screens/ecran_favoris.dart';
import 'screens/ecran_detail_lieu.dart';
import 'screens/ecran_edition_lieu.dart';

void main() {
  // On lance l application
  // On place MultiProvider au dessus de MyApp pour rendre les providers accessibles partout
  runApp(
    MultiProvider(
      providers: [
        // On gère la logique des villes et des lieux dans VilleProvider
        ChangeNotifierProvider(create: (_) => VilleProvider()),

        // On gère la logique des commentaires dans CommentaireProvider
        ChangeNotifierProvider(create: (_) => CommentaireProvider()),

        // On gère le thème clair et sombre dans ThemeProvider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute ThemeProvider
    // Si le thème change l app se reconstruit automatiquement
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Explorez votre ville',

      // Thèmes de l application
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,

      // Routes simples qui ne demandent pas d arguments
      routes: {
        '/': (_) => const EcranAccueil(),
        '/home': (_) => const EcranListeVilles(),
        '/favoris': (_) => const EcranFavoris(),
      },

      // Routes qui ont besoin d un argument
      // Exemple on passe l id du lieu pour ouvrir la page détail ou édition
      onGenerateRoute: (settings) {
        if (settings.name == '/details_lieu') {
          final id = settings.arguments as int?;
          return MaterialPageRoute(builder: (_) => EcranDetailLieu(lieuId: id));
        }

        if (settings.name == '/edit_lieu') {
          final id = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (_) => EcranEditionLieu(lieuId: id),
          );
        }

        // Si on ne reconnaît pas la route on renvoie null
        // Flutter gère alors l erreur ou l écran inconnu selon la config
        return null;
      },
    );
  }
}
