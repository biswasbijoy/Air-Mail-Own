import 'package:airmail/Model/chat_model.dart';
import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  const ButtonCard({Key? key, required this.name, required this.icon})
      : super(key: key);
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        child: Icon(
          icon,
          size: 35,
          color: Colors.white,
        ),
        backgroundColor: Colors.purpleAccent,
      ),
      title: Text(
        name,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
