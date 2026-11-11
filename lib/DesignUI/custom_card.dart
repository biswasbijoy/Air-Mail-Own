import 'package:flutter/material.dart';
import '../Model/chat_model.dart';
import 'app_avatar.dart';

class CustomCard extends StatelessWidget {
  final ChatModel chatModel;
  final VoidCallback? onTap;

  const CustomCard({super.key, required this.chatModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOnline = chatModel.status == 'online';
    final icon = chatModel.icon;

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
            Text(
              chatModel.time ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
