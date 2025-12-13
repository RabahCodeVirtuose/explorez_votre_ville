import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil avec animation d'intro :
/// - Icône qui pulse
/// - Texte principal statique
/// - Sous-titre en effet "machine à écrire" (AnimatedTextKit)
/// L'animation du texte se rejoue à chaque retour sur l'écran.
class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  Key _animKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône qui pulse
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
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
                Text(
                  'Explorez votre ville',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onBackground,
                      ),
                ),
                const SizedBox(height: 16),
                // Texte animé (typewriter)
                AnimatedTextKit(
                  key: _animKey,
                  totalRepeatCount: 1,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Cherche une ville, consulte la météo,\nles infos et la carte.',
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 40),
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: cs.onBackground.withOpacity(0.8),
                              ),
                    ),
                  ],
                  pause: const Duration(milliseconds: 200),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
                const SizedBox(height: 32),
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
                    await Navigator.pushNamed(context, '/home');
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
