import 'dart:io';

import 'package:app_perfumes/config/settings/currency_formatter.dart';
import 'package:app_perfumes/database/opinion.dart';
import 'package:app_perfumes/database/opinion_repository.dart';
import 'package:app_perfumes/database/perfumes.dart';
import 'package:app_perfumes/features/home/presentation/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Perfume perfume;
  final String nombreUsuario;

  const DetailScreen({
    super.key,
    required this.perfume,
    required this.nombreUsuario,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _opinionController = TextEditingController();
  int _currentPage = 0;
  int _puntuacion = 5;
  bool _guardandoOpinion = false;

  @override
  void dispose() {
    _pageController.dispose();
    _opinionController.dispose();
    super.dispose();
  }

  Future<void> _agregarOpinion() async {
    final perfumeId = widget.perfume.id;
    final comentario = _opinionController.text.trim();
    if (perfumeId == null || comentario.isEmpty || _guardandoOpinion) return;

    setState(() => _guardandoOpinion = true);
    await ref
        .read(opinionRepositoryProvider)
        .registrarOpinion(
          Opinion(
            perfumeId: perfumeId,
            usuario: widget.nombreUsuario,
            comentario: comentario,
            puntuacion: _puntuacion,
            fechaIso: DateTime.now().toIso8601String(),
          ),
        );

    _opinionController.clear();
    setState(() {
      _puntuacion = 5;
      _guardandoOpinion = false;
    });
    ref.invalidate(opinionesProvider(perfumeId));
  }

  Future<void> _eliminarOpinion(Opinion opinion) async {
    final perfumeId = widget.perfume.id;
    if (opinion.id == null || perfumeId == null) return;

    await ref.read(opinionRepositoryProvider).eliminarOpinion(opinion.id!);
    ref.invalidate(opinionesProvider(perfumeId));
  }

  @override
  Widget build(BuildContext context) {
    final monedaActual = ref.watch(currencyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        title: const Text('Detalle', style: TextStyle(fontFamily: 'monospace')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(
              '/edit/${widget.nombreUsuario}',
              extra: widget.perfume,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentPage == index ? 20 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? colorScheme.primary
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              children: [
                _buildDescripcionPage(colorScheme),
                _buildEspecificacionesPage(monedaActual),
                _buildOpinionesPage(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcionPage(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text(
            'DESCRIPCIÓN',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 20),
          if (widget.perfume.fotoPath != null &&
              widget.perfume.fotoPath!.isNotEmpty &&
              File(widget.perfume.fotoPath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(widget.perfume.fotoPath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.blur_on, size: 60, color: Colors.grey),
            ),
          const SizedBox(height: 24),
          Text(
            widget.perfume.nombre,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            widget.perfume.disenador,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.perfume.descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEspecificacionesPage(String monedaActual) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const Text(
            'ESPECIFICACIONES',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 40),
          _buildSpecRow(
            Icons.wb_sunny_outlined,
            'Clima recomendado:',
            widget.perfume.climaRecomendado,
          ),
          const SizedBox(height: 24),
          _buildSpecRow(
            Icons.hourglass_empty,
            'Duración en piel:',
            '${widget.perfume.duracionHoras} hs',
          ),
          const SizedBox(height: 24),
          _buildSpecRow(
            Icons.monetization_on_outlined,
            'Precio base:',
            CurrencyFormatter.formatUsd(widget.perfume.precioUsd, monedaActual),
          ),
        ],
      ),
    );
  }

  Widget _buildOpinionesPage(ColorScheme colorScheme) {
    final perfumeId = widget.perfume.id;
    if (perfumeId == null) {
      return const Center(
        child: Text('Guardá el perfume antes de agregar opiniones.'),
      );
    }

    final opinionesAsync = ref.watch(opinionesProvider(perfumeId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Text(
            'OPINIONES',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: opinionesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('No se pudieron cargar las opiniones: $error'),
              ),
              data: (opiniones) {
                if (opiniones.isEmpty) {
                  return Center(
                    child: Text(
                      'Todavía no hay opiniones para este perfume.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: opiniones.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final opinion = opiniones[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          opinion.puntuacion.toString(),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        opinion.usuario,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(opinion.comentario),
                      trailing: IconButton(
                        tooltip: 'Eliminar opinión',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _eliminarOpinion(opinion),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Expanded(
                child: Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _puntuacion.toString(),
                  value: _puntuacion.toDouble(),
                  onChanged: (value) =>
                      setState(() => _puntuacion = value.round()),
                ),
              ),
              Text('$_puntuacion/5'),
            ],
          ),
          TextField(
            controller: _opinionController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Agregar opinión',
              prefixIcon: const Icon(Icons.rate_review_outlined),
              suffixIcon: IconButton(
                icon: _guardandoOpinion
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: _guardandoOpinion ? null : _agregarOpinion,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _agregarOpinion(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
