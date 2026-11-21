import 'package:flutter/material.dart';

import 'Screens/call_page.dart';
import 'Screens/home_screen.dart';
import 'Screens/login_screen.dart';
import 'services/call_service.dart';
import 'services/notification_sound_service.dart';
import 'services/session.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.loadThemeMode();
  await SettingsService.instance.loadSettings();
  await NotificationSoundService.instance.init();

  NotificationSoundService.instance.onReturnToCall = () {
    if (CallService.instance.state != CallState.idle) {
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute<void>(builder: (_) => const CallPage()),
      );
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'AirMail',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeController.instance.themeMode,
          home: const SessionGate(),
        );
      },
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<Session?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = SessionStore.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data;
        if (session == null) {
          return const LoginScreen();
        }
        return HomeScreen(session: session);
      },
    );
  }
}
