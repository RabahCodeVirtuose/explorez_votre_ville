import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "providers/ville_provider.dart";
import "providers/commentaire_provider.dart";
import "screens/ecran_acceuil.dart";
import "screens/ecran_liste_villes.dart";
import "screens/ecran_favoris.dart";
import "screens/ecran_detail_lieu.dart";
import "screens/ecran_edition_lieu.dart";

void main() {
  // Injection des providers globaux à la racine.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VilleProvider()),
        ChangeNotifierProvider(create: (_) => CommentaireProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Explorez votre ville',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, // couleur seed globale
      ),
      // Routes principales.
      routes: {
        '/': (_) => const EcranAccueil(),
        '/home': (_) => const EcranListeVilles(),
        '/favoris': (_) => const EcranFavoris(),
      },
      // Routes nécessitant des arguments.
      onGenerateRoute: (settings) {
        if (settings.name == '/details_lieu') {
          final id = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (_) => EcranDetailLieu(lieuId: id),
          );
        }
        if (settings.name == '/edit_lieu') {
          final id = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (_) => EcranEditionLieu(lieuId: id),
          );
        }
        return null;
      },
    );
  }
}
