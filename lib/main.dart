import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/core/config/router/app_router.dart';
import 'package:app_perfumes/presentation/viewmodels/theme_view_model.dart';
import 'package:app_perfumes/core/config/theme/app_theme.dart';
import 'package:app_perfumes/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('usuarioLogueado');

  final firebaseUser = FirebaseAuth.instance.currentUser;
  final String usuarioInicial =
      firebaseUser?.displayName ?? firebaseUser?.email ?? '';
  final String rutaInicial = firebaseUser != null
      ? '/home/$usuarioInicial'
      : '/login';
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
