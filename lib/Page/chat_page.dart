import 'package:airmail/DesignUI/custom_card.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/select_contact_page.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.chatmodels, required this.sourceChat})
      : super(key: key);
  final List<ChatModel> chatmodels;
  final ChatModel sourceChat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    // ChatModel sourceChat = chatmodels.removeAt(0);
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: ListView.builder(
        itemCount: widget.chatmodels.length,
        itemBuilder: (context, index) => CustomCard(
          chatModel: widget.chatmodels[index],
          sourceChat: widget.sourceChat,
        ),
      ),
    );
  }
}
