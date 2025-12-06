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

/// Provider qui expose l'etat ville/meteo et les favoris (SQLite).
class VilleProvider with ChangeNotifier {
  final LatLng _defaultCenter = const LatLng(48.8566, 2.3522);

  WeatherData? _weather;
  VilleApiResult? _ville;
  bool _loading = false;
  String? _error;
  String? _lastQuery;

  List<LieuApiResult> _lieux = <LieuApiResult>[];
  LieuType _type = LieuType.parc;
  bool _loadingLieux = false;
  bool _isFavoriActuel = false;
  List<Lieu> _lieuxFavoris = <Lieu>[];
  int? _pinnedVilleId;

  final VilleRepository _villeRepo = VilleRepository();
  final LieuRepository _lieuRepo = LieuRepository();

  WeatherData? get weather => _weather;
  VilleApiResult? get ville => _ville;
  bool get loading => _loading;
  String? get error => _error;
  List<LieuApiResult> get lieux => _lieux;
  LieuType get type => _type;
  bool get loadingLieux => _loadingLieux;
  bool get isFavoriActuel => _isFavoriActuel;
  List<Lieu> get lieuxFavoris => _lieuxFavoris;
  int? get pinnedVilleId => _pinnedVilleId;

  LatLng get mapCenter {
    if (_weather != null) return _weather!.coordonnees;
    if (_ville != null) return LatLng(_ville!.lat, _ville!.lon);
    return _defaultCenter;
  }

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
    _lieuxFavoris = <Lieu>[];
    _pinnedVilleId = null;
    notifyListeners();
  }

  Future<Ville?> _trouverVilleParNom(String nom) async {
    final list = await _villeRepo.searchVillesByName(nom);
    for (final v in list) {
      if (v.nom.toLowerCase() == nom.toLowerCase()) {
        return v;
      }
    }
    return null;
  }

  Future<void> _synchroniserFavoriActuel() async {
    if (_weather == null) {
      _isFavoriActuel = false;
      return;
    }
    final existing = await _trouverVilleParNom(_weather!.cityName);
    _isFavoriActuel = existing?.isFavorie == true;
    notifyListeners();
  }

  Future<Ville?> _getOrInsertVilleCourante() async {
    if (_weather == null) return null;
    // Cherche en base
    final existing = await _trouverVilleParNom(_weather!.cityName);
    if (existing != null) return existing;

    // Insère si absente (en conservant le statut favori courant)
    final nouvelle = Ville(
      nom: _weather!.cityName,
      latitude: _weather?.coordonnees.latitude,
      longitude: _weather?.coordonnees.longitude,
      isFavorie: _isFavoriActuel,
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
    final ville = await _villeRepo.getVilleById(_pinnedVilleId!);
    if (ville != null) {
      await chercherVille(ville.nom);
    }
  }

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

  Future<void> ajouterLieuFavori(LieuApiResult poi) async {
    if (_weather == null) return;

    // S'assure que la ville courante est présente en base
    final villeCourante = await _getOrInsertVilleCourante();
    if (villeCourante == null || villeCourante.id == null) return;

    // Evite les doublons (nom + ville)
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

  Future<void> _chargerLieux({required LieuType type}) async {
    if (_lastQuery == null || _lastQuery!.isEmpty) {
      _lieux = <LieuApiResult>[];
      notifyListeners();
      return;
    }

    // Vider la liste actuelle pour éviter d'afficher les anciens marqueurs
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
