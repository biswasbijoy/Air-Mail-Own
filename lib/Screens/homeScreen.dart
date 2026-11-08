import 'dart:io';

import 'package:airmail/DesignUI/drawer_components.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Page/chat_page.dart';
import 'package:airmail/Screens/calls_screen.dart';
import 'package:airmail/Screens/game_screen.dart';
import 'package:airmail/Screens/login_screen.dart';
import 'package:airmail/Screens/select_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:airmail/theme/app_colors.dart';
import 'package:airmail/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.chatmodels,
    required this.sourceChat,
  }) : super(key: key);

  final List<ChatModel> chatmodels;
  final ChatModel sourceChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChatModel> _contacts = [];
  String? _token;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      initialIndex: 0,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _token = ModalRoute.of(context)!.settings.arguments as String?;
    _userId = _token != null ? 'temp_user' : null;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('https://airmail-backend.onrender.com/api/users'),
              headers: {'Authorization': 'Bearer $_token'});
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        setState(() {
          _contacts = users.map((user) {
            return ChatModel(
              name: user['name'],
              icon: 'assets/images/default_avatar.png',
              id: user['_id'].toString().substring(0, 8),
              email: user['email'],
              time: 'Just now',
              status: 'online',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkBg,
                AppColors.darkSurface,
                AppColors.darkRaised,
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'New Contacts',
                  child: Text('New Contacts'),
                ),
                const PopupMenuItem(
                  value: 'New Broadcast',
                  child: Text('New Broadcast'),
                ),
                const PopupMenuItem(
                  value: 'Airmails Web',
                  child: Text('Airmails Web'),
                ),
                const PopupMenuItem(
                  value: 'Settings',
                  child: Text('Settings'),
                ),
                PopupMenuItem(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  value: 'Log out',
                  child: const Text('Log out'),
                ),
                PopupMenuItem(
                  onTap: () {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else {
                      exit(0);
                    }
                  },
                  value: 'Exit',
                  child: const Text('Exit'),
                ),
              ];
            },
          ),
        ],
        elevation: 0,
        titleSpacing: 20,
      ),
      body: IndexedStack(
        index: _tabController.index,
        children: [
          ChatPage(
            chatmodels: widget.chatmodels,
            sourceChat: widget.sourceChat,
          ),
          SelectContact(),
          CallScreen(),
          GameScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        height: 68,
        onDestinationSelected: (int index) {
          setState(() {
            _tabController.animateTo(index);
          });
        },
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
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectContact(),
                  ),
                );
              },
              child: const Icon(Icons.edit_outlined),
            )
          : null,
      drawer: DrawerComponent(),
    );
  }

  Widget _buildAppBarTitle() {
    switch (_tabController.index) {
      case 0:
        return const Text('Inbox');
      case 1:
        return const Text('Contacts');
      case 2:
        return const Text('Calls');
      case 3:
        return const Text('Games');
      default:
        return const Text('AirMail');
    }
  }
}