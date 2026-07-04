import 'package:app_perfumes/core/models/user.dart';
import 'package:app_perfumes/core/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userViewModelProvider = Provider<UserViewModel>((ref) {
  return UserViewModel(ref.read(userRepositoryProvider));
});

class UserViewModel {
  final UserRepository _repository;

  UserViewModel(this._repository);

  Future<User?> obtenerPorNombre(String name) {
    return _repository.obtenerUsuarioPorNombre(name);
  }

  Future<User?> autenticar(String name, String password) {
    return _repository.autenticarUsuario(name, password);
  }

  Future<void> registrar(User usuario) {
    return _repository.registrarUsuario(usuario);
  }

  Future<void> actualizar(User usuario) {
    return _repository.actualizarUsuario(usuario);
  }

  Future<void> eliminar(String id) {
    return _repository.eliminarUsuario(id);
  }
}
