import 'package:airmail/Screens/developer_profile_screen.dart';
import 'package:flutter/material.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0x08080c),
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage("assets/images/bijoy.jpg"),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.wb_sunny)),
                  ],
                ),
                Spacer(),
                Text(
                  'Bijoy Biswas',
                  style: TextStyle(fontSize: 19, color: Colors.white),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '+8801751990907',
                      style: TextStyle(fontSize: 16, color: Color(0xa0a0a0)),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_drop_down_circle_sharp,
                            color: Color(0xa0a0a0)))
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x0f0f1a),
                  Color(0x1a1a2e),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.bookmark_border_outlined, color: Color(0xa0a0a0)),
            title: Text(
              'Saved Message',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: Color(0xa0a0a0)),
            title: Text(
              'Settings',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_outlined, color: Color(0xa0a0a0)),
            title: Text(
              'Invite Friends',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.help_outline_outlined, color: Color(0xa0a0a0)),
            title: Text(
              'AirMails Features',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => DeveloperScreen())),
            leading: Icon(Icons.person, color: Color(0x00d4aa)),
            title: Text(
              'Developer Contact',
              style: TextStyle(color: Color(0x00d4aa), fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}