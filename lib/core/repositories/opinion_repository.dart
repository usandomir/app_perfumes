import 'package:app_perfumes/core/models/opinion.dart';
import 'package:app_perfumes/core/repositories/perfumes_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final opinionRepositoryProvider = Provider<OpinionRepository>((ref) {
  return OpinionRepository(ref.read(perfumesDatabaseProvider));
});

class OpinionRepository {
  final PerfumesDatabase _database;

  OpinionRepository(this._database);

  Future<List<Opinion>> obtenerOpinionesPorPerfume(int perfumeId) async {
    final db = await _database.database;
    final resultado = await db.query(
      'opiniones',
      where: 'perfume_id = ?',
      whereArgs: [perfumeId],
      orderBy: 'fecha_iso DESC',
    );
    return resultado.map((map) => Opinion.fromMap(map)).toList();
  }

  Future<void> registrarOpinion(Opinion opinion) async {
    final db = await _database.database;
    await db.insert('opiniones', opinion.toMap());
  }

  Future<void> eliminarOpinion(int id) async {
    final db = await _database.database;
    await db.delete('opiniones', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarOpinionesDePerfume(int perfumeId) async {
    final db = await _database.database;
    await db.delete(
      'opiniones',
      where: 'perfume_id = ?',
      whereArgs: [perfumeId],
    );
  }
}
