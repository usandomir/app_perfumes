class Opinion {
  String? id;
  String perfumeId;
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
      'perfume_id': perfumeId,
      'usuario': usuario,
      'comentario': comentario,
      'puntuacion': puntuacion,
      'fecha_iso': fechaIso,
    };
  }

  factory Opinion.fromMap(Map<String, dynamic> map) {
    return Opinion(
      id: map['id']?.toString(),
      perfumeId: map['perfume_id']?.toString() ?? '',
      usuario: map['usuario'] ?? '',
      comentario: map['comentario'] ?? '',
      puntuacion: map['puntuacion'] as int? ?? 0,
      fechaIso: map['fecha_iso'] ?? '',
    );
  }
}
