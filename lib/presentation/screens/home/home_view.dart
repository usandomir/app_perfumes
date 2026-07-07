import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:app_perfumes/core/models/perfume.dart';
import 'package:app_perfumes/core/utils/currency_formatter.dart';
import 'package:app_perfumes/presentation/viewmodels/perfume_view_model.dart';
import 'package:app_perfumes/presentation/widgets/drawer_menu.dart';

final vistaSettingsProvider = StateProvider<String>((ref) => 'Grilla');
final currencyProvider = StateProvider<String>((ref) => CurrencyFormatter.usd);

class HomeScreen extends ConsumerStatefulWidget {
  final String nombre;
  const HomeScreen({super.key, required this.nombre});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _cargarAjustesPersistidos();
  }

  Future<void> _cargarAjustesPersistidos() async {
    final prefs = await SharedPreferences.getInstance();
    final monedaGuardada = prefs.getString('monedaSeleccionada');
    final vistaGuardada = prefs.getString('vistaSeleccionada');

    if (!mounted) return;
    if (monedaGuardada != null) {
      ref.read(currencyProvider.notifier).state =
          CurrencyFormatter.codeFromLabel(monedaGuardada);
    }
    if (vistaGuardada != null) {
      ref.read(vistaSettingsProvider.notifier).state = vistaGuardada;
    }
  }

  Future<List<Perfume>> _cargarPerfumes() async {
    if (_isRefreshing) await Future.delayed(const Duration(seconds: 2));
    return ref.read(perfumeViewModelProvider).obtenerPerfumes(widget.nombre);
  }

  Widget _buildDatoLista({
    required IconData icon,
    required String texto,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildImagenLista(Perfume perfume) {
    final foto = perfume.fotoPath;
    if (foto != null && foto.isNotEmpty) {
      if (foto.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(foto, width: 50, height: 50, fit: BoxFit.cover),
        );
      }
      if (File(foto).existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(foto),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return const Icon(Icons.image, size: 40, color: Colors.grey);
  }

  Widget _buildImagenGrilla(Perfume perfume) {
    final foto = perfume.fotoPath;
    if (foto != null && foto.isNotEmpty) {
      if (foto.startsWith('http')) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(foto, fit: BoxFit.cover, width: double.infinity),
        );
      }
      if (File(foto).existsSync()) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.file(
            File(foto),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }
    }
    return const Icon(Icons.image, size: 50, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final vista = ref.watch(vistaSettingsProvider);
    final moneda = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Catalogo de Perfumes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      drawer: MiNavigationDrawer(
        nombreUsuario: widget.nombre,
        currentRoute: GoRouterState.of(context).uri.toString(),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isRefreshing = true;
          });
          await _cargarPerfumes();
          setState(() {
            _isRefreshing = false;
          });
        },
        child: FutureBuilder<List<Perfume>>(
          future: _cargarPerfumes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: colorScheme.primary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay perfumes registrados.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Presiona el boton + para agregar tu primer perfume a la coleccion.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final listaPerfumes = snapshot.data!;
            if (vista == 'Lista') {
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: listaPerfumes.length,
                itemBuilder: (context, index) {
                  final p = listaPerfumes[index];
                  final precioMostrado = CurrencyFormatter.formatUsd(
                    p.precioUsd,
                    moneda,
                  );

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await context.push(
                          '/detail/${widget.nombre}',
                          extra: p,
                        );
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImagenLista(p),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.disenador,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      _buildDatoLista(
                                        icon: Icons.access_time,
                                        texto: '${p.duracionHoras} hs',
                                        color: colorScheme.primary,
                                      ),
                                      _buildDatoLista(
                                        icon: Icons.wb_sunny_outlined,
                                        texto: p.climaRecomendado,
                                        color: colorScheme.primary,
                                      ),
                                      Text(
                                        precioMostrado,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: vista == 'Compacto' ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: vista == 'Compacto' ? 0.8 : 0.75,
              ),
              itemCount: listaPerfumes.length,
              itemBuilder: (context, index) {
                final p = listaPerfumes[index];
                final precioMostrado = CurrencyFormatter.formatUsd(
                  p.precioUsd,
                  moneda,
                );

                return GestureDetector(
                  onTap: () async {
                    await context.push('/detail/${widget.nombre}', extra: p);
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: _buildImagenGrilla(p)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                p.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                precioMostrado,
                                style: TextStyle(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () async {
          await context.push('/edit/${widget.nombre}', extra: null);
          setState(() {});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
