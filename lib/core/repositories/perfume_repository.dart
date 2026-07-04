import 'package:app_perfumes/core/models/perfume.dart';
import 'package:app_perfumes/core/repositories/auth_repository.dart';
import 'package:app_perfumes/core/repositories/opinion_repository.dart';
import 'package:app_perfumes/core/repositories/storage_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final perfumeRepositoryProvider = Provider<PerfumeRepository>((ref) {
  return PerfumeRepository(
    FirebaseFirestore.instance,
    ref.read(authRepositoryProvider),
    ref.read(opinionRepositoryProvider),
    ref.read(storageRepositoryProvider),
  );
});

class PerfumeRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final OpinionRepository _opinionRepository;
  final StorageRepository _storageRepository;

  PerfumeRepository(
    this._firestore,
    this._authRepository,
    this._opinionRepository,
    this._storageRepository,
  );

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      _firestore.collection('perfumes');

  Future<List<Perfume>> obtenerPerfumesPorUsuario(String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    if (uid == null) return [];

    final resultado = await _coleccion
        .where('owner_id', isEqualTo: uid)
        .orderBy('nombre_lower')
        .get();

    return resultado.docs.map((doc) {
      return Perfume.fromMap({'id': doc.id, ...doc.data()});
    }).toList();
  }

  Future<String> registrarPerfume(Perfume perfume, String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    if (uid == null) throw Exception('No hay usuario logueado.');

    final doc = _coleccion.doc();
    final fotoUrl = await _storageRepository.subirImagen(
      pathLocal: perfume.fotoPath,
      carpeta: 'perfumes/$uid',
      nombreArchivo: doc.id,
    );

    await doc.set({
      ...perfume.toMap(),
      'foto_path': fotoUrl,
      'owner_id': uid,
      'usuario_dueno': nombreUsuario,
      'nombre_lower': perfume.nombre.toLowerCase(),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> actualizarPerfume(Perfume perfume, String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    final id = perfume.id;
    if (uid == null || id == null) return;

    final fotoUrl = await _storageRepository.subirImagen(
      pathLocal: perfume.fotoPath,
      carpeta: 'perfumes/$uid',
      nombreArchivo: id,
    );

    await _coleccion.doc(id).update({
      ...perfume.toMap(),
      'foto_path': fotoUrl,
      'usuario_dueno': nombreUsuario,
      'nombre_lower': perfume.nombre.toLowerCase(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarPerfume(String id, String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    if (uid == null) return;

    final doc = await _coleccion.doc(id).get();
    if (!doc.exists || doc.data()?['owner_id'] != uid) return;

    await _opinionRepository.eliminarOpinionesDePerfume(id);
    await _coleccion.doc(id).delete();
  }
}
