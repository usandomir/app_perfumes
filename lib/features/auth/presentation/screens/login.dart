import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/database/user_repository.dart';
import 'package:app_perfumes/database/user.dart';
import 'package:app_perfumes/config/theme/presentation/providers/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _inputName = TextEditingController();
  final _inputPass = TextEditingController();

  bool _isObscure = true;

  @override
  void dispose() {
    _inputName.dispose();
    _inputPass.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final String name = _inputName.text.trim();
    final String pass = _inputPass.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar('El campo de usuario está incompleto');
      return;
    }
    if (pass.isEmpty) {
      _showErrorSnackBar('La contraseña está incompleta');
      return;
    }

    final User? userFound = await ref
        .read(userRepositoryProvider)
        .autenticarUsuario(name, pass);

    if (!mounted) return;

    if (userFound != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuarioLogueado', userFound.name);
      FocusScope.of(context).unfocus();
      Future.microtask(() {
        if (mounted) {
          context.pushReplacement('/home/${userFound.name}');
        }
      });
    } else {
      _showErrorSnackBar('Usuario o contraseña incorrectos');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    final colorDinamico = Theme.of(context).colorScheme.primary;
    final idiomaActual = ref.watch(localeProvider);
    final textos = ref.watch(traduccionesProvider)[idiomaActual]!;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textos['login_titulo']!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _inputName,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      hintText: textos['login_usuario']!,
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: colorDinamico,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: colorDinamico, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _inputPass,
                    obscureText: _isObscure, // Aquí se aplica el estado
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      hintText: textos['login_pass']!,
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorDinamico,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: colorDinamico,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: colorDinamico, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botón Ingresar
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorDinamico,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 55),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      textos['login_btn_ingresar']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón Registrarse
                  ElevatedButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.white,
                      foregroundColor: isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      minimumSize: const Size(220, 55),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Text(
                      textos['login_btn_registrar']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
