import 'package:flutter/material.dart';
import '../../models/lieu_type.dart';

// LieuEditForm
// Ici on construit un petit formulaire pour modifier un lieu
// On reçoit des controllers déjà créés dans l écran parent
// Comme ça on garde les valeurs saisies même si l écran rebuild
// On reçoit aussi le type sélectionné et un callback pour le changer
// readOnlyNameType permet de figer le nom et le type quand on veut empêcher la modif
class LieuEditForm extends StatelessWidget {
  // Controller du champ nom
  final TextEditingController nomCtrl;

  // Controller du champ description
  final TextEditingController descCtrl;

  // Controller du champ latitude (texte car on récupère depuis un TextField)
  final TextEditingController latCtrl;

  // Controller du champ longitude
  final TextEditingController lonCtrl;

  // Type actuellement sélectionné dans le dropdown
  final LieuType typeSel;

  // Callback appelé quand on change le type dans le dropdown
  final ValueChanged<LieuType> onTypeChanged;

  // Si true on empêche la modification du nom et du type
  final bool readOnlyNameType;

  const LieuEditForm({
    super.key,
    required this.nomCtrl,
    required this.descCtrl,
    required this.latCtrl,
    required this.lonCtrl,
    required this.typeSel,
    required this.onTypeChanged,
    this.readOnlyNameType = false,
  });

  @override
  Widget build(BuildContext context) {
    // On empile les champs verticalement
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ nom
        // enabled permet d activer ou désactiver le champ facilement
        TextField(
          controller: nomCtrl,
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
          enabled: !readOnlyNameType,
        ),

        const SizedBox(height: 10),

        // Dropdown pour choisir le type du lieu
        // items est construit à partir de toutes les valeurs de l enum
        DropdownButtonFormField<LieuType>(
          value: typeSel,
          decoration: const InputDecoration(
            labelText: 'Type',
            border: OutlineInputBorder(),
          ),
          items: LieuType.values
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  // On affiche un label lisible au lieu du nom technique de l enum
                  child: Text(LieuTypeHelper.label(t)),
                ),
              )
              .toList(),

          // Si readOnlyNameType est true on met onChanged à null
          // Flutter comprend alors que le champ est désactivé
          onChanged: readOnlyNameType
              ? null
              : (v) {
                  // On vérifie v car le dropdown peut envoyer null
                  if (v != null) onTypeChanged(v);
                },
        ),

        const SizedBox(height: 10),

        // Champ description
        // maxLines 2 pour garder une taille raisonnable
        TextField(
          controller: descCtrl,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),

        const SizedBox(height: 10),

        // Ligne avec 2 champs côte à côte pour lat et lon
        Row(
          children: [
            // Expanded pour que chaque champ prenne la moitié de la ligne
            Expanded(
              child: TextField(
                controller: latCtrl,
                // On met number pour afficher un clavier numérique
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: TextField(
                controller: lonCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
