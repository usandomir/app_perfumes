import 'package:app_perfumes/core/models/user.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _googleInicializado = false;

  AuthRepository(this._auth, this._firestore);

  User? get usuarioActual => _auth.currentUser;

  Stream<User?> get cambiosDeSesion => _auth.authStateChanges();

  Future<app.User> registrarConEmail({
    required String nombre,
    required String email,
    required String password,
    int? edad,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credencial.user!;
      await firebaseUser.updateDisplayName(nombre);

      final usuario = app.User(
        id: firebaseUser.uid,
        name: nombre,
        email: email,
        age: edad ?? 0,
        profileImage: firebaseUser.photoURL,
      );
      await guardarPerfil(usuario);
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeAuth(e));
    }
  }

  Future<app.User> ingresarConEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _usuarioDesdeFirebase(credencial.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeAuth(e));
    }
  }

  Future<app.User> ingresarConGoogle() async {
    try {
      await _inicializarGoogle();
      final cuentaGoogle = await GoogleSignIn.instance.authenticate();
      final authGoogle = cuentaGoogle.authentication;
      final credencial = GoogleAuthProvider.credential(
        idToken: authGoogle.idToken,
      );
      final resultado = await _auth.signInWithCredential(credencial);
      final usuario = _usuarioDesdeFirebase(resultado.user!);
      await guardarPerfil(usuario);
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeAuth(e));
    } on GoogleSignInException catch (e) {
      throw Exception(e.description ?? 'No se pudo iniciar sesion con Google');
    }
  }

  Future<void> cerrarSesion() async {
    await _inicializarGoogle();
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<app.User?> obtenerPerfilActual() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (!doc.exists) return _usuarioDesdeFirebase(firebaseUser);
    return app.User.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<app.User?> obtenerPerfilPorNombre(String nombre) async {
    final actual = await obtenerPerfilActual();
    if (actual != null) return actual;

    final resultado = await _firestore
        .collection('users')
        .where('name_lower', isEqualTo: nombre.toLowerCase())
        .limit(1)
        .get();
    if (resultado.docs.isEmpty) return null;
    final doc = resultado.docs.first;
    return app.User.fromMap({'id': doc.id, ...doc.data()});
  }

  Future<void> guardarPerfil(app.User usuario) async {
    await _firestore.collection('users').doc(usuario.id).set({
      ...usuario.toMap(),
      'name_lower': usuario.name.toLowerCase(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> eliminarPerfilActual() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;
    await _firestore.collection('users').doc(firebaseUser.uid).delete();
    await firebaseUser.delete();
  }

  app.User _usuarioDesdeFirebase(User firebaseUser) {
    final nombre = firebaseUser.displayName?.trim();
    return app.User(
      id: firebaseUser.uid,
      name: nombre != null && nombre.isNotEmpty
          ? nombre
          : firebaseUser.email?.split('@').first ?? 'usuario',
      email: firebaseUser.email ?? '',
      profileImage: firebaseUser.photoURL,
    );
  }

  Future<void> _inicializarGoogle() async {
    if (_googleInicializado) return;
    await GoogleSignIn.instance.initialize();
    _googleInicializado = true;
  }

  String _mensajeAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El email no tiene un formato valido.';
      case 'user-disabled':
        return 'El usuario esta deshabilitado.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contrasena incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email.';
      case 'weak-password':
        return 'La contrasena es demasiado debil.';
      case 'requires-recent-login':
        return 'Volvemos a iniciar sesion antes de eliminar la cuenta.';
      default:
        return 'No se pudo completar la autenticacion.';
    }
  }
}
