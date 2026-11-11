import 'package:flutter/material.dart';
import 'package:airmail/theme/app_colors.dart';

class UserSideCard extends StatelessWidget {
  const UserSideCard({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
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
        const Text(
          "Flutter Developer || Data Science Intern\nGoogle Certified Data Analyst\nMachine Learning Enthusiast\nCompetitive Programmer",
          style: TextStyle(
              color: AppColors.darkMuted,
              fontSize: 16,
              fontWeight: FontWeight.w100),
          textAlign: TextAlign.center,
        ),
        const Divider(
          height: 20,
          color: Color(0x33ffffff),
          thickness: 2,
        ),
        const Text(
          "Hey there, I am Bijoy Biswas, iOS developer and Data Science intern. I love developing amazing applications, puzzles are my favourite! I am also a competitive programmer and a Machine Learning enthusiast. I am also a Google Certified Data Analyst.",
          style: TextStyle(
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
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/call.jpg'),
            radius: 30,
          ),
          title: const Text(
            "+8801719868313",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/facebook.jpg'),
            radius: 30,
          ),
          title: const Text(
            "@biswasbijoy414",
            style: TextStyle(
                color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/linkedin.jpg'),
            radius: 30,
          ),
          title: const Text(
            "@biswasbijoy",
            style: TextStyle(
                color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/gmail.jpg'),
            radius: 30,
          ),
          title: const Text(
            'biswasbijoy414@gmail.com',
            style: TextStyle(
                color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/telegram.jpg'),
            radius: 30,
          ),
          title: const Text(
            '@bijoy414',
            style: TextStyle(
                color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        ListTile(
          onTap: () {},
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/github.jpg'),
            radius: 30,
          ),
          title: const Text(
            'biswasbijoy',
            style: TextStyle(
                color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}