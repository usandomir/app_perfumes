import 'package:app_perfumes/core/models/user.dart';
import 'package:app_perfumes/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passController = TextEditingController();

  bool _isObscure = true;
  bool _cargando = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final ageStr = _ageController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _mostrarMensaje('Por favor, completa los campos obligatorios (*)');
      return;
    }
    if (!email.contains('@')) {
      _mostrarMensaje('Ingresa un email valido');
      return;
    }
    if (pass.length < 6) {
      _mostrarMensaje('La contrasena tiene que tener al menos 6 caracteres');
      return;
    }

    setState(() => _cargando = true);
    try {
      final newUser = User(
        id: '',
        name: name,
        email: email,
        age: int.tryParse(ageStr) ?? 0,
      );

      await ref.read(userViewModelProvider).registrar(newUser, pass);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuario creado con exito'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home/$name');
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildInput(
                controller: _nameController,
                hint: 'Usuario *',
                colorScheme: colorScheme,
              ),
              _buildInput(
                controller: _emailController,
                hint: 'Email *',
                keyboardType: TextInputType.emailAddress,
                colorScheme: colorScheme,
              ),
              _buildInput(
                controller: _ageController,
                hint: 'Edad (opcional)',
                keyboardType: TextInputType.number,
                colorScheme: colorScheme,
              ),
              _buildInput(
                controller: _passController,
                hint: 'Contrasena *',
                obscureText: _isObscure,
                colorScheme: colorScheme,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Registrarme',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              TextButton(
                onPressed: _cargando ? null : () => context.go('/login'),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required ColorScheme colorScheme,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          hintText: hint,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
