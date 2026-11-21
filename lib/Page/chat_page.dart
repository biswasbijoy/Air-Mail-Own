import 'dart:async';

import 'package:airmail/DesignUI/custom_card.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Model/message_model.dart';
import 'package:airmail/Screens/indivisual_page.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/services/session.dart';
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
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<MessageModel>? _messageSubscription;
  bool _loading = true;
  bool _refreshQueued = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _messageSubscription =
        RealtimeService.instance.messages.listen((_) => _scheduleRefresh());
    _loadChats(showSpinner: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _scheduleRefresh() {
    if (_refreshQueued) return;
    _refreshQueued = true;
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      _refreshQueued = false;
      if (mounted) _loadChats();
    });
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

      RealtimeService.instance.updateOnlineStatuses(chats);

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

  List<ChatModel> get _filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) {
      final name = (chat.name ?? '').toLowerCase();
      final msg = (chat.currentMessage ?? '').toLowerCase();
      return name.contains(_searchQuery) || msg.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_loading && _chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadChats(showSpinner: true),
        color: scheme.primary,
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
        color: scheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 420,
              child: EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No conversations yet',
                subtitle: 'Tap the pencil button to start your first chat on AirMail.',
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredChats;

    return RefreshIndicator(
      onRefresh: refresh,
      color: scheme.primary,
      child: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats & messages...',
                prefixIcon: Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                  borderSide: BorderSide(color: scheme.primary, width: 1.2),
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 300,
                        child: EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No results found',
                          subtitle: 'No chats match "$_searchQuery"',
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 82,
                      endIndent: 16,
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final chat = filtered[index];
                      return CustomCard(
                        chatModel: chat,
                        onTap: () => _openChat(chat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
