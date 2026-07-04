import 'package:app_perfumes/models/opinion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final perfumesDatabaseProvider = Provider<PerfumesDatabase>((ref) {
  return PerfumesDatabase();
});

class PerfumesDatabase {
  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _inicializarDB();
    return _db!;
  }

  Future<Database> _inicializarDB() async {
    final pathDB = join(await getDatabasesPath(), 'perfumes_database.db');
    return openDatabase(
      pathDB,
      version: 7,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
        await crearTablaOpiniones(db);
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
          await crearTablaOpiniones(db);
          await migrarOpinionesEmbebidas(db);
        }
      },
    );
  }

  Future<void> crearTablaOpiniones(Database db) async {
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

  Future<void> migrarOpinionesEmbebidas(Database db) async {
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

      await db.insert(
        'opiniones',
        Opinion(
          perfumeId: id,
          usuario: perfume['usuario_dueno']?.toString() ?? 'marco',
          comentario: comentario,
          puntuacion: 5,
          fechaIso: DateTime.now().toIso8601String(),
        ).toMap(),
      );
    }
  }
}
