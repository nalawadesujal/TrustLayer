import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.onProfileTap,
    this.onAboutTap,
    this.onHelpTap,
  });

  final VoidCallback? onProfileTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onHelpTap;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username;
    final email = authProvider.currentUser?.email;

    return Drawer(
      backgroundColor: AppTheme.black,
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _DrawerHeader(username: username, email: email),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                onTap: () => _replaceWith(context, '/dashboard'),
              ),
              _DrawerItem(
                icon: Icons.history_outlined,
                label: 'History',
                onTap: () => _push(context, '/history'),
              ),
              _DrawerItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: onProfileTap ?? () => _push(context, '/profile'),
              ),
              _DrawerItem(
                icon: Icons.info_outline,
                label: 'About',
                onTap: onAboutTap ?? () => _push(context, '/about'),
              ),
              _DrawerItem(
                icon: Icons.help_outline,
                label: 'Help',
                onTap: onHelpTap ?? () => _push(context, '/help'),
              ),
              const Spacer(),
              Divider(color: AppTheme.outlineBlue.withOpacity(0.7)),
              _DrawerItem(
                icon: Icons.logout_outlined,
                label: 'Logout',
                color: AppTheme.errorRed,
                onTap: () => _logout(context, authProvider),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, String routeName) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(routeName);
  }

  void _replaceWith(BuildContext context, String routeName) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    Navigator.of(context).pop();
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.username, required this.email});

  final String username;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard.withOpacity(0.62),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cyberCyan.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.electricBlue.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.electricBlue.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cyberCyan.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.security_outlined,
                color: AppTheme.cyberCyan,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'TrustLayer',
              style: TextStyle(
                color: AppTheme.textMain,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email != null && email!.isNotEmpty ? email! : username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.textMain,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppTheme.cyberCyan.withOpacity(0.08),
          highlightColor: AppTheme.electricBlue.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: color.withOpacity(0.55),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
