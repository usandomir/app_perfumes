import 'dart:io';

import 'package:app_perfumes/core/models/user.dart';
import 'package:app_perfumes/core/repositories/storage_repository.dart';
import 'package:app_perfumes/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  final String nombreUsuario;

  const PerfilScreen({super.key, required this.nombreUsuario});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _picker = ImagePicker();

  late TextEditingController _usernameController;
  User? _usuario;
  String? _imagenSeleccionada;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.nombreUsuario);
    _cargarUsuario();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await ref
        .read(userViewModelProvider)
        .obtenerPorNombre(widget.nombreUsuario);

    if (!mounted) return;
    setState(() {
      _usuario = usuario;
      _cargando = false;
      if (usuario != null) {
        _usernameController.text = usuario.name;
        _emailController.text = usuario.email;
        _ageController.text = usuario.age.toString();
        _imagenSeleccionada = usuario.profileImage;
      }
    });
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image == null || !mounted) return;
    setState(() => _imagenSeleccionada = image.path);
  }

  void _mostrarSelectorImagen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camara'),
              onTap: () {
                Navigator.of(context).pop();
                _seleccionarImagen(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarCambios() async {
    final usuarioActual = _usuario;
    if (usuarioActual == null || _guardando) return;

    setState(() => _guardando = true);
    try {
      final fotoUrl = await ref
          .read(storageRepositoryProvider)
          .subirImagen(
            pathLocal: _imagenSeleccionada,
            carpeta: 'perfiles',
            nombreArchivo: usuarioActual.id,
          );
      final edad =
          int.tryParse(_ageController.text.trim()) ?? usuarioActual.age;
      final usuarioActualizado = User(
        id: usuarioActual.id,
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        age: edad,
        profileImage: fotoUrl,
      );

      await ref.read(userViewModelProvider).actualizar(usuarioActualizado);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
      context.go('/home/${usuarioActualizado.name}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminarPerfil() async {
    final usuarioActual = _usuario;
    if (usuarioActual == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: const Text('Seguro que queres eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await ref.read(userViewModelProvider).eliminar(usuarioActual.id);

    if (!mounted) return;
    context.go('/login');
  }

  ImageProvider? _imagenPerfil() {
    final imagen = _imagenSeleccionada;
    if (imagen == null || imagen.isEmpty) return null;
    if (imagen.startsWith('http')) return NetworkImage(imagen);
    return FileImage(File(imagen));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_usuario == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('No se encontro el usuario.')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Perfil de usuario'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/${widget.nombreUsuario}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: _imagenPerfil(),
                  child: _imagenPerfil() == null
                      ? Icon(Icons.person, size: 56, color: colorScheme.primary)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    onPressed: _mostrarSelectorImagen,
                    icon: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _usernameController,
              label: 'Usuario',
              icon: Icons.account_circle,
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _ageController,
              label: 'Edad',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarCambios,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/home/${widget.nombreUsuario}'),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _eliminarPerfil,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar perfil'),
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.red[200] : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
