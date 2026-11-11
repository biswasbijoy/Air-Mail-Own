import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/DesignUI/empty_state.dart';
import 'package:airmail/DesignUI/message_bubble.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Model/message_model.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/session.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:airmail/utils/time_format.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
  io.Socket? _socket;

  bool _loading = true;
  bool _sending = false;
  String? _error;

  String? get _otherUserId => widget.chatModel.id;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectSocket();
  }

  @override
  void dispose() {
    _socket?.dispose();
    _controller.dispose();
    super.dispose();
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

  void _connectSocket() {
    final socket = io.io(
      ApiService.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': widget.session.token})
          .build(),
    );

    socket.on('new_message', (data) {
      if (!mounted || data is! Map) return;

      final message = MessageModel.fromJson(Map<String, dynamic>.from(data));
      final otherId = _otherUserId;
      if (message.senderId != otherId && message.receiverId != otherId) return;
      if (_messages.any((item) => item.id == message.id)) return;

      setState(() => _messages.add(message));
    });
    socket.onConnectError((_) {});
    socket.onError((_) {});

    _socket = socket;
    socket.connect();
  }

  Future<void> _send() async {
    final otherId = _otherUserId;
    final text = _controller.text.trim();
    if (_sending || text.isEmpty || otherId == null) return;

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
      return const EmptyState(
        icon: Icons.waving_hand_outlined,
        title: 'Say hi',
        subtitle: 'Send the first message to start the conversation.',
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
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
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        title: Row(
          children: [
            AppAvatar(
              name: widget.chatModel.name,
              size: 38,
              online: widget.chatModel.status == 'online',
            ),
            const SizedBox(width: 10),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.chatModel.status == 'online' ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Call',
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling is not available yet.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          SafeArea(
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
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
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
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
