// lib/providers/ville_provider.dart
//
// Provider central de l application
// On gère ici la ville courante la météo les lieux POI et les favoris
// On sépare l état et les actions pour garder un fichier lisible
// On utilise notifyListeners quand on change un état visible par l UI

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

class VilleProvider with ChangeNotifier {
  // Etat principal
  final LatLng _defaultCenter = const LatLng(48.8566, 2.3522);

  WeatherData? _weather;
  VilleApiResult? _ville;

  bool _loading = false;
  String? _error;

  // Lieux POI chargés depuis Geoapify
  List<LieuApiResult> _lieux = <LieuApiResult>[];
  LieuType _type = LieuType.parc;
  bool _loadingLieux = false;

  // Favoris et statuts de la ville courante
  bool _isFavoriActuel = false;
  bool _isVisiteeActuelle = false;
  bool _isExploreeActuelle = false;

  // Favoris lieux stockés en base pour la ville courante
  List<Lieu> _lieuxFavoris = <Lieu>[];

  // Ville épinglée en local
  int? _pinnedVilleId;

  // Accès base locale
  final VilleRepository _villeRepo = VilleRepository();
  final LieuRepository _lieuRepo = LieuRepository();

  // Getters pour l UI
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

  // Centre de carte
  // On préfère les coordonnées météo car c est la ville réelle de l API
  LatLng get mapCenter {
    if (_weather != null) return _weather!.coordonnees;
    if (_ville != null) return LatLng(_ville!.lat, _ville!.lon);
    return _defaultCenter;
  }

  // Petites méthodes internes pour éviter de répéter du code
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setLoadingLieux(bool value) {
    _loadingLieux = value;
    notifyListeners();
  }

  // Reset complet
  void reset() {
    _weather = null;
    _ville = null;
    _error = null;

    _loading = false;

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

  // Trouver une ville en base par nom
  // On compare en minuscule pour éviter les différences Paris paris etc
  Future<Ville?> _trouverVilleParNom(String nom) async {
    final list = await _villeRepo.searchVillesByName(nom);
    final cible = nom.toLowerCase();

    for (final v in list) {
      if (v.nom.toLowerCase() == cible) return v;
    }
    return null;
  }

  // Mettre à jour les indicateurs de la ville courante à partir de la base
  Future<void> _synchroniserStatutsVilleCourante() async {
    if (_weather == null) {
      _isFavoriActuel = false;
      _isVisiteeActuelle = false;
      _isExploreeActuelle = false;
      notifyListeners();
      return;
    }

    final existing = await _trouverVilleParNom(_weather!.cityName);
    _isFavoriActuel = existing?.isFavorie == true;
    _isVisiteeActuelle = existing?.isVisitee == true;
    _isExploreeActuelle = existing?.isExploree == true;

    notifyListeners();
  }

  // Récupérer la ville courante en base
  // Si elle n existe pas on l insère
  Future<Ville?> _getOrInsertVilleCourante() async {
    if (_weather == null) return null;

    final existing = await _trouverVilleParNom(_weather!.cityName);
    if (existing != null) return existing;

    final nouvelle = Ville(
      nom: _weather!.cityName,
      latitude: _weather!.coordonnees.latitude,
      longitude: _weather!.coordonnees.longitude,
      isFavorie: _isFavoriActuel,
      isVisitee: _isVisiteeActuelle,
      isExploree: _isExploreeActuelle,
    );

    final id = await _villeRepo.insertVille(nouvelle);
    return nouvelle.copyWith(id: id);
  }

  // Charger les lieux favoris stockés en base pour une ville
  Future<void> _chargerLieuxFavorisPourVille(Ville ville) async {
    if (ville.id == null) return;
    _lieuxFavoris = await _lieuRepo.getLieuxByVilleId(ville.id!);
    notifyListeners();
  }

  // Charger les lieux favoris pour la ville courante
  Future<void> _chargerFavorisVilleCourante() async {
    if (_weather == null) {
      _lieuxFavoris = <Lieu>[];
      notifyListeners();
      return;
    }

    final v = await _trouverVilleParNom(_weather!.cityName);
    if (v?.id == null) {
      _lieuxFavoris = <Lieu>[];
      notifyListeners();
      return;
    }

    await _chargerLieuxFavorisPourVille(v!);
  }

  // SharedPreferences
  Future<void> chargerPinnedDepuisPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _pinnedVilleId = prefs.getInt('pinned_ville_id');
    notifyListeners();
  }

