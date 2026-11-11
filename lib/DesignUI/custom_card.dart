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
    final icon = chatModel.icon;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: RealtimeService.instance.onlineUsers,
      builder: (context, _, __) {
        final isOnline = RealtimeService.instance.effectiveOnline(
          chatModel.id,
          fallback: chatModel.status == 'online',
        );
        final scheme = Theme.of(context).colorScheme;
        final unreadCount = chatModel.unreadCount;

        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null && icon.isNotEmpty)
                  CircleAvatar(radius: 26, backgroundImage: AssetImage(icon))
                else
                  AppAvatar(name: chatModel.name, size: 52, online: isOnline),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chatModel.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chatModel.currentMessage ?? 'Start the conversation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chatModel.time ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
