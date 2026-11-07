import 'package:flutter/material.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/indivisual_page.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(
      {Key? key, required this.chatModel, required this.sourceChat})
      : super(key: key);
  final ChatModel chatModel;
  final ChatModel sourceChat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndivisualPage(
              chatModel: chatModel,
              sourceChat: sourceChat,
            ),
          ),
        );
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(chatModel.icon ?? 'assets/images/default_avatar.png'),
            ),
            title: Text(
              chatModel.name ?? 'Unknown',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.done_all, color: Theme.of(context).colorScheme.primary, size: 16),
                Text(
                  chatModel.currentMessage ?? '',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            trailing: Text(
              chatModel.time ?? '',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}