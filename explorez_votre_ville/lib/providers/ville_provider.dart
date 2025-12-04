import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../api/api_meteo.dart';
import '../api/api_villes.dart';
import '../db/repository/ville_repository.dart';
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

  final VilleRepository _villeRepo = VilleRepository();

  WeatherData? get weather => _weather;
  VilleApiResult? get ville => _ville;
  bool get loading => _loading;
  String? get error => _error;
  List<LieuApiResult> get lieux => _lieux;
  LieuType get type => _type;
  bool get loadingLieux => _loadingLieux;
  bool get isFavoriActuel => _isFavoriActuel;

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

  Future<void> _chargerLieux({required LieuType type}) async {
    if (_lastQuery == null || _lastQuery!.isEmpty) {
      _lieux = <LieuApiResult>[];
      notifyListeners();
      return;
    }

    _loadingLieux = true;
    notifyListeners();
    try {
      final data = await ApiVillesEtLieux.fetchLieuxPourVille(
        nomVille: _lastQuery!,
        type: type,
        limit: 50,
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
