import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_meteo.dart';
import '../api/api_villes.dart';
import '../db/repository/lieu_repository.dart';
import '../db/repository/ville_repository.dart';
import '../models/lieu.dart';
import '../models/lieu_type.dart';
import '../models/weather_data.dart';
import '../models/ville.dart';

/// Provider central qui pilote :
/// - la ville et la meteo courantes,
/// - le chargement des lieux (POI) selon un type,
/// - la persistance des favoris (villes + lieux) en base SQLite,
/// - la ville « epinglee » stockee en SharedPreferences pour l'ouverture.
class VilleProvider with ChangeNotifier {
  // Centre par defaut (Paris) utilise quand aucune ville n'est encore chargee.
  final LatLng _defaultCenter = const LatLng(48.8566, 2.3522);

  // Etat courant issu des APIs.
  WeatherData? _weather; // Meteo complete (OpenWeather)
  VilleApiResult? _ville; // Infos ville (Nominatim)

  // Meta-etat de chargement.
  bool _loading = false;
  String? _error;
  String? _lastQuery;

  // Lieux (POI) affiches pour le type selectionne.
  List<LieuApiResult> _lieux = <LieuApiResult>[];
  LieuType _type = LieuType.parc;
  bool _loadingLieux = false;

  // Gestion des favoris.
  bool _isFavoriActuel = false; // Statut favori de la ville courante
  bool _isVisiteeActuelle = false; // Ville visitée
  bool _isExploreeActuelle = false; // Ville explorée
  List<Lieu> _lieuxFavoris =
      <Lieu>[]; // Lieux favoris (en base) pour la ville courante
  int? _pinnedVilleId; // Identifiant de la ville epinglee (SharedPreferences)

  // Repositories d'acces a la base locale.
  final VilleRepository _villeRepo = VilleRepository();
  final LieuRepository _lieuRepo = LieuRepository();

  // Getters exposes aux widgets.
  WeatherData? get weather => _weather;
  VilleApiResult? get ville => _ville;
  bool get loading => _loading;
  String? get error => _error;
  List<LieuApiResult> get lieux => _lieux;
  LieuType get type => _type;
  bool get loadingLieux => _loadingLieux;
  bool get isFavoriActuel => _isFavoriActuel;
  bool get isVisiteeActuelle => _isVisiteeActuelle;
  bool get isExploreeActuelle => _isExploreeActuelle;
  List<Lieu> get lieuxFavoris => _lieuxFavoris;
  int? get pinnedVilleId => _pinnedVilleId;

  /// Coordonnees a utiliser pour centrer la carte
  /// (meteo > ville > valeur par defaut).
  LatLng get mapCenter {
    if (_weather != null) return _weather!.coordonnees;
    if (_ville != null) return LatLng(_ville!.lat, _ville!.lon);
    return _defaultCenter;
  }

  /// Remet tout l'etat a zero (utilise pour reinitialiser la page).
  void reset() {
    _weather = null;
    _ville = null;
    _error = null;
    _loading = false;
    _lastQuery = null;
    _lieux = <LieuApiResult>[];
    _type = LieuType.parc;
    _loadingLieux = false;
    _isFavoriActuel = false;
    _isVisiteeActuelle = false;
    _isExploreeActuelle = false;
    _lieuxFavoris = <Lieu>[];
    _pinnedVilleId = null;
    notifyListeners();
  }

  /// Recherche en base locale une ville par son nom (casse ignoree).
  Future<Ville?> _trouverVilleParNom(String nom) async {
    final list = await _villeRepo.searchVillesByName(nom);
    for (final v in list) {
      if (v.nom.toLowerCase() == nom.toLowerCase()) {
        return v;
      }
    }
    return null;
  }

  /// Aligne le statut favori de la ville courante sur la base locale.
  Future<void> _synchroniserFavoriActuel() async {
    if (_weather == null) {
      _isFavoriActuel = false;
      _isVisiteeActuelle = false;
      _isExploreeActuelle = false;
      return;
    }
    final existing = await _trouverVilleParNom(_weather!.cityName);
    _isFavoriActuel = existing?.isFavorie == true;
    _isVisiteeActuelle = existing?.isVisitee == true;
    _isExploreeActuelle = existing?.isExploree == true;
    notifyListeners();
  }

  /// Recupere la ville courante en base ou l'insere si absente.
  /// Conserve le statut favori courant.
  Future<Ville?> _getOrInsertVilleCourante() async {
    if (_weather == null) return null;

    // 1. Cherche si la ville existe deja.
    final existing = await _trouverVilleParNom(_weather!.cityName);
    if (existing != null) return existing;

    // 2. Sinon, cree et insere une nouvelle entree.
    final nouvelle = Ville(
      nom: _weather!.cityName,
      latitude: _weather?.coordonnees.latitude,
      longitude: _weather?.coordonnees.longitude,
      isFavorie: _isFavoriActuel,
      isVisitee: _isVisiteeActuelle,
      isExploree: _isExploreeActuelle,
    );
    final id = await _villeRepo.insertVille(nouvelle);
    return nouvelle.copyWith(id: id);
  }

