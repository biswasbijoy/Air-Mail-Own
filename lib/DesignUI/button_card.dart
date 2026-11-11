import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  const ButtonCard({super.key, required this.name, required this.icon});
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          icon,
          size: 35,
          color: Colors.black,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}