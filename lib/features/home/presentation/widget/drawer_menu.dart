import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_perfumes/config/theme/presentation/providers/theme_provider.dart';

class MiNavigationDrawer extends ConsumerWidget {
  final String nombreUsuario;
  final String currentRoute;
  const MiNavigationDrawer({
    super.key,
    required this.nombreUsuario,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idiomaActual = ref.watch(localeProvider);
    final textos = ref.watch(traduccionesProvider)[idiomaActual]!;

    return Drawer(
      backgroundColor: const Color(0xFFFFF5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Text(
                nombreUsuario.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.home_outlined,
            label: textos['menu_home']!,
            route: '/home/$nombreUsuario',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person_outline,
            label: textos['menu_perfil']!,
            route: '/perfil',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_outlined,
            label: textos['menu_settings']!,
            route: '/settings/$nombreUsuario',
            currentRoute: currentRoute,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10.0,
            ),
            child: Divider(color: Colors.grey[300], height: 1),
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.logout_outlined,
            label: textos['menu_logout']!,
            route: '/login',
            currentRoute: currentRoute,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required String currentRoute,
    bool isLogout = false,
  }) {
    final bool isSelected = currentRoute.startsWith(route);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        horizontalTitleGap: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        selectedTileColor: const Color(0xFFFFE4E4),
        selected: isSelected,
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.redAccent
              : (isSelected ? Colors.brown[700] : Colors.grey[600]),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isLogout
                ? Colors.redAccent
                : (isSelected ? Colors.brown[800] : Colors.grey[700]),
          ),
        ),
        onTap: () async {
          Navigator.of(context).pop();

          if (isLogout) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('usuarioLogueado');

            if (context.mounted) {
              context.go('/login');
            }
          } else {
            context.go(route);
          }
        },
      ),
    );
  }
}
