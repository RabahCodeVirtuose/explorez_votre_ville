import 'package:flutter/material.dart'; // Material UI

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24), // Marges internes
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centre vertical
              children: [
                const Text(
                  'Explorez votre ville', // Titre
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24), // Espacement
                const Text(
                  'Cherche une ville, consulte la meteo,\nles infos, et la carte.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32), // Espacement
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'), // Aller ecran principal
                  child: const Text('Commencer'), // Libelle bouton
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
