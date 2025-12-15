import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil (intro) de l'application.
/// Objectif : afficher une intro simple avec une petite animation,
/// puis permettre d'aller vers l'écran principal (/home).
class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  /// Clé utilisée pour "rejouer" l'animation du texte.
  /// Quand on revient sur cet écran (après /home),
  /// on change la Key -> AnimatedTextKit redémarre.
  Key _animKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    // Récupère les couleurs du thème (claire/sombre)
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        // SafeArea évite d'être sous la barre de statut / encoche
        child: Center(
          child: Padding(
            // Padding global pour éviter que tout soit collé aux bords
            padding: const EdgeInsets.all(24),
            child: Column(
              // Centre verticalement la colonne
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ------------------------------
                // 1) Icône avec effet "pulse"
                // ------------------------------
                // TweenAnimationBuilder anime une valeur de 0.8 à 1.0
                // Ici on l'utilise pour faire un "zoom" très léger.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    // Transform.scale applique le facteur d'échelle
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  // child est "stable" : Flutter ne le rebuild pas à chaque frame
                  child: Container(
                    // Cercle de fond légèrement coloré
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withOpacity(0.15),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Icon(
                      Icons.travel_explore,
                      size: 48,
                      color: cs.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ------------------------------
                // 2) Titre principal
                // ------------------------------
                Text(
                  'Explorez votre ville',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onBackground,
                      ),
                ),

                const SizedBox(height: 16),

                // ------------------------------
                // 3) Sous-titre animé (typewriter)
                // ------------------------------
                // AnimatedTextKit affiche un texte animé.
                // On lui donne une Key (_animKey) pour pouvoir relancer l'anim.
                AnimatedTextKit(
                  key: _animKey,
                  // On ne répète l'animation qu'une seule fois
                  totalRepeatCount: 1,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      // Le \n force le retour à la ligne pour un rendu plus lisible
                      'Cherche une ville, consulte la météo,\nles infos et la carte.',
                      textAlign: TextAlign.center,
                      // vitesse d'écriture
                      speed: const Duration(milliseconds: 40),
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: cs.onBackground.withOpacity(0.8),
                              ),
                    ),
                  ],
                  // petite pause à la fin (avant arrêt)
                  pause: const Duration(milliseconds: 200),
                  // si l'utilisateur tape : afficher tout le texte directement
                  displayFullTextOnTap: true,
                  // et arrêter la pause si on tape
                  stopPauseOnTap: true,
                ),

                const SizedBox(height: 32),

                // ------------------------------
                // 4) Bouton "Commencer"
                // ------------------------------
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    // Navigation vers l'écran principal
                    await Navigator.pushNamed(context, '/home');

                    // Quand on revient, on relance l'animation du texte :
                    // changer la Key force AnimatedTextKit à repartir de zéro.
                    if (mounted) {
                      setState(() => _animKey = UniqueKey());
                    }
                  },
                  label: const Text('Commencer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
