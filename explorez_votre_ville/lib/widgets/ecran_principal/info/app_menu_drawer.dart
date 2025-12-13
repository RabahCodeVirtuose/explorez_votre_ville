import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

/// Drawer principal rÉutilisable.
/// - Lien vers la page des favoris.
/// - Bouton pour basculer le thÉme clair/sombre.
class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: cs.primaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Explorez votre ville',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Actions rapides',
                    style: TextStyle(color: cs.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Mes villes favorites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/favoris');
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Basculer thÉme clair/sombre'),
              onTap: () {
                Navigator.pop(context);
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }
}
