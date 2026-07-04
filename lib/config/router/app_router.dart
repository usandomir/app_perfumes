import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/features/auth/presentation/screens/login.dart';
import 'package:app_perfumes/features/auth/presentation/screens/register.dart';
import 'package:app_perfumes/database/perfumes.dart';
import 'package:app_perfumes/features/detail/detail.dart';
import 'package:app_perfumes/features/home/presentation/screens/home.dart';
import 'package:app_perfumes/features/edit/editar.dart';
import 'package:app_perfumes/features/profile/presentation/screens/perfil.dart';
import 'package:app_perfumes/config/settings/settings.dart';

class RouterNotifier {
  static Future<String> getInitialLocation() async => '/login';
}

Future<String> obtenerUsuarioActual(String fallback) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('usuarioLogueado') ?? fallback;
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
              state.pathParameters['usuario'] ?? usuarioInicial;
          return HomeScreen(nombre: nombreUsuario);
        },
      ),

      GoRoute(
        path: '/edit/:usuario',
        builder: (context, state) {
          final usuarioLogueado =
              state.pathParameters['usuario'] ?? usuarioInicial;
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
              state.pathParameters['usuario'] ?? usuarioInicial;
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
          return FutureBuilder<String>(
            future: obtenerUsuarioActual(usuarioInicial),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              return PerfilScreen(nombreUsuario: snapshot.data!);
            },
          );
        },
      ),

      GoRoute(
        path: '/settings/:usuario',
        builder: (context, state) {
          final nombreUsuario =
              state.pathParameters['usuario'] ?? usuarioInicial;
          return SettingsScreen(nombreUsuario: nombreUsuario);
        },
      ),
    ],
  );
}
