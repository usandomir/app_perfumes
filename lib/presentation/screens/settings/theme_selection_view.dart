// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_perfumes/core/config/theme/app_theme.dart';
import 'package:app_perfumes/presentation/viewmodels/theme_view_model.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  static const name = 'theme_selection_screen';
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seleccion de tema'),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).toggleDarkMode();
              },
              icon: isDarkMode
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
            ),
          ],

          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.palette_outlined), text: 'Colores'),
              Tab(icon: Icon(Icons.font_download_outlined), text: 'Fuentes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ColorSelectionView(), _FontSelectionView()],
        ),
      ),
    );
  }
}

class _ColorSelectionView extends ConsumerWidget {
  const _ColorSelectionView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Color> colors = colorList;
    final int selectedColor = ref.watch(themeNotifierProvider).selectedColor;

    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        return RadioListTile<int>(
          title: Text(
            'Color $index',
            style: TextStyle(color: colors[index], fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '#${colors[index].toARGB32().toRadixString(16).toUpperCase()}',
          ),
          activeColor: colors[index],
          value: index,
          groupValue: selectedColor,
          onChanged: (value) {
            ref
                .read(themeNotifierProvider.notifier)
                .changeColorTheme(value ?? 0);
          },
        );
      },
    );
  }
}

class _FontSelectionView extends ConsumerWidget {
  const _FontSelectionView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> fonts = fontList;
    final String selectedFont = ref.watch(themeNotifierProvider).selectedFont;

    return ListView.builder(
      itemCount: fonts.length,
      itemBuilder: (context, index) {
        final String fontName = fonts[index];

        return RadioListTile<String>(
          title: Text(
            fontName,
            style: TextStyle(
              fontFamily: fontName,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text('Tipografia estilo $fontName'),
          value: fontName,
          groupValue: selectedFont,
          onChanged: (value) {
            if (value != null) {
              ref.read(themeNotifierProvider.notifier).changeFontTheme(value);
            }
          },
        );
      },
    );
  }
}
