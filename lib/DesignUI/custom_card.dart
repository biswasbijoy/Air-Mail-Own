import 'package:flutter/material.dart';
import '../Model/chat_model.dart';
import '../services/realtime_service.dart';
import 'app_avatar.dart';

class CustomCard extends StatelessWidget {
  final ChatModel chatModel;
  final VoidCallback? onTap;

  const CustomCard({super.key, required this.chatModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unreadCount = chatModel.unreadCount;
    final icon = chatModel.icon;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: RealtimeService.instance.onlineUsers,
      builder: (context, _, __) {
        final isOnline = RealtimeService.instance.effectiveOnline(
          chatModel.id,
          fallback: chatModel.status == 'online',
        );

        return ValueListenableBuilder<Set<String>>(
          valueListenable: RealtimeService.instance.typingUsers,
          builder: (context, typing, ___) {
            final isTyping = typing.contains(chatModel.id);

            return InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null && icon.isNotEmpty)
                      CircleAvatar(
                        radius: 27,
                        backgroundImage: AssetImage(icon),
                      )
                    else
                      AppAvatar(
                        userId: chatModel.id,
                        name: chatModel.name,
                        size: 54,
                        online: isOnline,
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chatModel.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              letterSpacing: -0.2,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTyping
                                ? 'typing...'
                                : (chatModel.currentMessage ??
                                    'Start the conversation'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isTyping
                                  ? FontWeight.w600
                                  : (unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.w400),
                              fontStyle: isTyping
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: isTyping
                                  ? scheme.primary
                                  : (unreadCount > 0
                                      ? scheme.onSurface
                                      : scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chatModel.time ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: unreadCount > 0
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(height: 5),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: scheme.onPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ] else
                          const SizedBox(height: 18),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
