import 'package:app_perfumes/core/models/opinion.dart';
import 'package:app_perfumes/core/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final opinionRepositoryProvider = Provider<OpinionRepository>((ref) {
  return OpinionRepository(
    FirebaseFirestore.instance,
    ref.read(authRepositoryProvider),
  );
});

class OpinionRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  OpinionRepository(this._firestore, this._authRepository);

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      _firestore.collection('opiniones');

  Future<List<Opinion>> obtenerOpinionesPorPerfume(String perfumeId) async {
    final resultado = await _coleccion
        .where('perfume_id', isEqualTo: perfumeId)
        .orderBy('fecha_iso', descending: true)
        .get();

    return resultado.docs.map((doc) {
      return Opinion.fromMap({'id': doc.id, ...doc.data()});
    }).toList();
  }

  Future<void> registrarOpinion(Opinion opinion) async {
    final uid = _authRepository.usuarioActual?.uid;
    await _coleccion.add({
      ...opinion.toMap(),
      'user_id': uid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarOpinion(String id) async {
    await _coleccion.doc(id).delete();
  }

  Future<void> eliminarOpinionesDePerfume(String perfumeId) async {
    final resultado = await _coleccion
        .where('perfume_id', isEqualTo: perfumeId)
        .get();
    final batch = _firestore.batch();
    for (final doc in resultado.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
