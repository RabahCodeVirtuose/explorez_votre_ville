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
  /// - Ville + météo courantes (APIs)
  /// - Lieux (POI) par type (APIs)
  /// - Favoris (villes + lieux) en base SQLite (+ statuts visitée/explorée)
  /// - Ville épinglée dans SharedPreferences

/*
  - (A) État de base : ville/météo, erreurs, chargement
  - (B) Lieux/POI : liste, type courant, chargement
  - (C) Favoris + statuts : ville favorite, visitée, explorée, lieux favoris
  - (D) Pinned : ville épinglée en SharedPreferences
  - (E) Repositories DB
  - (F) Getters
  - (G) Reset global
  - (H) Outils DB ville
  - (I) Pinned helpers
  - (J) Favoris villes (CRUD + synchronisation)
  - (K) Sélection de ville via liste Nominatim
  - (L) Recherche ville simple
  - (M) Lieux favoris (CRUD)
  - (N) Chargement des POI (via bbox) + recherche de lieux par nom (bbox)



 */


  class VilleProvider with ChangeNotifier {
    // (A) État de base --------------------------------------------------------
    final LatLng _defaultCenter = const LatLng(48.8566, 2.3522);
    WeatherData? _weather;
    VilleApiResult? _ville; // contient notamment bbox pour les POI

    bool _loading = false;
    String? _error;

    // (B) Lieux / POI ---------------------------------------------------------
    List<LieuApiResult> _lieux = <LieuApiResult>[];
    LieuType _type = LieuType.parc;
    bool _loadingLieux = false;

    // (C) Favoris + statuts ---------------------------------------------------
    bool _isFavoriActuel = false;
    bool _isVisiteeActuelle = false;
    bool _isExploreeActuelle = false;
    List<Lieu> _lieuxFavoris = <Lieu>[];

    // (D) Ville épinglée (SharedPrefs) ----------------------------------------
    int? _pinnedVilleId;

    // (E) Accès base locale ---------------------------------------------------
    final VilleRepository _villeRepo = VilleRepository();
    final LieuRepository _lieuRepo = LieuRepository();

    // (F) Getters exposés -----------------------------------------------------
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

    /// Centre à afficher sur la carte (prend météo > ville > défaut)
    LatLng get mapCenter {
      if (_weather != null) return _weather!.coordonnees;
      if (_ville != null) return LatLng(_ville!.lat, _ville!.lon);
      return _defaultCenter;
    }

    // (G) Reset complet -------------------------------------------------------
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

    // (H) Outils DB ville -----------------------------------------------------
    Future<Ville?> _trouverVilleParNom(String nom) async {
      final list = await _villeRepo.searchVillesByName(nom);
      for (final v in list) {
        if (v.nom.toLowerCase() == nom.toLowerCase()) return v;
      }
      return null;
    }

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

    Future<Ville?> _getOrInsertVilleCourante() async {
      if (_weather == null) return null;
      final existing = await _trouverVilleParNom(_weather!.cityName);
      if (existing != null) return existing;

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

    Future<void> _chargerLieuxFavorisPourVille(Ville ville) async {
      _lieuxFavoris = await _lieuRepo.getLieuxByVilleId(ville.id!);
      notifyListeners();
    }

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

    // (I) Pinned city (SharedPrefs) -------------------------------------------
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

    // (J) Gestion favoris villes ---------------------------------------------
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

    Future<List<Ville>> chargerFavoris() async => _villeRepo.getVillesFavorites();

    Future<void> supprimerVille(int id) async {
      Ville? current;
      if (_weather != null) current = await _trouverVilleParNom(_weather!.cityName);

      await _villeRepo.deleteVille(id);
      if (_pinnedVilleId == id) _pinnedVilleId = null;
      if (current?.id == id) reset();
      notifyListeners();
    }

    // (K) Sélection multiple de villes (Nominatim) ----------------------------
    Future<List<VilleApiResult>> proposerVilles(String nomVille) async {
      return ApiVillesEtLieux.fetchVillesDepuisNominatimList(nomVille);
    }

    Future<void> appliquerVilleSelectionnee(VilleApiResult ville) async {
      _ville = ville; // conserve bbox
      _loading = true;
      _error = null;
      notifyListeners();
      try {
        final meteo = await ApiMeteo.fetchParCoordonnees(
          latitude: ville.lat,
          longitude: ville.lon,
        );
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

    // (L) Recherche ville + météo (simple) -----------------------------------
    Future<void> chercherVille(String nomVille) async {
      final query = nomVille.trim();
      if (query.isEmpty) {
        _error = 'Saisis une ville';
        notifyListeners();
        return;
      }

      _loading = true;
      _error = null;
      notifyListeners();

      try {
        final villeTrouvee = await ApiVillesEtLieux.fetchVilleDepuisNominatim(query);
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

    // (M) Lieux favoris : CRUD ------------------------------------------------
    Future<Lieu?> getLieuById(int id) async => _lieuRepo.getLieuById(id);

    Future<void> changerType(LieuType type) async {
      _type = type;
      await _chargerLieux(type: type);
    }

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

    Future<void> basculerVisiteeActuelle() async {
      if (_weather == null) return;
      final existing = await _trouverVilleParNom(_weather!.cityName);
      if (existing == null) {
        final v = await _getOrInsertVilleCourante();
        if (v != null) {
          await _villeRepo.updateVille(v.copyWith(isVisitee: true));
          _isVisiteeActuelle = true;
          await _chargerFavorisVilleCourante();
        }
      } else {
        final updated = existing.copyWith(isVisitee: !existing.isVisitee);
        await _villeRepo.updateVille(updated);
        _isVisiteeActuelle = updated.isVisitee;
      }
      notifyListeners();
    }

    Future<void> basculerExploreeActuelle() async {
      if (_weather == null) return;
      final existing = await _trouverVilleParNom(_weather!.cityName);
      if (existing == null) {
        final v = await _getOrInsertVilleCourante();
        if (v != null) {
          await _villeRepo.updateVille(v.copyWith(isExploree: true));
          _isExploreeActuelle = true;
          await _chargerFavorisVilleCourante();
        }
      } else {
        final updated = existing.copyWith(isExploree: !existing.isExploree);
        await _villeRepo.updateVille(updated);
        _isExploreeActuelle = updated.isExploree;
      }
      notifyListeners();
    }

    Future<void> ajouterLieuFavori(LieuApiResult poi) async {
      if (_weather == null) return;
      final villeCourante = await _getOrInsertVilleCourante();
      if (villeCourante == null || villeCourante.id == null) return;

      final deja = await _lieuRepo.getLieuByNomEtVille(poi.name, villeCourante.id!);
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

      final exists = _lieux.any((l) => l.name == poi.name && l.lat == poi.lat && l.lon == poi.lon);
      if (!exists) {
        _lieux = [..._lieux, poi];
        notifyListeners();
      }
    }

    Future<void> mettreAJourLieu(Lieu lieu) async {
      if (lieu.id == null) return;
      await _lieuRepo.updateLieu(lieu);
      _lieuxFavoris = _lieuxFavoris.map((l) => l.id == lieu.id ? lieu : l).toList(growable: false);
      notifyListeners();
    }

    Future<void> supprimerLieuFavori(int id) async {
      await _lieuRepo.deleteLieu(id);
      _lieuxFavoris = _lieuxFavoris.where((l) => l.id != id).toList();
      notifyListeners();
    }

    // (N) Chargement des POI (bbox obligatoire) -------------------------------
    Future<void> _chargerLieux({required LieuType type}) async {
      _lieux = <LieuApiResult>[];
      _loadingLieux = true;
      notifyListeners();
      try {
        final data = await ApiVillesEtLieux.fetchLieuxPourVille(
          type: type,
          limit: 15,
          bboxOverride: _ville?.bbox,
        );
        _lieux = data;
      } catch (e) {
        _error = e.toString();
      } finally {
        _loadingLieux = false;
        notifyListeners();
      }
    }

    /// Recherche des lieux par nom dans la ville sélectionnée (via bbox).
    Future<List<LieuApiResult>> chercherLieuxParNom(
      String nomLieu, {
      int limit = 10,
      LieuType? type,
    }) async {
      return ApiVillesEtLieux.fetchLieuxParNomDansVille(
        nomLieu: nomLieu,
        type: type ?? _type,
        bboxOverride: _ville?.bbox,
        limit: limit,
      );
    }
  }