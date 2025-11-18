// lib/models/commentaire.dart

/// Modèle aligné avec la table `commentaire`
class Commentaire {
  final int? id;
  final int lieuId;
  final String? contenu;
  final int note;
  final DateTime createdAt;

  Commentaire({
    this.id,
    required this.lieuId,
    this.contenu,
    required this.note,
    required this.createdAt,
  });

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

  /// Conversion Map -> Commentaire (lecture SQLite)
  factory Commentaire.fromMap(Map<String, dynamic> map) {
    return Commentaire(
      id: map['id'] as int?,
      lieuId: map['lieu_id'] as int,
      contenu: map['contenu'] as String?,
      note: map['note'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Conversion Commentaire -> Map (écriture SQLite)
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
