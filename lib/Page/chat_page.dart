import 'package:airmail/DesignUI/custom_card.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/select_contact_page.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final List<ChatModel> chatmodels;
  final ChatModel sourceChat;

  const ChatPage({
    Key? key,
    required this.chatmodels,
    required this.sourceChat,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    // Sort chats so newest message is first
    final sortedChats = List.of(widget.chatmodels)
        ..sort((a, b) => (b.time ?? '').compareTo(a.time ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
builder: (context) => SelectContact(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh logic would go here
        },
        color: AppColors.primary,
        child: sortedChats.isEmpty
            ? EmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No chats yet',
                subtitle: 'Tap the pencil to start a conversation.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: sortedChats.length,
                itemBuilder: (context, index) {
                  return CustomCard(
                    chatModel: sortedChats[index],
                    onTap: () {
                      // Navigate to individual chat
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectContact(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}