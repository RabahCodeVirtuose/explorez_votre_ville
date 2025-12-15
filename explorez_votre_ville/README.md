# Explorez votre ville

**Explorez votre ville** est une application mobile développée avec Flutter.
Elle permet à l’utilisateur de rechercher une ville, de consulter sa météo,
d’explorer des lieux d’intérêt sur une carte interactive et de gérer des villes
et lieux favoris avec une persistance locale.

---

## Objectif du projet

L’objectif principal de ce projet est de mettre en pratique les concepts vus en
cours de développement mobile, notamment :

- la conception d’une application Flutter bien structurée
- l’utilisation d’API externes pour récupérer des données en temps réel
- la gestion d’une base de données locale avec SQLite
- la gestion de l’état de l’application à l’aide de Provider
- la mise en place d’une interface utilisateur responsive et adaptée
  aux thèmes clair et sombre

Ce projet vise également à renforcer la compréhension de l’architecture d’une
application Flutter complète, depuis la récupération des données jusqu’à leur
affichage.

---

## Fonctionnalités principales

L’application propose les fonctionnalités suivantes :

- Recherche de villes à partir d’une saisie utilisateur (API Nominatim)
- Affichage des informations météo d’une ville sélectionnée (API OpenWeather)
- Visualisation d’une carte interactive avec les lieux d’intérêt (POI)
- Filtrage des lieux par type (parc, musée, restaurant, etc.)
- Ajout de lieux personnalisés directement depuis la carte
- Gestion des villes favorites avec différents statuts
  (favorite, visitée, explorée)
- Gestion des lieux favoris associés à une ville
- Ajout et consultation de commentaires sur un lieu
- Bascule dynamique entre thème clair et thème sombre

---

## Architecture du projet

Le projet est organisé de manière modulaire afin de faciliter la lisibilité
et la maintenance du code :

- `api/`  
  Contient les fichiers responsables des appels aux API externes
  (météo, villes, lieux)

- `db/`  
  Gère la base de données locale SQLite et les repositories
  pour l’accès aux données

- `models/`  
  Définit les modèles de données utilisés dans l’application
  (Ville, Lieu, Commentaire, Météo, etc.)

- `providers/`  
  Gère l’état global de l’application à l’aide du pattern Provider

- `screens/`  
  Contient les différents écrans principaux de l’application

- `widgets/`  
  Regroupe les widgets réutilisables, organisés par fonctionnalité

- `utils/`  
  Fonctions utilitaires, notamment pour le mapping des types de lieux
  vers les catégories des API

---

## Technologies utilisées

- Flutter / Dart
- Provider pour la gestion de l’état
- SQLite pour la persistance locale
- Flutter Map pour l’affichage cartographique
- API OpenWeather pour la météo
- API Nominatim / Geoapify pour la recherche de villes et de lieux

---

## Lancement du projet

1. Installer les dépendances du projet :
```bash
flutter pub get
````

2. Lancer l’application sur un émulateur ou un appareil :

```bash
flutter run
```

---


## Auteurs

* **Rabah TOUBAL**
* **Mouhammed Haady TIEMTORE**


