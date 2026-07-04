import 'dart:io';

import 'package:app_perfumes/presentation/viewmodels/perfume_view_model.dart';
import 'package:app_perfumes/core/models/perfume.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class FormPerfumeScreen extends ConsumerStatefulWidget {
  final Perfume? perfume;
  final String nombreUsuario;

  const FormPerfumeScreen({
    super.key,
    this.perfume,
    required this.nombreUsuario,
  });

  @override
  ConsumerState<FormPerfumeScreen> createState() => _FormPerfumeScreenState();
}

class _FormPerfumeScreenState extends ConsumerState<FormPerfumeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombre,
      _disenador,
      _duracion,
      _clima,
      _descripcion,
      _precio;
  String? _fotoSeleccionadaPath;

  bool get esEdicion => widget.perfume != null;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.perfume?.nombre ?? '');
    _disenador = TextEditingController(text: widget.perfume?.disenador ?? '');
    _duracion = TextEditingController(
      text: widget.perfume?.duracionHoras.toString() ?? '',
    );
    _clima = TextEditingController(
      text: widget.perfume?.climaRecomendado ?? '',
    );
    _descripcion = TextEditingController(
      text: widget.perfume?.descripcion ?? '',
    );
    _precio = TextEditingController(
      text: widget.perfume?.precioUsd.toString() ?? '',
    );
    _fotoSeleccionadaPath = widget.perfume?.fotoPath;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _disenador.dispose();
    _duracion.dispose();
    _clima.dispose();
    _descripcion.dispose();
    _precio.dispose();
    super.dispose();
  }

  double? _parsePrecio(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  String? _validarTextoObligatorio(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  String? _validarPrecio(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';

    final precio = _parsePrecio(value);
    if (precio == null) return 'Ingresa un precio valido';
    if (precio <= 0) return 'El precio tiene que ser mayor a 0';
    if (precio > 100000) return 'Revisa el precio ingresado';
    return null;
  }

  String? _validarDuracion(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';

    final duracion = int.tryParse(value.trim());
    if (duracion == null) return 'Ingresa una duracion en horas';
    if (duracion <= 0) return 'La duracion tiene que ser mayor a 0';
    if (duracion > 72) return 'La duracion no puede superar 72 hs';
    return null;
  }

  ImageProvider? _imagenSeleccionada() {
    final foto = _fotoSeleccionadaPath;
    if (foto == null || foto.isEmpty) return null;
    if (foto.startsWith('http')) return NetworkImage(foto);
    return FileImage(File(foto));
  }

  void _seleccionarFoto() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? img = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) {
                    setState(() => _fotoSeleccionadaPath = img.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camara'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? img = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (img != null) {
                    setState(() => _fotoSeleccionadaPath = img.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _guardarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    final perfumeFinal = Perfume(
      id: widget.perfume?.id,
      nombre: _nombre.text.trim(),
      disenador: _disenador.text.trim(),
      duracionHoras: int.parse(_duracion.text.trim()),
      climaRecomendado: _clima.text.trim(),
      descripcion: _descripcion.text.trim(),
      precioUsd: _parsePrecio(_precio.text)!,
      fotoPath: _fotoSeleccionadaPath,
    );

    final viewModel = ref.read(perfumeViewModelProvider);
    await viewModel.guardarPerfume(
      perfume: perfumeFinal,
      nombreUsuario: widget.nombreUsuario,
      esEdicion: esEdicion,
    );

    if (mounted) {
      ref.invalidate(perfumesProvider(widget.nombreUsuario));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/home/${widget.nombreUsuario}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar' : 'Agregar'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: cs.surfaceContainerHighest,
                      backgroundImage: _imagenSeleccionada(),
                      child: _fotoSeleccionadaPath == null
                          ? const Icon(Icons.image, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _seleccionarFoto,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: cs.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildInput(_nombre, 'Nombre', Icons.label),
              _buildInput(_disenador, 'Disenador', Icons.business),
              _buildInput(
                _precio,
                'Precio (USD)',
                Icons.attach_money,
                type: const TextInputType.numberWithOptions(decimal: true),
                validator: _validarPrecio,
              ),
              _buildInput(
                _duracion,
                'Duracion (hs)',
                Icons.access_time,
                type: TextInputType.number,
                validator: _validarDuracion,
              ),
              _buildInput(_clima, 'Clima', Icons.wb_sunny),
              _buildInput(
                _descripcion,
                'Descripcion',
                Icons.description,
                type: TextInputType.text,
                lines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardarFormulario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  child: const Text('Guardar'),
                ),
              ),
              if (esEdicion) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: cs.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar perfume?'),
                          content: const Text(
                            'Esta accion no se puede deshacer.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: cs.error,
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();

                                await ref
                                    .read(perfumeViewModelProvider)
                                    .eliminarPerfume(
                                      widget.perfume!.id!,
                                      widget.nombreUsuario,
                                    );

                                ref.invalidate(
                                  perfumesProvider(widget.nombreUsuario),
                                );

                                if (mounted) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    context.go('/home/${widget.nombreUsuario}');
                                  });
                                }
                              },
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int lines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: lines,
        validator: validator ?? _validarTextoObligatorio,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
