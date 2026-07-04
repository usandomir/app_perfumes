import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(FirebaseStorage.instance);
});

class StorageRepository {
  final FirebaseStorage _storage;

  StorageRepository(this._storage);

  Future<String?> subirImagen({
    required String? pathLocal,
    required String carpeta,
    required String nombreArchivo,
  }) async {
    if (pathLocal == null ||
        pathLocal.isEmpty ||
        pathLocal.startsWith('http')) {
      return pathLocal;
    }

    final archivo = File(pathLocal);
    if (!archivo.existsSync()) return pathLocal;

    final ref = _storage.ref().child('$carpeta/$nombreArchivo.jpg');
    await ref.putFile(archivo);
    return ref.getDownloadURL();
  }
}
