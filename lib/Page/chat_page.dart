import 'dart:async';

import 'package:airmail/DesignUI/custom_card.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/Model/call_record_model.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Model/message_model.dart';
import 'package:airmail/Screens/indivisual_page.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/call_history_store.dart';
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
  StreamSubscription<CallRecordModel>? _callSubscription;
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
        RealtimeService.instance.messages.listen(_handleRealtimeMessage);
    _callSubscription =
        RealtimeService.instance.callHistory.listen(_handleRealtimeCall);
    _loadChats(showSpinner: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageSubscription?.cancel();
    _callSubscription?.cancel();
    super.dispose();
  }

  void _handleRealtimeMessage(MessageModel message) {
    final otherId = message.senderId == widget.session.userId
        ? message.receiverId
        : message.senderId;

    final existingIndex = _chats.indexWhere((c) => c.id == otherId);
    if (existingIndex != -1) {
      final chat = _chats[existingIndex];
      chat.currentMessage = message.message;
      chat.lastMessageAt = message.createdAt;
      chat.time = formatTimestamp(message.createdAt);
      if (message.senderId == otherId) {
        chat.unreadCount = (chat.unreadCount ?? 0) + 1;
      }
      _chats.removeAt(existingIndex);
      _chats.insert(0, chat);
      if (mounted) setState(() {});
    } else {
      _scheduleRefresh();
    }
  }

  void _handleRealtimeCall(CallRecordModel record) {
    final otherId = record.peer.id;
    if (otherId == null) return;

    final summary = _formatCallSummary(record);
    final existingIndex = _chats.indexWhere(
      (c) => c.id == otherId || (c.email != null && c.email == record.peer.email),
    );

    if (existingIndex != -1) {
      final chat = _chats[existingIndex];
      chat.currentMessage = summary;
      chat.lastMessageAt = record.createdAt;
      chat.time = formatTimestamp(record.createdAt);
      _chats.removeAt(existingIndex);
      _chats.insert(0, chat);
      if (mounted) setState(() {});
    } else {
      final newChat = ChatModel(
        id: record.peer.id,
        name: record.peer.name,
        email: record.peer.email,
        avatar: record.peer.avatar,
        currentMessage: summary,
        lastMessageAt: record.createdAt,
        time: formatTimestamp(record.createdAt),
      );
      _chats.insert(0, newChat);
      if (mounted) setState(() {});
    }
  }

  String _formatCallSummary(CallRecordModel record) {
    final isOutgoing = record.direction == CallDirection.outgoing;
    final isMissed = record.status == CallStatus.missed;
    final isDeclined = record.status == CallStatus.declined;
    final isCancelled = record.status == CallStatus.cancelled;

    if (isMissed) {
      return isOutgoing ? '📞 Cancelled call' : '📞 Missed audio call';
    } else if (isDeclined) {
      return '📞 Declined call';
    } else if (isCancelled) {
      return '📞 Cancelled call';
    } else {
      return record.duration > 0
          ? '📞 Audio call (${_formatDuration(record.duration)})'
          : '📞 Audio call';
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}m ${s}s' : '${m}m';
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
      final cachedCalls = await CallHistoryStore.load(widget.session.userId);
      if (!mounted) return;

      final Map<String, CallRecordModel> latestCalls = {};
      for (final call in cachedCalls) {
        final key = call.peer.id ?? call.peer.email;
        if (key == null || key.isEmpty) continue;
        final existing = latestCalls[key];
        if (existing == null || call.createdAt.isAfter(existing.createdAt)) {
          latestCalls[key] = call;
        }
      }

      final existingChatKeys = <String>{};
      for (final chat in chats) {
        final idKey = chat.id;
        final emailKey = chat.email;
        if (idKey != null) existingChatKeys.add(idKey);
        if (emailKey != null) existingChatKeys.add(emailKey);

        final call = (idKey != null ? latestCalls[idKey] : null) ??
            (emailKey != null ? latestCalls[emailKey] : null);

        if (call != null) {
          final msgTime = chat.lastMessageAt;
          if (msgTime == null || call.createdAt.isAfter(msgTime)) {
            chat.currentMessage = _formatCallSummary(call);
            chat.lastMessageAt = call.createdAt;
          }
        }
      }

      for (final entry in latestCalls.entries) {
        if (!existingChatKeys.contains(entry.key)) {
          final call = entry.value;
          chats.add(ChatModel(
            id: call.peer.id,
            name: call.peer.name,
            email: call.peer.email,
            avatar: call.peer.avatar,
            currentMessage: _formatCallSummary(call),
            lastMessageAt: call.createdAt,
          ));
          existingChatKeys.add(entry.key);
        }
      }

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
