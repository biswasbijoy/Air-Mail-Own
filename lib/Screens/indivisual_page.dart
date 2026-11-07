import 'package:airmail/DesignUI/message_bubble.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class IndivisualPage extends StatefulWidget {
  final ChatModel chatModel;
  final String userId;

  const IndivisualPage({
    Key? key,
    required this.chatModel,
    required this.userId,
  }) : super(key: key);

  @override
  State<IndivisualPage> createState() => _IndivisualPageState();
}

class _IndivisualPageState extends State<IndivisualPage> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String? _lastDate;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': 'Hi! How are you?',
      'isMine': true,
      'time': '2:30 PM',
    });
    _messages.add({
      'text': 'I\'m doing well, thanks!',
      'isMine': false,
      'time': '2:31 PM',
    });
    _lastDate = null;
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text;
    setState(() {
      _messages.add({
        'text': text,
        'isMine': true,
        'time': 'Today',
      });
    });
    _controller.clear();
  }

  String _getDateLabel(String time) {
    final now = DateTime.now();
    final messageDate = DateTime.parse('2024-01-01');
    final today = now.difference(messageDate).inDays == 0 ? 'Today' : 'Yesterday';
    return today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        title: Row(
          children: [
            AppAvatar(
              size: 38,
              online: widget.chatModel.status == 'online',
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatModel.name ?? 'Chat',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  widget.chatModel.status == 'online'
                      ? 'Online'
                      : 'Offline',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'Settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'Log out',
                child: Text('Log out'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isToday = _getDateLabel(message['time']!) == 'Today';
                final dateWidget = today
                    ? null
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        color: AppColors.darkRaised,
                        borderRadius: BorderRadius.circular(12),
                        child: const Text(
                          'Yesterday',
                          style: TextStyle(fontSize: 12, color: AppColors.darkMuted),
                        ),
                      );

                return MessageBubble(
                  text: message['text']!,
                  time: message['time']!,
                  isMine: message['isMine'] as bool,
                );
              },
            ),
          ),
          if (_messages.isEmpty)
            const EmptyState(
              icon: Icons.waving_hand_outlined,
              title: 'Say hi',
              subtitle: 'Send the first message.',
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}