import 'package:flutter/material.dart';

final List<String> fontList = [
  'Roboto',
  'Serif',
  'Monospace',
  'Cursive',
  'Fantasy',
  'Sans-Serif',
  'Georgia',
  'Arial',
];

final List<Map<String, dynamic>> colorMapList = [
  {'nombre': 'Rojo', 'color': Colors.red},
  {'nombre': 'Verde', 'color': Colors.green},
  {'nombre': 'Azul', 'color': Colors.blue},
  {'nombre': 'Amarillo', 'color': Colors.yellow},
  {'nombre': 'Púrpura', 'color': Colors.purple},
  {'nombre': 'Naranja', 'color': Colors.orange},
  {'nombre': 'Rosa', 'color': Colors.pink},
  {'nombre': 'Teal', 'color': Colors.teal},
  {'nombre': 'Cian', 'color': Colors.cyan},
  {'nombre': 'Índigo', 'color': Colors.indigo},
  {'nombre': 'Lima', 'color': Colors.lime},
  {'nombre': 'Ámbar', 'color': Colors.amber},
  {'nombre': 'Marrón', 'color': Colors.brown},
  {'nombre': 'Gris', 'color': Colors.grey},
  {'nombre': 'Azul Grisáceo', 'color': Colors.blueGrey},
];

final List<Color> colorList = colorMapList
    .map((e) => e['color'] as Color)
    .toList();

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;
  final String selectedFont;

  AppTheme({
    this.selectedColor = 0,
    this.isDarkMode = false,
    this.selectedFont = 'Roboto',
  }) : assert(selectedColor >= 0, 'selectedColor must be greater than 0'),
       assert(
         selectedColor < colorMapList.length,
         'selectedColor must be less than colorList.length',
       );

  ThemeData getTheme() {
    final colorSemilla = colorMapList[selectedColor]['color'] as Color;

    return ThemeData(
      colorSchemeSeed: colorSemilla,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      fontFamily: selectedFont,
      useMaterial3: true,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: isDarkMode ? Colors.grey[950] : colorSemilla,
        foregroundColor: isDarkMode ? Colors.white : Colors.white,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorSemilla,
        foregroundColor: Colors.white,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorSemilla,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  AppTheme copyWith({
    int? selectedColor,
    bool? isDarkMode,
    String? selectedFont,
  }) {
    return AppTheme(
      selectedColor: selectedColor ?? this.selectedColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedFont: selectedFont ?? this.selectedFont,
    );
  }
}
