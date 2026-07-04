import 'dart:ui';

import 'package:app_perfumes/config/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<List<Color>> colorListProvider = Provider((ref) => colorList);
final Provider<List<String>> fontListProvider = Provider((ref) => fontList);

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((
  ref,
) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme()) {
    _cargarTemaDeDisco();
  }

  Future<void> _cargarTemaDeDisco() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final selectedColor = prefs.getInt('selectedColor') ?? 0;
    final selectedFont = prefs.getString('selectedFont') ?? 'Roboto';

    state = AppTheme(
      isDarkMode: isDarkMode,
      selectedColor: selectedColor,
      selectedFont: selectedFont,
    );
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final nuevoValor = !state.isDarkMode;
    await prefs.setBool('isDarkMode', nuevoValor);
    state = state.copyWith(isDarkMode: nuevoValor);
  }

  Future<void> changeColorTheme(int colorIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColor', colorIndex);
    state = state.copyWith(selectedColor: colorIndex);
  }

  Future<void> changeFontTheme(String fontName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFont', fontName);
    state = state.copyWith(selectedFont: fontName);
  }
}
