import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "providers/ville_provider.dart";
import "screens/ecran_acceuil.dart";
import "screens/ecran_liste_villes.dart";
import "screens/ecran_favoris.dart";

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VilleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorez votre ville',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      routes: {
        '/': (_) => const EcranAccueil(),
        '/home': (_) => const EcranListeVilles(),
        '/favoris': (_) => const EcranFavoris(),
      },
    );
  }
}
