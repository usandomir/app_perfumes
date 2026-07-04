import 'package:app_perfumes/core/models/perfume.dart';
import 'package:app_perfumes/core/repositories/perfume_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final perfumeViewModelProvider = Provider<PerfumeViewModel>((ref) {
  return PerfumeViewModel(ref.read(perfumeRepositoryProvider));
});

final perfumesProvider = FutureProvider.autoDispose
    .family<List<Perfume>, String>((ref, nombre) async {
      return ref.read(perfumeViewModelProvider).obtenerPerfumes(nombre);
    });

class PerfumeViewModel {
  final PerfumeRepository _repository;

  PerfumeViewModel(this._repository);

  Future<List<Perfume>> obtenerPerfumes(String nombreUsuario) {
    return _repository.obtenerPerfumesPorUsuario(nombreUsuario);
  }

  Future<int> guardarPerfume({
    required Perfume perfume,
    required String nombreUsuario,
    required bool esEdicion,
  }) {
    if (esEdicion) {
      return _repository
          .actualizarPerfume(perfume, nombreUsuario)
          .then((_) => perfume.id ?? 0);
    }
    return _repository.registrarPerfume(perfume, nombreUsuario);
  }

  Future<void> eliminarPerfume(int id, String nombreUsuario) {
    return _repository.eliminarPerfume(id, nombreUsuario);
  }
}
