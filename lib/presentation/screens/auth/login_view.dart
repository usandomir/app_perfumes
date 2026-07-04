import 'package:app_perfumes/core/models/user.dart';
import 'package:app_perfumes/presentation/viewmodels/theme_view_model.dart';
import 'package:app_perfumes/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _inputEmail = TextEditingController();
  final _inputPass = TextEditingController();

  bool _isObscure = true;
  bool _cargando = false;

  @override
  void dispose() {
    _inputEmail.dispose();
    _inputPass.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _inputEmail.text.trim();
    final pass = _inputPass.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showErrorSnackBar('Ingresa un email valido');
      return;
    }
    if (pass.isEmpty) {
      _showErrorSnackBar('La contrasena esta incompleta');
      return;
    }

    await _ejecutarAutenticacion(() {
      return ref.read(userViewModelProvider).autenticar(email, pass);
    });
  }

  Future<void> _handleGoogleLogin() async {
    await _ejecutarAutenticacion(() {
      return ref.read(userViewModelProvider).autenticarConGoogle();
    });
  }

  Future<void> _ejecutarAutenticacion(Future<User?> Function() accion) async {
    if (_cargando) return;
    setState(() => _cargando = true);

    try {
      final userFound = await accion();
      if (!mounted) return;

      if (userFound != null) {
        FocusScope.of(context).unfocus();
        context.pushReplacement('/home/${userFound.name}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
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
                    'Iniciar sesion',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _inputEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
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
                    obscureText: _isObscure,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      hintText: 'Contrasena',
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
                  ElevatedButton(
                    onPressed: _cargando ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorDinamico,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 55),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Ingresar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _cargando ? null : _handleGoogleLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Ingresar con Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(220, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cargando
                        ? null
                        : () => context.push('/register'),
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
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
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
