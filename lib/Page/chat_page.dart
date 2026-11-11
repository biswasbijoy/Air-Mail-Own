import 'package:airmail/DesignUI/custom_card.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/indivisual_page.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/session.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:airmail/utils/time_format.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.session,
  });

  final Session session;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final List<ChatModel> _chats = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats(showSpinner: true);
  }

  Future<void> refresh() => _loadChats();

  Future<void> _loadChats({bool showSpinner = false}) async {
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final chats = await ApiService(token: widget.session.token).fetchChats();
      if (!mounted) return;

      chats.sort((a, b) {
        final aTime = a.lastMessageAt;
        final bTime = b.lastMessageAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      for (final chat in chats) {
        chat.time = formatTimestamp(chat.lastMessageAt);
      }

      setState(() {
        _chats
          ..clear()
          ..addAll(chats);
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load conversations.';
      });
    }
  }

  Future<void> _openChat(ChatModel chat) async {
    if (chat.id == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndivisualPage(
          chatModel: chat,
          session: widget.session,
        ),
      ),
    );
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadChats(showSpinner: true),
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 420,
              child: EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load chats',
                subtitle: _error!,
                onPressed: () => _loadChats(showSpinner: true),
              ),
            ),
          ],
        ),
      );
    }

    if (_chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 420,
              child: EmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No chats yet',
                subtitle: 'Tap the pencil button to start a conversation.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return CustomCard(
            chatModel: chat,
            onTap: () => _openChat(chat),
          );
        },
      ),
    );
  }
}
