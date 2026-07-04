import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/config/theme/theme.dart';

final Provider<List<Color>> colorListProvider = Provider((ref) => colorList);
final Provider<List<String>> fontListProvider = Provider((ref) => fontList);

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((
  ref,
) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme()) {
    _cargarTemaDeDisco();
  }

  Future<void> _cargarTemaDeDisco() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final selectedColor = prefs.getInt('selectedColor') ?? 0;
    final selectedFont = prefs.getString('selectedFont') ?? 'Roboto';

    state = AppTheme(
      isDarkMode: isDarkMode,
      selectedColor: selectedColor,
      selectedFont: selectedFont,
    );
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final nuevoValor = !state.isDarkMode;
    await prefs.setBool('isDarkMode', nuevoValor);
    state = state.copyWith(isDarkMode: nuevoValor);
  }

  Future<void> changeColorTheme(int colorIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedColor', colorIndex);
    state = state.copyWith(selectedColor: colorIndex);
  }

  Future<void> changeFontTheme(String fontName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFont', fontName);
    state = state.copyWith(selectedFont: fontName);
  }
}

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('Español') {
    _cargarIdiomaDeDisco();
  }

  Future<void> _cargarIdiomaDeDisco() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('appLocale') ?? 'Español';
  }

  Future<void> cambiarIdioma(String nuevoIdioma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLocale', nuevoIdioma);
    state = nuevoIdioma;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

final traduccionesProvider = Provider<Map<String, Map<String, String>>>((ref) {
  return {
    'Español': {
      'home_titulo': 'Pantalla Principal',
      'home_bienvenido': 'Bienvenido',
      'home_sub':
          'Deslizá desde la izquierda o tocá el menú de arriba para navegar.',
      'menu_home': 'Inicio',
      'menu_perfil': 'Perfil',
      'menu_settings': 'Configuración',
      'menu_logout': 'Cerrar sesión',
      'set_titulo': 'Configuración',
      'set_sub': 'Ajustes de la Aplicación',
      'set_idioma': 'Idioma de la app',
      'set_idioma_sub': 'Selecciona el idioma de la interfaz',
      'set_moneda': 'Moneda del precio',
      'set_moneda_sub': 'Precios de frascos y decants',
      'set_vista': 'Visualizar lista',
      'set_vista_sub': 'Cómo ver tu catálogo',
      'set_color': 'Color temático',
      'set_color_sub': 'Aplicado: Color ',
      'set_fuente': 'Fuente del texto',
      'set_fuente_sub': 'Actual: ',
      'set_dark': 'Modo Oscuro',
      'set_dark_sub': 'Alternar el brillo de la app',
      'set_btn_guardar': 'Guardar Ajustes',
      'set_btn_volver': 'Volver al Home',
      'perfil_titulo': 'Perfil de Usuario',
      'perfil_guardar': 'Guardar Cambios',
      'perfil_cancelar': 'Cancelar',
      'perfil_exito': '¡Cambios guardados con éxito!',
      'msg_ajustes_guardados': 'Ajustes guardados',
      'login_titulo': 'Iniciar Sesión',
      'login_usuario': 'Usuario',
      'login_pass': 'Contraseña',
      'login_btn_ingresar': 'Ingresar',
      'login_btn_registrar': 'Registrarse',
      'reg_titulo': 'Crear Cuenta',
      'reg_usuario': 'Usuario *',
      'reg_email': 'Email *',
      'reg_edad': 'Edad (Opcional)',
      'reg_pass': 'Contraseña *',
      'reg_btn_registrar': 'Registrarme',
      'reg_btn_cancelar': 'Cancelar',
      'dialog_cancel_title': '¿Estás seguro?',
      'dialog_cancel_content':
          'Si cancelas, se perderán todos los cambios que no hayas guardado.',
      'dialog_cancel_btn_no': 'No, volver',
      'dialog_cancel_btn_yes': 'Sí, cancelar',
      'dialog_delete_title': 'Eliminar registro',
      'dialog_delete_content':
          '¿Estás seguro de que querés borrar esto? Esta acción no se puede deshacer.',
      'dialog_delete_btn_no': 'Cancelar',
      'dialog_delete_btn_yes': 'Sí, eliminar',
      'det_desc': 'DESCRIPCIÓN',
      'det_esp': 'ESPECIFICACIONES',
      'det_res': 'RESEÑA PERSONAL',
      'det_clima': 'Clima recomendado:',
      'det_duracion': 'Duración en piel:',
      'det_precio': 'Precio base:',
    },
    'English': {
      'home_titulo': 'Home Screen',
      'home_bienvenido': 'Welcome',
      'home_sub': 'Swipe from the left or tap the menu above to navigate.',
      'menu_home': 'Home',
      'menu_perfil': 'Profile',
      'menu_settings': 'Settings',
      'menu_logout': 'Log out',
      'set_titulo': 'Settings',
      'set_sub': 'App Settings',
      'set_idioma': 'App Language',
      'set_idioma_sub': 'Select interface language',
      'set_moneda': 'Price Currency',
      'set_moneda_sub': 'Bottles and decants pricing',
      'set_vista': 'View Catalog',
      'set_vista_sub': 'How to display your collection',
      'set_color': 'Theme Color',
      'set_color_sub': 'Applied: Color ',
      'set_fuente': 'Text Font',
      'set_fuente_sub': 'Current: ',
      'set_dark': 'Dark Mode',
      'set_dark_sub': 'Toggle app brightness',
      'set_btn_guardar': 'Save Settings',
      'set_btn_volver': 'Back to Home',
      'perfil_titulo': 'User Profile',
      'perfil_guardar': 'Save Changes',
      'perfil_cancelar': 'Cancel',
      'perfil_exito': 'Changes saved successfully!',
      'msg_ajustes_guardados': 'Settings saved',
      'login_titulo': 'Log In',
      'login_usuario': 'Username',
      'login_pass': 'Password',
      'login_btn_ingresar': 'Enter',
      'login_btn_registrar': 'Sign Up',
      'reg_titulo': 'Create Account',
      'reg_usuario': 'Username *',
      'reg_email': 'Email *',
      'reg_edad': 'Age (Optional)',
      'reg_pass': 'Password *',
      'reg_btn_registrar': 'Register',
      'reg_btn_cancelar': 'Cancel',
      'dialog_cancel_title': 'Are you sure?',
      'dialog_cancel_content':
          'If you cancel, all unsaved changes will be lost.',
      'dialog_cancel_btn_no': 'No, go back',
      'dialog_cancel_btn_yes': 'Yes, cancel',
      'dialog_delete_title': 'Delete record',
      'dialog_delete_content':
          'Are you sure you want to delete this? This action cannot be undone.',
      'dialog_delete_btn_no': 'Cancel',
      'dialog_delete_btn_yes': 'Yes, delete',
      'det_desc': 'DESCRIPTION',
      'det_esp': 'SPECIFICATIONS',
      'det_res': 'PERSONAL REVIEW',
      'det_clima': 'Recommended climate:',
      'det_duracion': 'Skin duration:',
      'det_precio': 'Base price:',
    },
    'Português': {
      'home_titulo': 'Tela Principal',
      'home_bienvenido': 'Bem-vindo',
      'home_sub': 'Deslize da esquerda ou toque no menu acima para navegar.',
      'menu_home': 'Início',
      'menu_perfil': 'Perfil',
      'menu_settings': 'Configurações',
      'menu_logout': 'Sair',
      'set_titulo': 'Configurações',
      'set_sub': 'Ajustes do Aplicativo',
      'set_idioma': 'Idioma do aplicativo',
      'set_idioma_sub': 'Selecione o idioma da interface',
      'set_moneda': 'Moeda do preço',
      'set_moneda_sub': 'Preços de frascos e decants',
      'set_vista': 'Visualizar lista',
      'set_vista_sub': 'Como ver seu catálogo',
      'set_color': 'Cor do tema',
      'set_color_sub': 'Aplicado: Cor ',
      'set_fuente': 'Fonte do texto',
      'set_fuente_sub': 'Atual: ',
      'set_dark': 'Modo Escuro',
      'set_dark_sub': 'Alternar brilho do app',
      'set_btn_guardar': 'Salvar Configurações',
      'set_btn_volver': 'Voltar para o Home',
      'perfil_titulo': 'Perfil de Usuário',
      'perfil_guardar': 'Salvar alterações',
      'perfil_cancelar': 'Cancelar',
      'perfil_exito': 'Modificações salvas com sucesso!',
      'msg_ajustes_guardados': 'Configurações salvas',
      'login_titulo': 'Entrar',
      'login_usuario': 'Usuário',
      'login_pass': 'Senha',
      'login_btn_ingresar': 'Acessar',
      'login_btn_registrar': 'Cadastrar-se',
      'reg_titulo': 'Criar Conta',
      'reg_usuario': 'Usuário *',
      'reg_email': 'E-mail *',
      'reg_edad': 'Idade (Opcional)',
      'reg_pass': 'Senha *',
      'reg_btn_registrar': 'Registrar-me',
      'reg_btn_cancelar': 'Cancelar',
      'dialog_cancel_title': 'Tem certeza?',
      'dialog_cancel_content':
          'Se você cancelar, todas as alterações não salvas serão perdidas.',
      'dialog_cancel_btn_no': 'Não, voltar',
      'dialog_cancel_btn_yes': 'Sim, cancelar',
      'dialog_delete_title': 'Excluir registro',
      'dialog_delete_content':
          'Tem certeza de que deseja excluir isso? Esta ação não pode ser desfeita.',
      'dialog_delete_btn_no': 'Cancelar',
      'dialog_delete_btn_yes': 'Sim, excluir',
      'det_desc': 'DESCRIÇÃO',
      'det_esp': 'ESPECIFICAÇÕES',
      'det_res': 'AVALIAÇÃO PESSOAL',
      'det_clima': 'Clima recomendado:',
      'det_duracion': 'Duração na pele:',
      'det_precio': 'Preço base:',
    },
  };
});
