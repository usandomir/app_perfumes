import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_perfumes/config/theme/theme.dart';
import 'package:app_perfumes/features/home/presentation/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/config/theme/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String nombreUsuario;
  const SettingsScreen({super.key, required this.nombreUsuario});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _monedaSeleccionada = 'USD (U\$S)';
  String _vistaSeleccionada = 'Grilla';

  final List<String> _idiomas = ['Español', 'English', 'Português'];
  final List<String> _monedas = ['ARS (\$)', 'USD (U\$S)', 'EUR (€)'];
  final List<String> _vistas = ['Lista', 'Grilla', 'Compacto'];

  @override
  void initState() {
    super.initState();
    _cargarAjustesPersistidos();
  }

  Future<void> _cargarAjustesPersistidos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monedaSeleccionada =
          prefs.getString('monedaSeleccionada') ?? 'USD (U\$S)';
      _vistaSeleccionada = prefs.getString('vistaSeleccionada') ?? 'Compacto';
    });
  }

  void _irAlHome() {
    context.go('/home/${widget.nombreUsuario}');
  }

  void _guardarAjustes(String mensajeAviso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('monedaSeleccionada', _monedaSeleccionada);
    await prefs.setString('vistaSeleccionada', _vistaSeleccionada);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeAviso),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _irAlHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final int selectedColorIndex = currentTheme.selectedColor;
    final String selectedFont = currentTheme.selectedFont;
    final bool isDarkMode = currentTheme.isDarkMode;

    final String idiomaActual = ref.watch(localeProvider);
    final textos = ref.watch(traduccionesProvider)[idiomaActual]!;
    final Color colorDinamico = colorList[selectedColorIndex];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF12151C) : Colors.grey[200],
      appBar: AppBar(
        title: Text(textos['set_titulo']!),
        backgroundColor: colorDinamico,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _irAlHome,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Icono de configuración
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.settings, size: 60, color: colorDinamico),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade400,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(
                      textos['set_sub']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 24, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          leading: Icon(Icons.language, color: colorDinamico),
                          title: Text(textos['set_idioma']!),
                          trailing: _buildDropdownMenu(
                            value: idiomaActual,
                            items: _idiomas,
                            colorDinamico: colorDinamico,
                            onChanged: (v) => ref
                                .read(localeProvider.notifier)
                                .cambiarIdioma(v!),
                          ),
                        );
                      } else if (index == 1) {
                        return ListTile(
                          leading: Icon(
                            Icons.attach_money,
                            color: colorDinamico,
                          ),
                          title: Text(textos['set_moneda']!),
                          trailing: _buildDropdownMenu(
                            value: _monedaSeleccionada,
                            items: _monedas,
                            colorDinamico: colorDinamico,
                            onChanged: (v) {
                              setState(() => _monedaSeleccionada = v!);
                              ref.read(currencyProvider.notifier).state = v!
                                  .substring(0, 3);
                            },
                          ),
                        );
                      } else if (index == 2) {
                        return ListTile(
                          leading: Icon(Icons.grid_view, color: colorDinamico),
                          title: Text(textos['set_vista']!),
                          trailing: _buildDropdownMenu(
                            value: _vistaSeleccionada,
                            items: _vistas,
                            colorDinamico: colorDinamico,
                            onChanged: (v) {
                              setState(() => _vistaSeleccionada = v!);
                              ref.read(vistaSettingsProvider.notifier).state =
                                  v!;
                            },
                          ),
                        );
                      } else if (index == 3) {
                        return ListTile(
                          leading: Icon(
                            Icons.palette_outlined,
                            color: colorDinamico,
                          ),
                          title: Text(textos['set_color']!),
                          trailing: _buildDropdownMenu(
                            value: selectedColorIndex.toString(),
                            items: List.generate(
                              colorMapList.length,
                              (i) => i.toString(),
                            ),
                            isColorDropdown: true,
                            colorDinamico: colorDinamico,
                            onChanged: (v) => ref
                                .read(themeNotifierProvider.notifier)
                                .changeColorTheme(int.parse(v!)),
                          ),
                        );
                      } else if (index == 4) {
                        return ListTile(
                          leading: Icon(
                            Icons.font_download_outlined,
                            color: colorDinamico,
                          ),
                          title: Text(textos['set_fuente']!),
                          trailing: _buildDropdownMenu(
                            value: selectedFont,
                            items: fontList,
                            colorDinamico: colorDinamico,
                            onChanged: (v) => ref
                                .read(themeNotifierProvider.notifier)
                                .changeFontTheme(v!),
                          ),
                        );
                      } else {
                        return ListTile(
                          leading: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: colorDinamico,
                          ),
                          title: Text(
                            isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                          ),
                          trailing: Switch(
                            value: isDarkMode,
                            activeThumbColor: colorDinamico,
                            onChanged: (_) => ref
                                .read(themeNotifierProvider.notifier)
                                .toggleDarkMode(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () =>
                            _guardarAjustes(textos['msg_ajustes_guardados']!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorDinamico,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          textos['set_btn_guardar']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _irAlHome,
                      child: Text(
                        textos['set_btn_volver']!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMenu({
    required String value,
    required List<String> items,
    bool isColorDropdown = false,
    required Color colorDinamico,
    required ValueChanged<String?> onChanged,
  }) {
    final darkActive = ref.watch(themeNotifierProvider).isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: darkActive ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.arrow_drop_down, color: colorDinamico),
          dropdownColor: darkActive ? Colors.grey[850] : Colors.white,
          items: items
              .asMap()
              .entries
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: isColorDropdown
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: colorList[e.key],
                            ),
                            const SizedBox(width: 8),
                            Text(colorMapList[e.key]['nombre']),
                          ],
                        )
                      : Text(e.value),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