  Future<void> epinglerVille(Ville ville) async {
    if (ville.id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pinned_ville_id', ville.id!);
    _pinnedVilleId = ville.id;
    notifyListeners();
  }

  Future<void> deseEpinglerVille() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pinned_ville_id');
    _pinnedVilleId = null;
    notifyListeners();
  }

  Future<void> afficherVilleEpinglee() async {
    if (_pinnedVilleId == null) return;
    final v = await _villeRepo.getVilleById(_pinnedVilleId!);
    if (v != null) await chercherVille(v.nom);
  }

  // Favoris villes
  Future<void> marquerFavori(Ville ville) async {
    if (ville.id == null) {
      await _villeRepo.insertVille(ville.copyWith(isFavorie: true));
    } else {
      await _villeRepo.updateVille(ville.copyWith(isFavorie: true));
    }

    _isFavoriActuel = true;
    notifyListeners();
  }

  Future<void> retirerFavori(Ville ville) async {
    if (ville.id != null) {
      await _villeRepo.updateVille(ville.copyWith(isFavorie: false));
    }

    _isFavoriActuel = false;
    notifyListeners();
  }

  Future<List<Ville>> chargerFavoris() async {
    return _villeRepo.getVillesFavorites();
  }

  Future<void> supprimerVille(int id) async {
    Ville? current;
    if (_weather != null) {
      current = await _trouverVilleParNom(_weather!.cityName);
    }

    await _villeRepo.deleteVille(id);

    if (_pinnedVilleId == id) _pinnedVilleId = null;
    if (current?.id == id) reset();

    notifyListeners();
  }

  // Proposer plusieurs villes via Nominatim
  Future<List<VilleApiResult>> proposerVilles(String nomVille) async {
    return ApiVillesEtLieux.fetchVillesDepuisNominatimList(nomVille);
  }

