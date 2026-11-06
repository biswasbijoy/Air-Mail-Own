import 'package:flutter/material.dart';
import "package:url_launcher/url_launcher.dart";

class DeveloperScreenUI extends StatefulWidget {
  const DeveloperScreenUI({Key? key}) : super(key: key);

  @override
  _DeveloperScreenUIState createState() => _DeveloperScreenUIState();
}

class _DeveloperScreenUIState extends State<DeveloperScreenUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(
          "Developer Information",
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.redAccent,
                Colors.purple,
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.15,
                  backgroundImage: AssetImage("assets/images/bijoy.jpg"),
                ),
                Divider(
                  height: 20,
                  color: Colors.white,
                  thickness: 2,
                ),
                Text(
                  "Bijoy Biswas",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Divider(
                  height: 20,
                  color: Colors.white,
                  thickness: 2,
                ),
                Text(
                  "Flutter Developer || Data Science Intern\nGoogle Certified Data Analyst\nMachine Learning Enthusiast\nCompetitive Programmer",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w100),
                  textAlign: TextAlign.center,
                ),
                Divider(
                  height: 20,
                  color: Colors.white,
                  thickness: 2,
                ),
                Text(
                  "Hey there, I am Bijoy Biswas, iOS developer and Data Science intern. I love developing amazing applications, puzzles are my favourite! I am also a competitive programmer and a Machine Learning enthusiast. I am currently working on Flutter and Data Science. I am also a Google Certified Data Analyst.",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                  // textAlign: TextAlign.center,
                ),
                Divider(
                  height: MediaQuery.of(context).size.height * 0.02,
                  color: Colors.white,
                  thickness: 2,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Text(
                  "Contact",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                Divider(
                  thickness: 2,
                  color: Colors.white,
                  indent: MediaQuery.of(context).size.width * 0.3,
                  endIndent: MediaQuery.of(context).size.width * 0.3,
                ),
                ListTileComp('tel:+8801719868313', "assets/images/call.jpg",
                    "+8801719868313"),
                SizedBox(
                  height: 2,
                ),
                ListTileComp('https://www.facebook.com/biswasbijoy414',
                    "assets/images/facebook.jpg", "@biswasbijoy414"),
                SizedBox(
                  height: 2,
                ),
                ListTileComp('https://www.linkedin.com/in/biswasbijoy',
                    "assets/images/linkedin.jpg", "@biswasbijoy"),
                SizedBox(
                  height: 2,
                ),
                ListTileComp('mailto:biswasbijoy414@gmail.com',
                    'assets/images/gmail.jpg', 'biswasbijoy414@gmail.com'),
                SizedBox(
                  height: 2,
                ),
                ListTileComp('https://t.me/bijoy414',
                    'assets/images/telegram.jpg', '@bijoy414'),
                SizedBox(
                  height: 2,
                ),
                ListTileComp('https://twitter.com/biswasbijoy_414',
                    'assets/images/twitter.jpg', '@biswasbijoy_414'),
                SizedBox(
                  height: 2,
                ),
                ListTileComp('https://github.com/biswasbijoy',
                    'assets/images/github.jpg', 'biswasbijoy'),
                SizedBox(
                  height: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget ListTileComp(String url, String assetImage, String text) {
    return ListTile(
      onTap: () {
        launch(url);
      },
      leading: CircleAvatar(
        backgroundImage: AssetImage(assetImage),
        radius: 30,
      ),
      title: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
    );
  }
}
