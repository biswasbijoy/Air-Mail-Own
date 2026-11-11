import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
  });

  final ChatModel contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = contact.icon;

    return ListTile(
      onTap: onTap,
      leading: icon != null && icon.isNotEmpty
          ? CircleAvatar(radius: 25, backgroundImage: AssetImage(icon))
          : AppAvatar(name: contact.name, size: 50),
      title: Text(
        contact.name ?? 'Unknown',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        contact.email ?? contact.status ?? 'offline',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
