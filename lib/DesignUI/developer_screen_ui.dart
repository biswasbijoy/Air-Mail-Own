import 'package:flutter/material.dart';

class DeveloperScreenUI extends StatefulWidget {
  const DeveloperScreenUI({Key? key}) : super(key: key);

  @override
  _DeveloperScreenUIState createState() => _DeveloperScreenUIState();
}

class _DeveloperScreenUIState extends State<DeveloperScreenUI> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0x08080c),
      appBar: AppBar(
        title: const Text(
          "Developer Information",
        ),
        centerTitle: true,
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
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.15,
                  backgroundImage: AssetImage("assets/images/bijoy.jpg"),
                ),
                const Divider(
                  height: 20,
                  color: Color(0x33ffffff),
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
                const Divider(
                  height: 20,
                  color: Color(0x33ffffff),
                  thickness: 2,
                ),
                Text(
                  "Flutter Developer || Data Science Intern\nGoogle Certified Data Analyst\nMachine Learning Enthusiast\nCompetitive Programmer",
                  style: TextStyle(
                      color: Color(0xa0a0a0),
                      fontSize: 18,
                      fontWeight: FontWeight.w100),
                  textAlign: TextAlign.center,
                ),
                const Divider(
                  height: 20,
                  color: Color(0x33ffffff),
                  thickness: 2,
                ),
                Text(
                  "Hey there, I am Bijoy Biswas, iOS developer and Data Science intern. I love developing amazing applications, puzzles are my favourite! I am also a competitive programmer and a Machine Learning enthusiast. I am also a Google Certified Data Analyst.",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  // textAlign: TextAlign.center,
                ),
                Divider(
                  height: screenHeight * 0.02,
                  color: Color(0x33ffffff),
                  thickness: 2,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Contact",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Divider(
                  thickness: 2,
                  color: Color(0x33ffffff),
                  indent: 30,
                  endIndent: 30,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundImage: AssetImage("assets/images/call.jpg"),
                    radius: 30,
                  ),
                  title: Text(
                    "+8801719868313",
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundImage: AssetImage("assets/images/facebook.jpg"),
                    radius: 30,
                  ),
                  title: Text(
                    "@biswasbijoy414",
                    style: TextStyle(
                        color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundImage: AssetImage("assets/images/linkedin.jpg"),
                    radius: 30,
                  ),
                  title: Text(
                    "@biswasbijoy",
                    style: TextStyle(
                        color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/gmail.jpg'),
                    radius: 30,
                  ),
                  title: Text(
                    'biswasbijoy414@gmail.com',
                    style: TextStyle(
                        color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/telegram.jpg'),
                    radius: 30,
                  ),
                  title: Text(
                    '@bijoy414',
                    style: TextStyle(
                        color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/twitter.jpg'),
                    radius: 30,
                  ),
                  title: Text(
                    '@biswasbijoy_414',
                    style: TextStyle(
                        color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/github.jpg'),
                    radius: 30,
                  ),
                  title: Text(
                    'biswasbijoy',
                    style: TextStyle(
                        color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}