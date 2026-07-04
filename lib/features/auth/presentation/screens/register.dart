import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_perfumes/database/user_repository.dart';
import 'package:app_perfumes/database/user.dart';
import 'package:app_perfumes/config/theme/presentation/providers/theme_provider.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String pass = _passController.text.trim();
    final String ageStr = _ageController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, completa los campos obligatorios (*)',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: pass,
      age: int.tryParse(ageStr) ?? 0,
    );

    await ref.read(userRepositoryProvider).registrarUsuario(newUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Usuario creado con éxito!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final idiomaActual = ref.watch(localeProvider);
    final textos = ref.watch(traduccionesProvider)[idiomaActual]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(textos['reg_titulo']!),
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
                hint: textos['reg_usuario']!,
                colorScheme: colorScheme,
              ),
              _buildInput(
                controller: _emailController,
                hint: textos['reg_email']!,
                keyboardType: TextInputType.emailAddress,
                colorScheme: colorScheme,
              ),
              _buildInput(
                controller: _ageController,
                hint: textos['reg_edad']!,
                keyboardType: TextInputType.number,
                colorScheme: colorScheme,
              ),
              _buildInput(
                controller: _passController,
                hint: textos['reg_pass']!,
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
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    textos['reg_btn_registrar']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  textos['reg_btn_cancelar']!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
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
