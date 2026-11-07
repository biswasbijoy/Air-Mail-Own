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
  _HomeScreenState();

  late TabController _tabController;
  List<ChatModel> _contacts = [];
  String? _token;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _token = ModalRoute.of(context)!.settings.arguments as String?;
    _userId = _token != null ? 'temp_user' : null; // In real app, decode token
    _fetchUsers();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
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
        title: const Text(
          "AirMail",
          style: TextStyle(
              color: Color(0xfffff8f0),
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x0f0f1a),
                Color(0x1a1a2e),
                Color(0x25253b),
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search,
                color: Colors.white),
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
        bottom: TabBar(
          indicatorColor: Color(0x00d4aa),
          indicatorWeight: 4,
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.inbox, color: Colors.white),
              text: 'Inbox',
            ),
            Tab(
              icon: Icon(Icons.contacts, color: Colors.white),
              text: 'Contacts',
            ),
            Tab(
              icon: Icon(Icons.call, color: Colors.white),
              text: 'Calls',
            ),
            Tab(
              icon: Icon(Icons.sports_esports_outlined, color: Colors.white),
              text: 'Games',
            ),
          ],
        ),
        elevation: 20,
        titleSpacing: 20,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatPage(
            chatmodels: _contacts,
            sourceChat: ChatModel(
              name: _userId != null ? 'User' : 'Unknown',
              id: _userId ?? '0',
              email: _token ?? '',
            ),
          ),
          SelectContact(),
          CallScreen(),
          GameScreen(),
        ],
      ),
      drawer: DrawerComponent(),
    );
  }
}