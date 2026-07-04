import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/config/router/app_router.dart';
import 'package:app_perfumes/viewmodels/theme_view_model.dart';
import 'package:app_perfumes/config/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? usuarioGuardado = prefs.getString('usuarioLogueado');
  final String rutaInicial =
      (usuarioGuardado != null && usuarioGuardado.isNotEmpty)
      ? '/home/$usuarioGuardado'
      : '/login';
  final String usuarioInicial = usuarioGuardado ?? '';
  final routerConfigurado = crearRouter(rutaInicial, usuarioInicial);

  runApp(ProviderScope(child: MainApp(routerConfigurado: routerConfigurado)));
}

class MainApp extends ConsumerWidget {
  final dynamic routerConfigurado;

  const MainApp({super.key, required this.routerConfigurado});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      routerConfig: routerConfigurado,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: themeState.isDarkMode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: colorList[themeState.selectedColor],

        fontFamily: themeState.selectedFont,
      ),
    );
  }
}
