import 'package:flutter/material.dart';
import '../../models/lieu_type.dart';

/// Formulaire d’édition des champs du lieu (nom, type, description, lat/lon).
class LieuEditForm extends StatelessWidget {
  final TextEditingController nomCtrl;
  final TextEditingController descCtrl;
  final TextEditingController latCtrl;
  final TextEditingController lonCtrl;
  final LieuType typeSel;
  final ValueChanged<LieuType> onTypeChanged;

  const LieuEditForm({
    super.key,
    required this.nomCtrl,
    required this.descCtrl,
    required this.latCtrl,
    required this.lonCtrl,
    required this.typeSel,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nomCtrl,
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
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
                  child: Text(LieuTypeHelper.label(t)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onTypeChanged(v);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: descCtrl,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: latCtrl,
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
