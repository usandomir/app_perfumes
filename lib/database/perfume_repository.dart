import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:app_perfumes/database/opinion.dart';
import 'package:app_perfumes/database/perfumes.dart';
import 'package:sqflite/sqflite.dart';

final perfumeRepositoryProvider = Provider<PerfumeRepository>((ref) {
  return PerfumeRepository();
});

final perfumesProvider = FutureProvider.autoDispose
    .family<List<Perfume>, String>((ref, nombre) async {
      return ref
          .read(perfumeRepositoryProvider)
          .obtenerPerfumesPorUsuario(nombre);
    });

final opinionesProvider = FutureProvider.autoDispose.family<List<Opinion>, int>(
  (ref, perfumeId) async {
    return ref
        .read(perfumeRepositoryProvider)
        .obtenerOpinionesPorPerfume(perfumeId);
  },
);

class PerfumeRepository {
  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _inicializarDB();
    return _db!;
  }

  Future<Database> _inicializarDB() async {
    final pathDB = join(await getDatabasesPath(), 'perfumes_database.db');
    return await openDatabase(
      pathDB,
      version: 7,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE perfumes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            disenador TEXT,
            duracion_horas INTEGER,
            clima_recomendado TEXT,
            descripcion TEXT,
            foto_path TEXT,
            precio_usd REAL,
            usuario_dueno TEXT
          )
        ''');
        await _crearTablaOpiniones(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 6) {
          try {
            await db.execute('ALTER TABLE perfumes ADD COLUMN opiniones TEXT');
          } catch (_) {}
          try {
            await db.execute(
              'ALTER TABLE perfumes ADD COLUMN usuario_dueno TEXT DEFAULT "marco"',
            );
          } catch (_) {}
        }
        if (oldVersion < 7) {
          await _crearTablaOpiniones(db);
          await _migrarOpinionesEmbebidas(db);
        }
      },
    );
  }

  Future<void> _crearTablaOpiniones(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS opiniones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        perfume_id INTEGER NOT NULL,
        usuario TEXT NOT NULL,
        comentario TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        fecha_iso TEXT NOT NULL,
        FOREIGN KEY (perfume_id) REFERENCES perfumes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _migrarOpinionesEmbebidas(Database db) async {
    final columnas = await db.rawQuery('PRAGMA table_info(perfumes)');
    final tieneOpiniones = columnas.any(
      (columna) => columna['name'] == 'opiniones',
    );
    if (!tieneOpiniones) return;

    final perfumesConOpinion = await db.query(
      'perfumes',
      columns: ['id', 'usuario_dueno', 'opiniones'],
      where: 'opiniones IS NOT NULL AND TRIM(opiniones) != ?',
      whereArgs: [''],
    );

    for (final perfume in perfumesConOpinion) {
      final id = perfume['id'] as int?;
      final comentario = perfume['opiniones']?.toString().trim() ?? '';
      if (id == null || comentario.isEmpty) continue;

      final existente = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM opiniones WHERE perfume_id = ? AND comentario = ?',
          [id, comentario],
        ),
      );
      if ((existente ?? 0) > 0) continue;

      await db.insert('opiniones', {
        'perfume_id': id,
        'usuario': perfume['usuario_dueno']?.toString() ?? 'marco',
        'comentario': comentario,
        'puntuacion': 5,
        'fecha_iso': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<Perfume>> obtenerPerfumesPorUsuario(String nombreUsuario) async {
    final db = await database;
    final List<Map<String, dynamic>> resultado = await db.query(
      'perfumes',
      where: 'LOWER(usuario_dueno) = ?',
      whereArgs: [nombreUsuario.toLowerCase()],
      orderBy: 'nombre COLLATE NOCASE ASC',
    );
    return resultado.map((map) => Perfume.fromMap(map)).toList();
  }

  Future<int> registrarPerfume(Perfume perfume, String nombreUsuario) async {
    final db = await database;
    final map = perfume.toMap();
    map['usuario_dueno'] = nombreUsuario.toLowerCase();
    return db.insert(
      'perfumes',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> actualizarPerfume(Perfume perfume, String nombreUsuario) async {
    final db = await database;
    await db.update(
      'perfumes',
      perfume.toMap(),
      where: 'id = ? AND LOWER(usuario_dueno) = ?',
      whereArgs: [perfume.id, nombreUsuario.toLowerCase()],
    );
  }

  Future<void> eliminarPerfume(int id, String nombreUsuario) async {
    final db = await database;
    await db.delete('opiniones', where: 'perfume_id = ?', whereArgs: [id]);
    await db.delete(
      'perfumes',
      where: 'id = ? AND LOWER(usuario_dueno) = ?',
      whereArgs: [id, nombreUsuario.toLowerCase()],
    );
  }

  Future<List<Opinion>> obtenerOpinionesPorPerfume(int perfumeId) async {
    final db = await database;
    final resultado = await db.query(
      'opiniones',
      where: 'perfume_id = ?',
      whereArgs: [perfumeId],
      orderBy: 'fecha_iso DESC',
    );
    return resultado.map((map) => Opinion.fromMap(map)).toList();
  }

  Future<void> registrarOpinion(Opinion opinion) async {
    final db = await database;
    await db.insert('opiniones', opinion.toMap());
  }

  Future<void> eliminarOpinion(int id) async {
    final db = await database;
    await db.delete('opiniones', where: 'id = ?', whereArgs: [id]);
  }
}
