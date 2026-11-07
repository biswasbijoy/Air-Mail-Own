import 'package:flutter/material.dart';
import 'package:airmail/Model/chat_model.dart';

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
          backgroundImage: AssetImage(contact.icon ?? 'assets/images/default_avatar.png'),
        ),
        title: Text(
          contact.name ?? 'Unknown',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: Text(
          contact.status ?? 'offline',
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}