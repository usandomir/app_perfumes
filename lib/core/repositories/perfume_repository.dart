import 'package:app_perfumes/core/repositories/opinion_repository.dart';
import 'package:app_perfumes/core/models/perfume.dart';
import 'package:app_perfumes/core/repositories/perfumes_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final perfumeRepositoryProvider = Provider<PerfumeRepository>((ref) {
  return PerfumeRepository(
    ref.read(perfumesDatabaseProvider),
    ref.read(opinionRepositoryProvider),
  );
});

class PerfumeRepository {
  final PerfumesDatabase _database;
  final OpinionRepository _opinionRepository;

  PerfumeRepository(this._database, this._opinionRepository);

  Future<List<Perfume>> obtenerPerfumesPorUsuario(String nombreUsuario) async {
    final db = await _database.database;
    final resultado = await db.query(
      'perfumes',
      where: 'LOWER(usuario_dueno) = ?',
      whereArgs: [nombreUsuario.toLowerCase()],
      orderBy: 'nombre COLLATE NOCASE ASC',
    );
    return resultado.map((map) => Perfume.fromMap(map)).toList();
  }

  Future<int> registrarPerfume(Perfume perfume, String nombreUsuario) async {
    final db = await _database.database;
    final map = perfume.toMap();
    map['usuario_dueno'] = nombreUsuario.toLowerCase();
    return db.insert(
      'perfumes',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> actualizarPerfume(Perfume perfume, String nombreUsuario) async {
    final db = await _database.database;
    await db.update(
      'perfumes',
      perfume.toMap(),
      where: 'id = ? AND LOWER(usuario_dueno) = ?',
      whereArgs: [perfume.id, nombreUsuario.toLowerCase()],
    );
  }

  Future<void> eliminarPerfume(int id, String nombreUsuario) async {
    final db = await _database.database;
    await _opinionRepository.eliminarOpinionesDePerfume(id);
    await db.delete(
      'perfumes',
      where: 'id = ? AND LOWER(usuario_dueno) = ?',
      whereArgs: [id, nombreUsuario.toLowerCase()],
    );
  }
}
