import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_perfumes/config/theme/presentation/providers/theme_provider.dart';
import 'package:app_perfumes/database/user.dart';
import 'package:app_perfumes/database/user_repository.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  final String nombreUsuario;

  const PerfilScreen({super.key, required this.nombreUsuario});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  late TextEditingController _usernameController;
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _deletePasswordController = TextEditingController();

  bool _mostrarCamposContrasena = false;
  File? _imageFile;
  final _picker = ImagePicker();
  User? _usuarioLogueadoDB;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.nombreUsuario);
    _recuperarDatosDeUsuario();
  }

  void _recuperarDatosDeUsuario() async {
    final pathDB = await ref.read(userRepositoryProvider).database;
    final List<Map<String, dynamic>> res = await pathDB.query(
      'usuarios',
      where: 'LOWER(name) = ?',
      whereArgs: [widget.nombreUsuario.toLowerCase()],
    );

    if (res.isNotEmpty) {
      setState(() {
        _usuarioLogueadoDB = User.fromMap(res.first);
        _emailController.text = _usuarioLogueadoDB!.email;
        _ageController.text = _usuarioLogueadoDB!.age.toString();

        if (_usuarioLogueadoDB!.profileImage != null &&
            _usuarioLogueadoDB!.profileImage!.isNotEmpty) {
          _imageFile = File(_usuarioLogueadoDB!.profileImage!);
        }
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  void _mostrarPopupAdvertenciaEliminar(
    Color colorDinamico,
    Map<String, String> textos,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(textos['dialog_delete_title']!),
            ],
          ),
          content: Text(textos['dialog_delete_content']!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                textos['dialog_delete_btn_no']!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarPopupConfirmarContrasenaBorrado(colorDinamico, textos);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                textos['dialog_delete_btn_yes']!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarPopupConfirmarContrasenaBorrado(
    Color colorDinamico,
    Map<String, String> textos,
  ) {
    _deletePasswordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _deletePasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: colorDinamico),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                textos['dialog_delete_btn_no']!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_usuarioLogueadoDB != null &&
                    _deletePasswordController.text ==
                        _usuarioLogueadoDB!.password) {
                  Navigator.of(context).pop();
                  await ref
                      .read(userRepositoryProvider)
                      .eliminarUsuario(_usuarioLogueadoDB!.id);
                  if (mounted) {
                    context.go('/login');
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                textos['dialog_delete_btn_yes']!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _imgFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  Future<void> _imgFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  void _showImagePicker(BuildContext context, Color colorDinamico) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Seleccionar foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: colorDinamico,
                ),
                title: const Text('Galería'),
                onTap: () {
                  _imgFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera_outlined,
                  color: colorDinamico,
                ),
                title: const Text('Cámara'),
                onTap: () {
                  _imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarPopupGuardar(Map<String, String> textos, Color colorDinamico) {
    _confirmPasswordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirmar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: colorDinamico),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                textos['perfil_cancelar']!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_usuarioLogueadoDB != null &&
                    _confirmPasswordController.text ==
                        _usuarioLogueadoDB!.password) {
                  Navigator.of(context).pop();

                  final usuarioModificado = User(
                    id: _usuarioLogueadoDB!.id,
                    name: _usernameController.text,
                    email: _emailController.text,
                    password: _newPasswordController.text.isNotEmpty
                        ? _newPasswordController.text
                        : _usuarioLogueadoDB!.password,
                    age: int.tryParse(_ageController.text) ?? 0,
                    profileImage: _imageFile?.path,
                  );

                  await ref
                      .read(userRepositoryProvider)
                      .actualizarUsuario(usuarioModificado);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(textos['perfil_exito']!),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.go('/home/${_usernameController.text}');
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: colorDinamico),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final bool isDarkMode = currentTheme.isDarkMode;
    final String idiomaActual = ref.watch(localeProvider);
    final textos = ref.watch(traduccionesProvider)[idiomaActual]!;

    final colorScheme = Theme.of(context).colorScheme;
    final Color colorDinamico = colorScheme.primary;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      appBar: AppBar(
        title: Text(textos['perfil_titulo']!),
        backgroundColor: colorDinamico,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/${widget.nombreUsuario}'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : null,
                      child: _imageFile == null
                          ? Icon(
                              Icons.person,
                              size: 70,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => _showImagePicker(context, colorDinamico),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: colorDinamico,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        textos['perfil_titulo']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _usernameController,
                      label: textos['reg_usuario']!,
                      icon: Icons.account_circle,
                      colorDinamico: colorDinamico,
                      isDarkMode: isDarkMode,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: textos['reg_email']!,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      colorDinamico: colorDinamico,
                      isDarkMode: isDarkMode,
                    ),
                    _buildTextField(
                      controller: _ageController,
                      label: textos['reg_edad']!,
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      colorDinamico: colorDinamico,
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => _mostrarCamposContrasena =
                              !_mostrarCamposContrasena,
                        ),
                        icon: Icon(
                          _mostrarCamposContrasena
                              ? Icons.expand_less
                              : Icons.lock_reset,
                          color: colorDinamico,
                        ),
                        label: Text(
                          'Cambiar contraseña',
                          style: TextStyle(color: colorDinamico, fontSize: 16),
                        ),
                      ),
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _mostrarCamposContrasena
                          ? Column(
                              children: [
                                const Divider(height: 30),
                                _buildTextField(
                                  controller: _currentPasswordController,
                                  label: textos['login_pass']!,
                                  icon: Icons.password,
                                  obscureText: true,
                                  colorDinamico: colorDinamico,
                                  isDarkMode: isDarkMode,
                                ),
                                _buildTextField(
                                  controller: _newPasswordController,
                                  label: 'New Password',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  colorDinamico: colorDinamico,
                                  isDarkMode: isDarkMode,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () =>
                            _mostrarPopupGuardar(textos, colorDinamico),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorDinamico,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          textos['perfil_guardar']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: TextButton(
                        onPressed: () =>
                            context.go('/home/${widget.nombreUsuario}'),
                        child: Text(
                          textos['perfil_cancelar']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    Center(
                      child: TextButton.icon(
                        onPressed: () => _mostrarPopupAdvertenciaEliminar(
                          colorDinamico,
                          textos,
                        ),
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          textos['dialog_delete_title']!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required Color colorDinamico,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(icon, color: colorDinamico),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorDinamico, width: 2),
          ),
        ),
      ),
    );
  }
}
