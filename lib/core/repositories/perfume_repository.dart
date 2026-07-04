import 'package:app_perfumes/core/models/perfume.dart';
import 'package:app_perfumes/core/repositories/auth_repository.dart';
import 'package:app_perfumes/core/repositories/storage_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final perfumeRepositoryProvider = Provider<PerfumeRepository>((ref) {
  return PerfumeRepository(
    FirebaseFirestore.instance,
    ref.read(authRepositoryProvider),
    ref.read(storageRepositoryProvider),
  );
});

class PerfumeRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final StorageRepository _storageRepository;

  PerfumeRepository(
    this._firestore,
    this._authRepository,
    this._storageRepository,
  );

  CollectionReference<Map<String, dynamic>> get _catalogo =>
      _firestore.collection('catalogo_perfumes');

  CollectionReference<Map<String, dynamic>> _miColeccion(String uid) =>
      _firestore.collection('users').doc(uid).collection('mis_perfumes');

  Future<List<Perfume>> obtenerPerfumesPorUsuario(String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    if (uid == null) return [];

    final propios = await _miColeccion(uid).orderBy('agregado_en').get();
    if (propios.docs.isEmpty) return [];

    final perfumes = <Perfume>[];
    for (final propio in propios.docs) {
      final catalogoId = propio.id;
      final doc = await _catalogo.doc(catalogoId).get();
      if (!doc.exists || doc.data() == null) continue;
      perfumes.add(Perfume.fromMap({'id': doc.id, ...doc.data()!}));
    }

    perfumes.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );
    return perfumes;
  }

  Future<String> registrarPerfume(Perfume perfume, String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    if (uid == null) throw Exception('No hay usuario logueado.');

    final catalogoId = await _obtenerOCrearPerfumeGlobal(
      perfume,
      uid,
      nombreUsuario,
    );
    await _agregarAMiColeccion(uid, catalogoId);
    return catalogoId;
  }

  Future<void> actualizarPerfume(Perfume perfume, String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    final id = perfume.id;
    if (uid == null || id == null) return;

    final doc = await _catalogo.doc(id).get();
    if (!doc.exists) return;
    if (doc.data()?['creado_por'] != uid) {
      throw Exception(
        'Solo quien cargo el perfume global puede editar sus datos.',
      );
    }

    final fotoUrl = await _storageRepository.subirImagen(
      pathLocal: perfume.fotoPath,
      carpeta: 'perfumes_globales',
      nombreArchivo: id,
    );

    await _catalogo.doc(id).update({
      ...perfume.toMap(),
      'foto_path': fotoUrl,
      'clave_catalogo': _claveCatalogo(perfume),
      'nombre_lower': perfume.nombre.toLowerCase(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarPerfume(String id, String nombreUsuario) async {
    final uid = _authRepository.usuarioActual?.uid;
    if (uid == null) return;

    await _miColeccion(uid).doc(id).delete();
  }

  Future<String> _obtenerOCrearPerfumeGlobal(
    Perfume perfume,
    String uid,
    String nombreUsuario,
  ) async {
    final clave = _claveCatalogo(perfume);
    final existente = await _catalogo
        .where('clave_catalogo', isEqualTo: clave)
        .limit(1)
        .get();

    if (existente.docs.isNotEmpty) {
      return existente.docs.first.id;
    }

    final doc = _catalogo.doc();
    final fotoUrl = await _storageRepository.subirImagen(
      pathLocal: perfume.fotoPath,
      carpeta: 'perfumes_globales',
      nombreArchivo: doc.id,
    );

    await doc.set({
      ...perfume.toMap(),
      'foto_path': fotoUrl,
      'creado_por': uid,
      'creado_por_nombre': nombreUsuario,
      'clave_catalogo': clave,
      'nombre_lower': perfume.nombre.toLowerCase(),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> _agregarAMiColeccion(String uid, String catalogoId) async {
    await _miColeccion(uid).doc(catalogoId).set({
      'catalogo_perfume_id': catalogoId,
      'agregado_en': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _claveCatalogo(Perfume perfume) {
    final nombre = _normalizar(perfume.nombre);
    final disenador = _normalizar(perfume.disenador);
    return '$nombre|$disenador';
  }

  String _normalizar(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
