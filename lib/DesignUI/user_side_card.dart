import 'package:flutter/material.dart';

class UserSideCard extends StatelessWidget {
  const UserSideCard({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Divider(
          height: 20,
          color: Color(0x33ffffff),
          thickness: 2,
        ),
        Text(
          "Flutter Developer || Data Science Intern\nGoogle Certified Data Analyst\nMachine Learning Enthusiast\nCompetitive Programmer",
          style: const TextStyle(
              color: Color(0xa0a0a0),
              fontSize: 16,
              fontWeight: FontWeight.w100),
          textAlign: TextAlign.center,
        ),
        const Divider(
          height: 20,
          color: Color(0x33ffffff),
          thickness: 2,
        ),
        Text(
          "Hey there, I am Bijoy Biswas, iOS developer and Data Science intern. I love developing amazing applications, puzzles are my favourite! I am also a competitive programmer and a Machine Learning enthusiast. I am currently working on Flutter and Data Science. I am also a Google Certified Data Analyst.",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        const Divider(
          height: 20,
          color: Color(0x33ffffff),
          thickness: 2,
        ),
        const Text(
          "Contact",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        const Divider(
          thickness: 2,
          color: Color(0x33ffffff),
          indent: 30,
          endIndent: 30,
        ),
        ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/call.jpg'),
            radius: 30,
          ),
          title: Text(
            "+8801719868313",
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/facebook.jpg'),
            radius: 30,
          ),
          title: Text(
            "@biswasbijoy414",
            style: const TextStyle(
                color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/linkedin.jpg'),
            radius: 30,
          ),
          title: Text(
            "@biswasbijoy",
            style: const TextStyle(
                color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/gmail.jpg'),
            radius: 30,
          ),
          title: Text(
            'biswasbijoy414@gmail.com',
            style: const TextStyle(
                color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/telegram.jpg'),
            radius: 30,
          ),
          title: Text(
            '@bijoy414',
            style: const TextStyle(
                color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/twitter.jpg'),
            radius: 30,
          ),
          title: Text(
            '@biswasbijoy_414',
            style: const TextStyle(
                color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/github.jpg'),
            radius: 30,
          ),
          title: Text(
            'biswasbijoy',
            style: const TextStyle(
                color: Color(0x00d4aa), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}