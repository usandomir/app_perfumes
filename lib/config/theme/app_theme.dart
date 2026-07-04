import 'package:flutter/material.dart';

const colorList = <Color>[
  Colors.blue,
  Colors.purple,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.teal,
  Colors.indigo,
  Colors.pink,
  Colors.amber,
  Colors.cyan,
  Colors.brown,
  Colors.blueGrey,
];

const List<Map<String, dynamic>> colorMapList = [
  {'nombre': 'Azul', 'color': Colors.blue},
  {'nombre': 'Purpura', 'color': Colors.purple},
  {'nombre': 'Verde', 'color': Colors.green},
  {'nombre': 'Naranja', 'color': Colors.orange},
  {'nombre': 'Rojo', 'color': Colors.red},
  {'nombre': 'Turquesa', 'color': Colors.teal},
  {'nombre': 'Indigo', 'color': Colors.indigo},
  {'nombre': 'Rosa', 'color': Colors.pink},
  {'nombre': 'Ambar', 'color': Colors.amber},
  {'nombre': 'Cian', 'color': Colors.cyan},
  {'nombre': 'Marron', 'color': Colors.brown},
  {'nombre': 'Azul grisaceo', 'color': Colors.blueGrey},
];

const fontList = <String>['Roboto', 'Arial', 'Verdana', 'Courier New'];

class AppTheme {
  final bool isDarkMode;
  final int selectedColor;
  final String selectedFont;

  AppTheme({
    this.isDarkMode = false,
    this.selectedColor = 0,
    this.selectedFont = 'Roboto',
  });

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: colorList[selectedColor],
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    fontFamily: selectedFont,
  );

  AppTheme copyWith({
    bool? isDarkMode,
    int? selectedColor,
    String? selectedFont,
  }) {
    return AppTheme(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedFont: selectedFont ?? this.selectedFont,
    );
  }
}
