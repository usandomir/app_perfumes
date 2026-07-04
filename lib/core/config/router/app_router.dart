import 'package:app_perfumes/core/models/perfume.dart';
import 'package:app_perfumes/presentation/screens/auth/login_view.dart';
import 'package:app_perfumes/presentation/screens/auth/register_view.dart';
import 'package:app_perfumes/presentation/screens/home/home_view.dart';
import 'package:app_perfumes/presentation/screens/perfumes/perfume_detail_view.dart';
import 'package:app_perfumes/presentation/screens/perfumes/perfume_form_view.dart';
import 'package:app_perfumes/presentation/screens/profile/profile_view.dart';
import 'package:app_perfumes/presentation/screens/settings/settings_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier {
  static Future<String> getInitialLocation() async => '/login';
}

String obtenerNombreUsuario(String fallback) {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  return firebaseUser?.displayName ?? firebaseUser?.email ?? fallback;
}

GoRouter crearRouter(String ubicacionInicial, String usuarioInicial) {
  return GoRouter(
    initialLocation: ubicacionInicial,
    errorBuilder: (context, state) => const LoginScreen(),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home/:usuario',
        builder: (context, state) {
          final nombreUsuario =
              state.pathParameters['usuario'] ??
              obtenerNombreUsuario(usuarioInicial);
          return HomeScreen(nombre: nombreUsuario);
        },
      ),
      GoRoute(
        path: '/edit/:usuario',
        builder: (context, state) {
          final usuarioLogueado =
              state.pathParameters['usuario'] ??
              obtenerNombreUsuario(usuarioInicial);
          final perfumeParaEditar = state.extra as Perfume?;
          return FormPerfumeScreen(
            perfume: perfumeParaEditar,
            nombreUsuario: usuarioLogueado,
          );
        },
      ),
      GoRoute(
        path: '/detail/:usuario',
        builder: (context, state) {
          final usuarioLogueado =
              state.pathParameters['usuario'] ??
              obtenerNombreUsuario(usuarioInicial);
          final perfumeSeleccionado = state.extra as Perfume;
          return DetailScreen(
            perfume: perfumeSeleccionado,
            nombreUsuario: usuarioLogueado,
          );
        },
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) {
          return PerfilScreen(
            nombreUsuario: obtenerNombreUsuario(usuarioInicial),
          );
        },
      ),
      GoRoute(
        path: '/settings/:usuario',
        builder: (context, state) {
          final nombreUsuario =
              state.pathParameters['usuario'] ??
              obtenerNombreUsuario(usuarioInicial);
          return SettingsScreen(nombreUsuario: nombreUsuario);
        },
      ),
    ],
  );
}