  /// Charge les lieux favoris en base pour une ville donnee.
  Future<void> _chargerLieuxFavorisPourVille(Ville ville) async {
    _lieuxFavoris = await _lieuRepo.getLieuxByVilleId(ville.id!);
    notifyListeners();
  }

  /// Charge les lieux favoris pour la ville courante, ou vide la liste.
  Future<void> _chargerFavorisVilleCourante() async {
    if (_weather == null) {
      _lieuxFavoris = <Lieu>[];
      notifyListeners();
      return;
    }
    final v = await _trouverVilleParNom(_weather!.cityName);
    if (v?.id != null) {
      await _chargerLieuxFavorisPourVille(v!);
    } else {
      _lieuxFavoris = <Lieu>[];
      notifyListeners();
    }
  }

  /// Lit en SharedPreferences l'id de la ville epinglee (si existante).
  Future<void> chargerPinnedDepuisPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _pinnedVilleId = prefs.getInt('pinned_ville_id');
    notifyListeners();
  }

  /// Epingler une ville (enregistre l'id dans SharedPreferences).
  Future<void> epinglerVille(Ville ville) async {
    if (ville.id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pinned_ville_id', ville.id!);
    _pinnedVilleId = ville.id;
    notifyListeners();
  }

  /// Supprime l'epingle courante.
  Future<void> deseEpinglerVille() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pinned_ville_id');
    _pinnedVilleId = null;
    notifyListeners();
  }

  /// Si une ville est epinglee, relance la recherche pour l'afficher.
  Future<void> afficherVilleEpinglee() async {
    if (_pinnedVilleId == null) return;
    final ville = await _villeRepo.getVilleById(_pinnedVilleId!);
    if (ville != null) {
      await chercherVille(ville.nom);
    }
  }

  /// Marque une ville comme favorite en base et dans l'etat.
  Future<void> marquerFavori(Ville ville) async {
    if (ville.id == null) {
      await _villeRepo.insertVille(ville.copyWith(isFavorie: true));
    } else {
      await _villeRepo.updateVille(ville.copyWith(isFavorie: true));
    }
    _isFavoriActuel = true;
    notifyListeners();
  }

  /// Retire le statut favori pour la ville passee.
  Future<void> retirerFavori(Ville ville) async {
    if (ville.id != null) {
      await _villeRepo.updateVille(ville.copyWith(isFavorie: false));
    }
    _isFavoriActuel = false;
    notifyListeners();
  }

  /// Renvoie toutes les villes favorites stockees en base locale.
  Future<List<Ville>> chargerFavoris() async {
    return _villeRepo.getVillesFavorites();
  }

  /// Supprime une ville en base (et désépingle si c'était celle en cours),
  /// et nettoie les états locaux si la ville courante est concernée.
  Future<void> supprimerVille(int id) async {
    // On récupère l'id de la ville courante avant suppression
    Ville? current;
    if (_weather != null) {
      current = await _trouverVilleParNom(_weather!.cityName);
    }

    await _villeRepo.deleteVille(id);

    // Si c'était la ville épinglée, on la désépingle.
    if (_pinnedVilleId == id) {
      _pinnedVilleId = null;
    }

    // Si c'était la ville actuellement affichée, on met à jour les flags locaux.
    if (current?.id == id) {
      reset();
    }

    notifyListeners();
  }

  /// Appel principal : cherche une ville, sa meteo, puis charge les lieux,
  /// synchronise le statut favori et les lieux favoris.
  Future<void> chercherVille(String nomVille) async {
    final query = nomVille.trim();
    if (query.isEmpty) {
      _error = 'Saisis une ville';
      notifyListeners();
      return;
    }

    _lastQuery = query;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final villeTrouvee = await ApiVillesEtLieux.fetchVilleDepuisNominatim(
        query,
      );
      final meteo = await ApiMeteo.fetchParVille(query);

      _ville = villeTrouvee;
      _weather = meteo;
      await _chargerLieux(type: _type);
      await _synchroniserFavoriActuel();
      await _chargerFavorisVilleCourante();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Récupère un lieu par son id (accès indirect au repo).
  Future<Lieu?> getLieuById(int id) async {
    return _lieuRepo.getLieuById(id);
  }

  /// Change le type de lieu a afficher et recharge les POI.
  Future<void> changerType(LieuType type) async {
    _type = type;
    await _chargerLieux(type: type);
  }

  /// Ajoute ou retire la ville courante des favoris, puis resynchronise l'etat.
  Future<void> basculerFavoriActuel() async {
    if (_weather == null) return;
    final nom = _weather!.cityName;
    final existing = await _trouverVilleParNom(nom);

    if (existing == null) {
      final nouvelle = Ville(
        nom: nom,
        pays: null,
        latitude: _weather?.coordonnees.latitude,
        longitude: _weather?.coordonnees.longitude,
        isFavorie: true,
        isVisitee: _isVisiteeActuelle,
        isExploree: _isExploreeActuelle,
      );
      await marquerFavori(nouvelle);
    } else {
      if (existing.isFavorie) {
        await retirerFavori(existing);
      } else {
        await marquerFavori(existing);
      }
    }
    await _synchroniserFavoriActuel();
  }

  /// Bascule le statut "visitee" sur la ville courante.
  Future<void> basculerVisiteeActuelle() async {
    if (_weather == null) return;
    final nom = _weather!.cityName;
    final existing = await _trouverVilleParNom(nom);

    if (existing == null) {
      final nouvelle = Ville(
        nom: nom,
        pays: null,
        latitude: _weather?.coordonnees.latitude,
        longitude: _weather?.coordonnees.longitude,
        isFavorie: _isFavoriActuel,
        isVisitee: true,
        isExploree: _isExploreeActuelle,
      );
      final id = await _villeRepo.insertVille(nouvelle);
      _isVisiteeActuelle = true;
      await _chargerFavorisVilleCourante();
    } else {
      final updated = existing.copyWith(isVisitee: !existing.isVisitee);
      await _villeRepo.updateVille(updated);
      _isVisiteeActuelle = updated.isVisitee;
    }
    notifyListeners();
  }

  /// Bascule le statut "explorée" sur la ville courante.
  Future<void> basculerExploreeActuelle() async {
    if (_weather == null) return;
    final nom = _weather!.cityName;
    final existing = await _trouverVilleParNom(nom);

    if (existing == null) {
      final nouvelle = Ville(
        nom: nom,
        pays: null,
        latitude: _weather?.coordonnees.latitude,
        longitude: _weather?.coordonnees.longitude,
        isFavorie: _isFavoriActuel,
        isVisitee: _isVisiteeActuelle,
        isExploree: true,
      );
      final id = await _villeRepo.insertVille(nouvelle);
      _isExploreeActuelle = true;
      await _chargerFavorisVilleCourante();
    } else {
      final updated = existing.copyWith(isExploree: !existing.isExploree);
      await _villeRepo.updateVille(updated);
      _isExploreeActuelle = updated.isExploree;
    }
    notifyListeners();
  }

  /// Enregistre un lieu favori pour la ville courante (nom+ville non dupliques).
  Future<void> ajouterLieuFavori(LieuApiResult poi) async {
    if (_weather == null) return;

    // S'assure que la ville courante est presente en base.
    final villeCourante = await _getOrInsertVilleCourante();
    if (villeCourante == null || villeCourante.id == null) return;

    // Evite les doublons (nom + ville).
    final deja = await _lieuRepo.getLieuByNomEtVille(
      poi.name,
      villeCourante.id!,
    );
    if (deja != null) {
      await _chargerLieuxFavorisPourVille(villeCourante);
      return;
    }

    final lieu = Lieu(
      villeId: villeCourante.id!,
      nom: poi.name.isEmpty ? '(Sans nom)' : poi.name,
      type: _type,
      latitude: poi.lat,
      longitude: poi.lon,
      description: poi.formattedAddress,
    );
    await _lieuRepo.insertLieu(lieu);
    await _chargerLieuxFavorisPourVille(villeCourante);
  }

  /// Met à jour un lieu favori en base et dans la liste locale.
  Future<void> mettreAJourLieu(Lieu lieu) async {
    if (lieu.id == null) return;
    await _lieuRepo.updateLieu(lieu);
    _lieuxFavoris = _lieuxFavoris
        .map((l) => l.id == lieu.id ? lieu : l)
        .toList(growable: false);
    notifyListeners();
  }

  /// Supprime un lieu favori en base et met à jour l'état local.
  Future<void> supprimerLieuFavori(int id) async {
    await _lieuRepo.deleteLieu(id);
    _lieuxFavoris = _lieuxFavoris.where((l) => l.id != id).toList();
    notifyListeners();
  }

  /// Charge les lieux (POI) pour le type demande et met a jour l'etat UI.
  Future<void> _chargerLieux({required LieuType type}) async {
    if (_lastQuery == null || _lastQuery!.isEmpty) {
      _lieux = <LieuApiResult>[];
      notifyListeners();
      return;
    }

    // Vider la liste actuelle pour eviter d'afficher les anciens marqueurs
    // pendant le chargement du nouveau type.
    _lieux = <LieuApiResult>[];
    _loadingLieux = true;
    notifyListeners();
    try {
      final data = await ApiVillesEtLieux.fetchLieuxPourVille(
        nomVille: _lastQuery!,
        type: type,
        limit: 15,
      );
      _lieux = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingLieux = false;
      notifyListeners();
    }
  }
}
