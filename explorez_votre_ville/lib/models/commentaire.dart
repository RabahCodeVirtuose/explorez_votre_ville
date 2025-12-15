//
// Cette classe représente un commentaire dans l application
// Elle correspond à la table commentaire dans SQLite
// Un commentaire appartient à un lieu grâce à lieuId

class Commentaire {
  // id est null tant que le commentaire n est pas enregistré en base
  final int? id;

  // Chaque commentaire est lié à un lieu
  final int lieuId;

  // Le contenu peut être null si on autorise une note sans texte
  final String? contenu;

  // note est obligatoire dans la table donc on la garde required
  final int note;

  // createdAt sert à trier les commentaires et afficher la date
  final DateTime createdAt;

  Commentaire({
    this.id,
    required this.lieuId,
    this.contenu,
    required this.note,
    required this.createdAt,
  });

  // copyWith sert à créer une copie avec quelques champs modifiés
  // On l utilise souvent quand on veut changer un champ sans recréer tout l objet
  Commentaire copyWith({
    int? id,
    int? lieuId,
    String? contenu,
    int? note,
    DateTime? createdAt,
  }) {
    return Commentaire(
      id: id ?? this.id,
      lieuId: lieuId ?? this.lieuId,
      contenu: contenu ?? this.contenu,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // On transforme une ligne SQLite en objet Commentaire
  // created_at est stocké en texte donc on le convertit en DateTime
  factory Commentaire.fromMap(Map<String, dynamic> map) {
    return Commentaire(
      id: map['id'] as int?,
      lieuId: map['lieu_id'] as int,
      contenu: map['contenu'] as String?,
      note: map['note'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // On transforme l objet Commentaire en Map pour l insertion ou la mise à jour
  // On stocke la date en string ISO car c est simple et standard
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lieu_id': lieuId,
      'contenu': contenu,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
