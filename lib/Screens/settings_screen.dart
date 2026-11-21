import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../DesignUI/app_avatar.dart';
import '../Screens/login_screen.dart';
import '../services/api_service.dart';
import '../services/call_history_store.dart';
import '../services/realtime_service.dart';
import '../services/session.dart';
import '../services/settings_service.dart';
import '../services/share_service.dart';
import '../theme/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  final Session session;

  const SettingsScreen({super.key, required this.session});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  bool _clearingCallHistory = false;

  @override
  void initState() {
    super.initState();
    _settings.loadSettings();
  }

  void _copyUserId() {
    Clipboard.setData(ClipboardData(text: widget.session.userId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showThemeDialog() async {
    final current = ThemeController.instance.themeMode;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choose theme'),
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System default'),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (val) => Navigator.of(context).pop(val),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (val) => Navigator.of(context).pop(val),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (val) => Navigator.of(context).pop(val),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      await ThemeController.instance.setThemeMode(selected);
      if (mounted) setState(() {});
    }
  }

  Future<void> _confirmClearCallHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear call history?'),
        content: const Text(
          'This will remove all incoming and outgoing call records from your device and server. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _clearingCallHistory = true);
    try {
      await CallHistoryStore.clear(widget.session.userId);
      await ApiService(token: widget.session.token).clearCallHistory().catchError((_) => false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call history cleared successfully.')),
        );
      }
    } finally {
      if (mounted) setState(() => _clearingCallHistory = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to sign out of AirMail?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    RealtimeService.instance.disconnect();
    await SessionStore.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
      case ThemeMode.system:
        return 'System default';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: scheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children, EdgeInsetsGeometry? padding}) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeMode = ThemeController.instance.themeMode;
    final isOnline = RealtimeService.instance.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_settings, ThemeController.instance]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // User profile header card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Card(
                  elevation: 0,
                  color: scheme.primaryContainer.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        AppAvatar(
                          name: widget.session.name,
                          size: 60,
                          online: isOnline,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.session.name.isEmpty
                                    ? 'AirMail User'
                                    : widget.session.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.session.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _copyUserId,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'ID: ${widget.session.userId.length > 12 ? "${widget.session.userId.substring(0, 10)}..." : widget.session.userId}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.copy,
                                        size: 13,
                                        color: scheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              _buildCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(_themeLabel(themeMode)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showThemeDialog,
                  ),
                ],
              ),

              // Notifications Section
              _buildSectionHeader(context, 'Notifications & Sounds'),
              _buildCard(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Message notifications'),
                    subtitle: const Text('Show banners for incoming messages'),
                    value: _settings.notifications,
                    onChanged: (val) => _settings.setNotifications(val),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_outlined),
                    title: const Text('Notification sounds'),
                    subtitle: const Text('Play audio for new messages'),
                    value: _settings.sound,
                    onChanged: (val) => _settings.setSound(val),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_outlined),
                    title: const Text('Vibrate on incoming calls'),
                    subtitle: const Text('Vibrate phone when someone calls you'),
                    value: _settings.vibrate,
                    onChanged: (val) => _settings.setVibrate(val),
                  ),
                ],
              ),

              // Chat & Calling Section
              _buildSectionHeader(context, 'Chat & Calling'),
              _buildCard(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.keyboard_return_outlined),
                    title: const Text('Send with Enter key'),
                    subtitle: const Text('Press Enter on keyboard to send message'),
                    value: _settings.enterIsSend,
                    onChanged: (val) => _settings.setEnterIsSend(val),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete_sweep_outlined,
                      color: scheme.error,
                    ),
                    title: Text(
                      'Clear call history',
                      style: TextStyle(color: scheme.error),
                    ),
                    subtitle: const Text('Delete all incoming and outgoing call records'),
                    trailing: _clearingCallHistory
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onTap: _clearingCallHistory ? null : _confirmClearCallHistory,
                  ),
                ],
              ),

              // Connection & Diagnostics
              _buildSectionHeader(context, 'Connection & Diagnostics'),
              _buildCard(
                children: [
                  ListTile(
                    leading: Icon(
                      isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                      color: isOnline ? const Color(0xFF10B981) : scheme.error,
                    ),
                    title: const Text('Socket.IO Gateway'),
                    subtitle: Text(
                      isOnline ? 'Connected to live signaling server' : 'Disconnected / Reconnecting',
                    ),
                    trailing: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? const Color(0xFF10B981) : scheme.error,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  const ListTile(
                    leading: Icon(Icons.network_check_outlined),
                    title: Text('WebRTC Relay (STUN / TURN)'),
                    subtitle: Text('Metered.ca TURN & Google STUN enabled for cross-network audio'),
                  ),
                ],
              ),

              // About & Developer
              _buildSectionHeader(context, 'About AirMail'),
              _buildCard(
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/airmail_logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.mail),
                      ),
                    ),
                    title: const Text('AirMail'),
                    subtitle: const Text('Version 1.0.0+1 (Stable)'),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AirMail',
                        applicationVersion: '1.0.0+1',
                        applicationIcon: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/airmail_logo.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        children: const [
                          Text(
                            'AirMail is a modern, high-performance messaging and WebRTC calling app featuring cross-network audio calls, real-time presence, and interactive games.',
                          ),
                        ],
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add_alt_outlined),
                    title: const Text('Invite friends to AirMail'),
                    subtitle: const Text('Share invite link and connect with others'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ShareService.showInviteModal(context, widget.session),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Open source licenses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'AirMail',
                      applicationVersion: '1.0.0+1',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out of AirMail'),
                  onPressed: _confirmLogout,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
