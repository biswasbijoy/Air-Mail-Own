import 'package:airmail/Screens/developer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:airmail/theme/app_colors.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.darkBg,
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
                      style: TextStyle(fontSize: 16, color: AppColors.darkMuted),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_drop_down_circle_sharp,
                            color: AppColors.darkMuted))
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                AppColors.darkBg,
                AppColors.darkSurface,
              ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.bookmark_border_outlined, color: AppColors.darkMuted),
            title: Text(
              'Saved Message',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: AppColors.darkMuted),
            title: Text(
              'Settings',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_outlined, color: AppColors.darkMuted),
            title: Text(
              'Invite Friends',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.help_outline_outlined, color: AppColors.darkMuted),
            title: Text(
              'AirMails Features',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => DeveloperScreen())),
            leading: Icon(Icons.person, color: AppColors.primary),
            title: Text(
              'Developer Contact',
              style: TextStyle(color: AppColors.primary, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}