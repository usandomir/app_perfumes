import 'package:app_perfumes/core/models/opinion.dart';
import 'package:app_perfumes/core/repositories/opinion_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final opinionViewModelProvider = Provider<OpinionViewModel>((ref) {
  return OpinionViewModel(ref.read(opinionRepositoryProvider));
});

final opinionesProvider = FutureProvider.autoDispose
    .family<List<Opinion>, String>((ref, perfumeId) async {
      return ref.read(opinionViewModelProvider).obtenerOpiniones(perfumeId);
    });

class OpinionViewModel {
  final OpinionRepository _repository;

  OpinionViewModel(this._repository);

  Future<List<Opinion>> obtenerOpiniones(String perfumeId) {
    return _repository.obtenerOpinionesPorPerfume(perfumeId);
  }

  Future<void> agregarOpinion(Opinion opinion) {
    return _repository.registrarOpinion(opinion);
  }

  Future<void> eliminarOpinion(String id) {
    return _repository.eliminarOpinion(id);
  }
}
