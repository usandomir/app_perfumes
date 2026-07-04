import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_perfumes/presentation/viewmodels/user_view_model.dart';

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
            ref: ref,
            icon: Icons.home_outlined,
            label: 'Inicio',
            route: '/home/$nombreUsuario',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context: context,
            ref: ref,
            icon: Icons.person_outline,
            label: 'Perfil',
            route: '/perfil',
            currentRoute: currentRoute,
          ),
          _buildDrawerItem(
            context: context,
            ref: ref,
            icon: Icons.settings_outlined,
            label: 'Configuracion',
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
            ref: ref,
            icon: Icons.logout_outlined,
            label: 'Cerrar sesion',
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
    required WidgetRef ref,
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
            await ref.read(userViewModelProvider).cerrarSesion();

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
