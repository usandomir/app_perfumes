class Opinion {
  int? id;
  int perfumeId;
  String usuario;
  String comentario;
  int puntuacion;
  String fechaIso;

  Opinion({
    this.id,
    required this.perfumeId,
    required this.usuario,
    required this.comentario,
    required this.puntuacion,
    required this.fechaIso,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'perfume_id': perfumeId,
      'usuario': usuario,
      'comentario': comentario,
      'puntuacion': puntuacion,
      'fecha_iso': fechaIso,
    };
  }

  factory Opinion.fromMap(Map<String, dynamic> map) {
    return Opinion(
      id: map['id'] as int?,
      perfumeId: map['perfume_id'] as int? ?? 0,
      usuario: map['usuario'] ?? '',
      comentario: map['comentario'] ?? '',
      puntuacion: map['puntuacion'] as int? ?? 0,
      fechaIso: map['fecha_iso'] ?? '',
    );
  }
}
