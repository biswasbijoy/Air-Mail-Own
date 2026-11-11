import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/Screens/developer_profile_screen.dart';
import 'package:airmail/services/session.dart';
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
                  tooltip: 'Theme information',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Theme follows your device settings: Display > Theme.',
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.brightness_4_outlined,
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
            onTap: () => _showUnavailable(context, 'Settings'),
          ),
          ListTile(
            leading: Icon(
              Icons.person_add_alt_outlined,
              color: scheme.onSurfaceVariant,
            ),
            title: const Text('Invite friends'),
            onTap: () => _showUnavailable(context, 'Invite friends'),
          ),
          ListTile(
            leading: Icon(
              Icons.help_outline_outlined,
              color: scheme.onSurfaceVariant,
            ),
            title: const Text('AirMail features'),
            onTap: () => _showUnavailable(context, 'AirMail features'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.code_outlined, color: scheme.primary),
            title: Text(
              'Developer contact',
              style: TextStyle(color: scheme.primary),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeveloperScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text('Log out', style: TextStyle(color: scheme.error)),
            onTap: () {
              Navigator.of(context).pop();
              onLogout();
            },
          ),
        ],
      ),
    );
  }
}