  // Appliquer une ville sélectionnée depuis la liste
  Future<void> appliquerVilleSelectionnee(VilleApiResult ville) async {
    _ville = ville;
    _setLoading(true);
    _setError(null);

    try {
      _weather = await ApiMeteo.fetchParCoordonnees(
        latitude: ville.lat,
        longitude: ville.lon,
      );

      await _chargerLieux(type: _type);
      await _synchroniserStatutsVilleCourante();
      await _chargerFavorisVilleCourante();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Recherche simple par nom
  Future<void> chercherVille(String nomVille) async {
    final query = nomVille.trim();

    if (query.isEmpty) {
      _setError('Saisis une ville');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final villeTrouvee = await ApiVillesEtLieux.fetchVilleDepuisNominatim(
        query,
      );
      final meteo = await ApiMeteo.fetchParVille(query);

      _ville = villeTrouvee;
      _weather = meteo;

      await _chargerLieux(type: _type);
      await _synchroniserStatutsVilleCourante();
      await _chargerFavorisVilleCourante();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Accès direct à un lieu favori par id
  Future<Lieu?> getLieuById(int id) async {
    return _lieuRepo.getLieuById(id);
  }

  // Changer le type courant et recharger les POI
  Future<void> changerType(LieuType type) async {
    _type = type;
    notifyListeners();
    await _chargerLieux(type: type);
  }

  // Favori ville courante
  Future<void> basculerFavoriActuel() async {
    if (_weather == null) return;

    final nom = _weather!.cityName;
    final existing = await _trouverVilleParNom(nom);

    if (existing == null) {
      final nouvelle = Ville(
        nom: nom,
        latitude: _weather!.coordonnees.latitude,
        longitude: _weather!.coordonnees.longitude,
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

    await _synchroniserStatutsVilleCourante();
  }

  Future<void> basculerVisiteeActuelle() async {
    if (_weather == null) return;

    final existing = await _trouverVilleParNom(_weather!.cityName);

    if (existing == null) {
      final v = await _getOrInsertVilleCourante();
      if (v == null) return;

      await _villeRepo.updateVille(v.copyWith(isVisitee: true));
      _isVisiteeActuelle = true;
      await _chargerFavorisVilleCourante();
      notifyListeners();
      return;
    }

    final updated = existing.copyWith(isVisitee: !existing.isVisitee);
    await _villeRepo.updateVille(updated);
    _isVisiteeActuelle = updated.isVisitee;
    notifyListeners();
  }

  Future<void> basculerExploreeActuelle() async {
    if (_weather == null) return;

    final existing = await _trouverVilleParNom(_weather!.cityName);

    if (existing == null) {
      final v = await _getOrInsertVilleCourante();
      if (v == null) return;

      await _villeRepo.updateVille(v.copyWith(isExploree: true));
      _isExploreeActuelle = true;
      await _chargerFavorisVilleCourante();
      notifyListeners();
      return;
    }

    final updated = existing.copyWith(isExploree: !existing.isExploree);
    await _villeRepo.updateVille(updated);
    _isExploreeActuelle = updated.isExploree;
    notifyListeners();
  }

  // Lieux favoris
  Future<void> ajouterLieuFavori(LieuApiResult poi) async {
    if (_weather == null) return;

    final villeCourante = await _getOrInsertVilleCourante();
    if (villeCourante?.id == null) return;

    final deja = await _lieuRepo.getLieuByNomEtVille(
      poi.name,
      villeCourante!.id!,
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

    final exists = _lieux.any(
      (l) => l.name == poi.name && l.lat == poi.lat && l.lon == poi.lon,
    );

    if (!exists) {
      _lieux = [..._lieux, poi];
      notifyListeners();
    }
  }

  Future<void> mettreAJourLieu(Lieu lieu) async {
    if (lieu.id == null) return;

    await _lieuRepo.updateLieu(lieu);

    _lieuxFavoris = _lieuxFavoris
        .map((l) => l.id == lieu.id ? lieu : l)
        .toList(growable: false);

    notifyListeners();
  }

  Future<void> supprimerLieuFavori(int id) async {
    await _lieuRepo.deleteLieu(id);
    _lieuxFavoris = _lieuxFavoris.where((l) => l.id != id).toList();
    notifyListeners();
  }

  // Charger les POI
  // On a besoin d une ville avec une bbox
  Future<void> _chargerLieux({required LieuType type}) async {
    final bbox = _ville?.bbox;
    if (bbox == null) return;

    _lieux = <LieuApiResult>[];
    _setLoadingLieux(true);

    try {
      _lieux = await ApiVillesEtLieux.fetchLieuxPourVille(
        type: type,
        limit: 15,
        bboxOverride: bbox,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingLieux(false);
    }
  }

  // Recherche de lieux par nom dans la ville courante
  Future<List<LieuApiResult>> chercherLieuxParNom(
    String nomLieu, {
    int limit = 10,
    LieuType? type,
  }) async {
    final bbox = _ville?.bbox;
    if (bbox == null) return <LieuApiResult>[];

    return ApiVillesEtLieux.fetchLieuxParNomDansVille(
      nomLieu: nomLieu,
      type: type ?? _type,
      bboxOverride: bbox,
      limit: limit,
    );
  }

  // Ajout d un lieu personnalisé
  // On vérifie que le point est dans la bbox pour éviter les incohérences
  // On insère ensuite en base puis on recharge les favoris
  Future<String?> ajouterLieuPersonnalise({
    required double lat,
    required double lon,
    required String nom,
    required LieuType type,
    String? description,
  }) async {
    final bbox = _ville?.bbox;
    if (_weather == null || bbox == null) {
      return 'Aucune ville courante ou bbox indisponible';
    }

    final dansBBox =
        lat >= bbox.latMin &&
        lat <= bbox.latMax &&
        lon >= bbox.lonMin &&
        lon <= bbox.lonMax;

    if (!dansBBox) {
      return 'Le point sélectionné est hors de la zone de la ville';
    }

    final villeCourante = await _getOrInsertVilleCourante();
    if (villeCourante?.id == null) {
      return 'Impossible de récupérer la ville courante';
    }

    final lieu = Lieu(
      villeId: villeCourante!.id!,
      nom: nom.isEmpty ? '(Sans nom)' : nom,
      type: type,
      latitude: lat,
      longitude: lon,
      description: description ?? '',
    );

    await _lieuRepo.insertLieu(lieu);
    await _chargerLieuxFavorisPourVille(villeCourante);

    notifyListeners();
    return null;
  }
}
