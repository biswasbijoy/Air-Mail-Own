import 'package:airmail/DesignUI/drawer_components.dart';
import 'package:airmail/Page/chat_page.dart';
import 'package:airmail/Screens/call_page.dart';
import 'package:airmail/Screens/calls_screen.dart';
import 'package:airmail/Screens/game_screen.dart';
import 'package:airmail/Screens/login_screen.dart';
import 'package:airmail/Screens/select_contact_page.dart';
import 'package:airmail/services/call_service.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/services/session.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.session});

  final Session session;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ChatPageState> _chatPageKey = GlobalKey<ChatPageState>();
  final GlobalKey<CallScreenState> _callScreenKey = GlobalKey<CallScreenState>();
  late final List<Widget> _pages;
  int _selectedIndex = 0;
  bool _callPageOpen = false;

  @override
  void initState() {
    super.initState();
    RealtimeService.instance.connect(widget.session);
    CallService.instance.currentUserId = widget.session.userId;
    CallService.instance.attach();
    CallService.instance.addListener(_handleCallStateChanged);
    _pages = [
      ChatPage(key: _chatPageKey, session: widget.session),
      SelectContact(session: widget.session),
      CallScreen(key: _callScreenKey, session: widget.session),
      const GameScreen(),
    ];
  }

  @override
  void dispose() {
    CallService.instance.removeListener(_handleCallStateChanged);
    CallService.instance.detach();
    RealtimeService.instance.disconnect();
    super.dispose();
  }

  void _handleCallStateChanged() {
    if (!mounted || _callPageOpen) return;

    final state = CallService.instance.state;
    if (state != CallState.outgoing && state != CallState.incoming) return;

    _callPageOpen = true;
    final route = MaterialPageRoute<void>(builder: (_) => const CallPage());
    Navigator.of(context).push(route).whenComplete(() {
      _callPageOpen = false;
      _callScreenKey.currentState?.refresh();
      final nextState = CallService.instance.state;
      if (nextState == CallState.outgoing || nextState == CallState.incoming) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleCallStateChanged();
        });
      }
    });
  }

  Future<void> _logout() async {
    RealtimeService.instance.disconnect();
    await SessionStore.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openContactPicker() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectContact(session: widget.session, embedded: false),
      ),
    );
    _chatPageKey.currentState?.refresh();
    _callScreenKey.currentState?.refresh();
  }

  Future<void> _openCallPicker() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectContact(
          session: widget.session,
          embedded: false,
          forCall: true,
        ),
      ),
    );
    _callScreenKey.currentState?.refresh();
  }

  void _onDestinationSelected(int index) {
    final previous = _selectedIndex;
    setState(() => _selectedIndex = index);
    if (index == 0 && previous != 0) {
      _chatPageKey.currentState?.refresh();
    } else if (index == 2 && previous != 2) {
      _callScreenKey.currentState?.refresh();
    }
  }

  String get _title {
    switch (_selectedIndex) {
      case 1:
        return 'Contacts';
      case 2:
        return 'Calls';
      case 3:
        return 'Games';
      default:
        return 'Inbox';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/airmail_logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 10),
            Text(_selectedIndex == 0 ? 'AirMail' : _title),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (value) {
              if (value == 'new_contact') {
                _openContactPicker();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'new_contact',
                child: Text('New chat'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Log out'),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.2),
        height: 68,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call),
            label: 'Calls',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              tooltip: 'New chat',
              onPressed: _openContactPicker,
              child: const Icon(Icons.edit_outlined),
            )
          : (_selectedIndex == 2
              ? FloatingActionButton(
                  tooltip: 'New call',
                  onPressed: _openCallPicker,
                  child: const Icon(Icons.add_call),
                )
              : null),
      drawer: DrawerComponent(
        session: widget.session,
        onLogout: _logout,
      ),
    );
  }
}
