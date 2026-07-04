import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/views/auth/login_view.dart';
import 'package:app_perfumes/views/auth/register_view.dart';
import 'package:app_perfumes/models/perfume.dart';
import 'package:app_perfumes/views/perfumes/perfume_detail_view.dart';
import 'package:app_perfumes/views/home/home_view.dart';
import 'package:app_perfumes/views/perfumes/perfume_form_view.dart';
import 'package:app_perfumes/views/profile/profile_view.dart';
import 'package:app_perfumes/views/settings/settings_view.dart';

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
