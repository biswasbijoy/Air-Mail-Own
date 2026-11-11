import 'package:airmail/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DeveloperScreenUI extends StatelessWidget {
  const DeveloperScreenUI({super.key});

  static const _contactItems = [
    _ContactItem(
      iconAsset: 'assets/images/call.jpg',
      label: '+8801719868313',
    ),
    _ContactItem(
      iconAsset: 'assets/images/facebook.jpg',
      label: '@biswasbijoy414',
    ),
    _ContactItem(
      iconAsset: 'assets/images/linkedin.jpg',
      label: '@biswasbijoy',
    ),
    _ContactItem(
      iconAsset: 'assets/images/gmail.jpg',
      label: 'biswasbijoy414@gmail.com',
    ),
    _ContactItem(
      iconAsset: 'assets/images/telegram.jpg',
      label: '@bijoy414',
    ),
    _ContactItem(
      iconAsset: 'assets/images/twitter.jpg',
      label: '@biswasbijoy_414',
    ),
    _ContactItem(
      iconAsset: 'assets/images/github.jpg',
      label: 'biswasbijoy',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Information'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: width * 0.15,
              backgroundImage: const AssetImage('assets/images/bijoy.jpg'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Bijoy Biswas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Flutter Developer • Data Science Intern\n'
            'Google Certified Data Analyst\n'
            'Machine Learning Enthusiast\n'
            'Competitive Programmer',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 32),
          Text(
            'Hey there, I am Bijoy Biswas, an iOS developer and Data Science '
            'intern. I love building applications, puzzles are my favourite, '
            'and I am also a competitive programmer and Machine Learning '
            'enthusiast.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 32),
          Text(
            'Contact',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._contactItems.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: AssetImage(item.iconAsset),
                radius: 24,
              ),
              title: Text(
                item.label,
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.label} is shown for contact only.'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'AirMail',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem {
  const _ContactItem({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;
}
