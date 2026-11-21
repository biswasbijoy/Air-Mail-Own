import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/Screens/settings_screen.dart';
import 'package:airmail/services/session.dart';
import 'package:airmail/services/share_service.dart';
import 'package:airmail/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final Session session;
  final Future<void> Function() onLogout;

  void _showUnavailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not available yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: scheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.surface, scheme.surfaceContainerHighest],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: Row(
              children: [
                AppAvatar(name: session.name, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name.isEmpty ? 'AirMail user' : session.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: Theme.of(context).brightness == Brightness.dark
                      ? 'Switch to light theme'
                      : 'Switch to dark theme',
                  onPressed: () {
                    ThemeController.instance.toggleTheme(context);
                  },
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.bookmark_border_outlined,
              color: scheme.onSurfaceVariant,
            ),
            title: const Text('Saved messages'),
            onTap: () => _showUnavailable(context, 'Saved messages'),
          ),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: scheme.onSurfaceVariant,
            ),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(session: session),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person_add_alt_outlined,
              color: scheme.onSurfaceVariant,
            ),
            title: const Text('Invite friends'),
            onTap: () {
              Navigator.of(context).pop();
              ShareService.showInviteModal(context, session);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text('Log out', style: TextStyle(color: scheme.error)),
            onTap: () {
              Navigator.of(context).pop();
              onLogout();
            },
          ),
          const SizedBox(height: 12),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/airmail_logo.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AirMail',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
