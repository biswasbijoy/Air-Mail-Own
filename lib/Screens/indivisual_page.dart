import 'dart:async';

import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/DesignUI/message_bubble.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Model/message_model.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/call_service.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/services/session.dart';
import 'package:airmail/services/settings_service.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:airmail/utils/time_format.dart';
import 'package:flutter/material.dart';

class IndivisualPage extends StatefulWidget {
  const IndivisualPage({
    super.key,
    required this.chatModel,
    required this.session,
  });

  final ChatModel chatModel;
  final Session session;

  @override
  State<IndivisualPage> createState() => _IndivisualPageState();
}

class _IndivisualPageState extends State<IndivisualPage> {
  final TextEditingController _controller = TextEditingController();
  final List<MessageModel> _messages = [];
  StreamSubscription<MessageModel>? _messageSubscription;
  Timer? _typingTimer;

  bool _loading = true;
  bool _sending = false;
  bool _startingCall = false;
  bool _typingSent = false;
  String? _error;

  String? get _otherUserId => widget.chatModel.id;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
    _messageSubscription =
        RealtimeService.instance.messages.listen(_handleIncomingMessage);
    _loadMessages();
  }

  @override
  void dispose() {
    _stopTyping();
    _messageSubscription?.cancel();
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final otherId = _otherUserId;
    if (otherId == null) return;

    if (_controller.text.trim().isEmpty) {
      _stopTyping();
      return;
    }

    if (!_typingSent) {
      _typingSent = true;
      RealtimeService.instance.sendTyping(otherId, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
  }

  void _stopTyping() {
    _typingTimer?.cancel();
    _typingTimer = null;
    if (!_typingSent) return;

    _typingSent = false;
    final otherId = _otherUserId;
    if (otherId != null) {
      RealtimeService.instance.sendTyping(otherId, false);
    }
  }

  Future<void> _markConversationRead() async {
    final otherId = _otherUserId;
    if (otherId == null) return;

    try {
      await ApiService(token: widget.session.token)
          .markConversationRead(otherId);
    } catch (_) {}
  }

  Future<void> _loadMessages() async {
    final otherId = _otherUserId;
    if (otherId == null) {
      setState(() {
        _loading = false;
        _error = 'This contact is not available.';
      });
      return;
    }

    try {
      final messages =
          await ApiService(token: widget.session.token).fetchMessages(otherId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _loading = false;
        _error = null;
      });
      unawaited(_markConversationRead());
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
        _error = 'Could not load messages.';
      });
    }
  }

  void _handleIncomingMessage(MessageModel message) {
    final otherId = _otherUserId;
    if (!mounted || otherId == null) return;
    if (message.senderId != otherId && message.receiverId != otherId) return;
    if (_messages.any((item) => item.id == message.id)) return;

    setState(() => _messages.add(message));

    if (message.senderId == otherId) {
      unawaited(_markConversationRead());
    }
  }

  Future<void> _send() async {
    final otherId = _otherUserId;
    final text = _controller.text.trim();
    if (_sending || text.isEmpty || otherId == null) return;

    _stopTyping();
    setState(() => _sending = true);

    try {
      final message = await ApiService(token: widget.session.token)
          .sendMessage(receiverId: otherId, message: text);

      if (!mounted) return;
      if (!_messages.any((item) => item.id == message.id)) {
        setState(() => _messages.add(message));
      }
      _controller.clear();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send the message.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _startCall() async {
    if (_startingCall) return;
    setState(() => _startingCall = true);

    final started = await CallService.instance.startCall(widget.chatModel);

    if (!mounted) return;
    setState(() => _startingCall = false);

    if (!started) {
      final message =
          CallService.instance.lastError ?? 'Could not start the call.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load messages',
        subtitle: _error!,
        onPressed: () {
          setState(() => _loading = true);
          _loadMessages();
        },
      );
    }

    if (_messages.isEmpty) {
      return EmptyState(
        icon: Icons.waving_hand_rounded,
        title: 'Say Hello!',
        subtitle: 'Start the conversation with ${widget.chatModel.name ?? 'your contact'}.',
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - 1 - index];
        return MessageBubble(
          text: message.message,
          time: formatTimestamp(message.createdAt),
          isMine: message.senderId == widget.session.userId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 44,
        titleSpacing: 0,
        title: ValueListenableBuilder<Set<String>>(
          valueListenable: RealtimeService.instance.onlineUsers,
          builder: (context, _, __) {
            final online = RealtimeService.instance.effectiveOnline(
              _otherUserId,
              fallback: widget.chatModel.status == 'online',
            );

            return ValueListenableBuilder<Set<String>>(
              valueListenable: RealtimeService.instance.typingUsers,
              builder: (context, typing, ___) {
                final isTyping = typing.contains(_otherUserId);

                return Row(
                  children: [
                    AppAvatar(
                      name: widget.chatModel.name,
                      size: 40,
                      online: online,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatModel.name ?? 'Chat',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              if (online && !isTyping)
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                isTyping
                                    ? 'typing...'
                                    : online
                                        ? 'Active now'
                                        : 'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isTyping ? FontWeight.w600 : FontWeight.w400,
                                  color: isTyping
                                      ? scheme.primary
                                      : (online
                                          ? const Color(0xFF10B981)
                                          : scheme.onSurfaceVariant),
                                  fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Start audio call',
            icon: _startingCall
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(Icons.call_rounded, size: 20, color: scheme.primary),
                  ),
            onPressed: _startingCall ? null : _startCall,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: SettingsService.instance.enterIsSend ? 1 : 5,
                        textInputAction: SettingsService.instance.enterIsSend
                            ? TextInputAction.send
                            : TextInputAction.newline,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.5), width: 1.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _sending ? null : _send,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
