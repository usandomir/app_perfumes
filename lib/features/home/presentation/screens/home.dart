import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:app_perfumes/database/perfumes.dart';
import 'package:app_perfumes/database/perfume_repository.dart';
import 'package:app_perfumes/features/home/presentation/widget/drawer_menu.dart';

final vistaSettingsProvider = StateProvider<String>((ref) => 'Grilla');
final currencyProvider = StateProvider<String>((ref) => 'ARS');

class HomeScreen extends ConsumerStatefulWidget {
  final String nombre;
  const HomeScreen({super.key, required this.nombre});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isRefreshing = false;

  Future<List<Perfume>> _cargarPerfumes() async {
    if (_isRefreshing) await Future.delayed(const Duration(seconds: 2));
    return ref
        .read(perfumeRepositoryProvider)
        .obtenerPerfumesPorUsuario(widget.nombre);
  }

  String _obtenerPrecioFormateado(double precioUsd, String moneda) {
    if (moneda == 'ARS') {
      return '\$ ${(precioUsd * 1000).toStringAsFixed(0)}';
    } else if (moneda == 'EUR') {
      return '€ ${(precioUsd * 0.92).toStringAsFixed(2)}';
    } else {
      return 'U\$S ${precioUsd.toStringAsFixed(2)}';
    }
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
          'Catálogo de Perfumes',
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
                        color: colorScheme.primary.withOpacity(0.6),
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
                        'Presioná el botón + para agregar tu primer perfume a la colección.',
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
                  final precioMostrado = _obtenerPrecioFormateado(
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading:
                          (p.fotoPath != null && File(p.fotoPath!).existsSync())
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(p.fotoPath!),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                      title: Text(
                        p.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.disenador,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: colorScheme.primary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${p.duracionHoras} hs',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.wb_sunny_outlined,
                                size: 16,
                                color: colorScheme.primary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                p.climaRecomendado,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        precioMostrado,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.primary,
                        ),
                      ),
                      onTap: () async {
                        await context.push(
                          '/detail/${widget.nombre}',
                          extra: p,
                        );
                        setState(() {});
                      },
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
                final precioMostrado = _obtenerPrecioFormateado(
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
                        Expanded(
                          child:
                              (p.fotoPath != null &&
                                  File(p.fotoPath!).existsSync())
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.file(
                                    File(p.fotoPath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
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
