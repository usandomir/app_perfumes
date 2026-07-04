class Perfume {
  String? id;
  String nombre;
  String disenador;
  int duracionHoras;
  String climaRecomendado;
  String descripcion;
  String? fotoPath;
  double precioUsd;
  String? creadoPor;

  Perfume({
    this.id,
    required this.nombre,
    required this.disenador,
    required this.duracionHoras,
    required this.climaRecomendado,
    required this.descripcion,
    this.fotoPath,
    required this.precioUsd,
    this.creadoPor,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'disenador': disenador,
      'duracion_horas': duracionHoras,
      'clima_recomendado': climaRecomendado,
      'descripcion': descripcion,
      'foto_path': fotoPath,
      'precio_usd': precioUsd,
      'creado_por': creadoPor,
    };
  }

  factory Perfume.fromMap(Map<String, dynamic> map) {
    return Perfume(
      id: map['id']?.toString(),
      nombre: map['nombre'] ?? '',
      disenador: map['disenador'] ?? '',
      duracionHoras: map['duracion_horas'] as int? ?? 0,
      climaRecomendado: map['clima_recomendado'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fotoPath: map['foto_path']?.toString(),
      precioUsd: (map['precio_usd'] as num?)?.toDouble() ?? 0.0,
      creadoPor: map['creado_por']?.toString(),
    );
  }
}
