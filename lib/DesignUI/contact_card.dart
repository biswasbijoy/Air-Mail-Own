import 'package:airmail/Model/chat_model.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({Key? key, required this.contact}) : super(key: key);
  final ChatModel contact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(contact.icon),
        ),
        title: Text(
          contact.name,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          contact.status,
          style: TextStyle(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }
}
