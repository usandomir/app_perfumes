import 'package:app_perfumes/core/models/user.dart';
import 'package:app_perfumes/core/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(authRepositoryProvider));
});

class UserRepository {
  final AuthRepository _authRepository;

  UserRepository(this._authRepository);

  Future<User?> obtenerUsuarioPorNombre(String name) {
    return _authRepository.obtenerPerfilPorNombre(name);
  }

  Future<User?> autenticarUsuario(String email, String password) async {
    return _authRepository.ingresarConEmail(email: email, password: password);
  }

  Future<User> autenticarConGoogle() {
    return _authRepository.ingresarConGoogle();
  }

  Future<void> cerrarSesion() {
    return _authRepository.cerrarSesion();
  }

  Future<void> registrarUsuario(User usuario, String password) async {
    await _authRepository.registrarConEmail(
      nombre: usuario.name,
      email: usuario.email,
      password: password,
      edad: usuario.age,
    );
  }

  Future<void> actualizarUsuario(User usuario) {
    return _authRepository.guardarPerfil(usuario);
  }

  Future<void> eliminarUsuario(String id) {
    return _authRepository.eliminarPerfilActual();
  }
}
