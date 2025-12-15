import 'package:explorez_votre_ville/api/api_villes.dart';
import 'package:explorez_votre_ville/models/lieu_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Ce widget représente une couche de markers sur la carte
// On reçoit une liste de POI et on transforme chaque POI en Marker FlutterMap
// Quand on tape sur un marker on renvoie le POI au parent grâce au callback onTap
class PoiMarkerLayer extends StatelessWidget {
  // Liste des lieux à afficher sur la carte
  final List<LieuApiResult> pois;

  // Fonction appelée quand on tape sur un marker
  // Le parent décide quoi faire après (ouvrir une bottom sheet afficher un détail etc)
  final void Function(LieuApiResult) onTap;

  // Type courant sélectionné dans l appli
  // On s en sert pour choisir l icône et la couleur de cette série de markers
  final LieuType type;

  const PoiMarkerLayer({
    super.key,
    required this.pois,
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Taille visuelle de chaque marker sur la carte
    // On met une largeur assez grande car on affiche aussi un texte
    const double markerHeight = 40;
    const double markerWidth = 150;

    // On récupère l icône et la couleur en fonction du type sélectionné
    // Ça permet de garder la même logique partout dans l appli
    final iconData = LieuTypeHelper.icon(type);
    final iconColor = LieuTypeHelper.color(type);

    // MarkerLayer est le widget fourni par flutter_map pour afficher une liste de Marker
    return MarkerLayer(
      markers: pois
          .map(
            (p) => Marker(
              // On convertit les coordonnées du POI en LatLng
              point: LatLng(p.lat, p.lon),

              // On fixe une zone de rendu pour que le marker ait une taille stable
              width: markerWidth,
              height: markerHeight,

              // child est le contenu réel dessiné sur la carte
              // Ici on veut pouvoir détecter le tap
              child: GestureDetector(
                // Quand on tape on renvoie le POI au parent
                onTap: () => onTap(p),

                // On affiche une petite ligne avec l icône et le nom
                child: Row(
                  // mainAxisSize min évite de prendre toute la largeur disponible
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône du marker selon le type
                    Icon(iconData, color: iconColor, size: 26),

                    // Petit espace entre l icône et le texte
                    const SizedBox(width: 4),

                    // Flexible permet au texte de se couper proprement dans la largeur du marker
                    Flexible(
                      child: Text(
                        // Nom du POI retourné par l API
                        // Si c est vide on affiche quand même quelque chose pour éviter un rendu bizarre
                        p.name.isEmpty ? '(Sans nom)' : p.name,

                        // Style simple et lisible
                        // backgroundColor aide à lire sur la carte
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          backgroundColor: Colors.white70,
                        ),

                        // Si c est trop long on coupe avec ...
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
