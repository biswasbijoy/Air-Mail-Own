import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isMine ? AppColors.primary : scheme.surfaceContainerHighest;
    final fg = isMine ? AppColors.onPrimary : scheme.onSurface;
    final timeColor = isMine
        ? AppColors.onPrimary.withValues(alpha: 0.7)
        : scheme.onSurfaceVariant;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: TextStyle(fontSize: 15, color: fg, height: 1.3)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 11, color: timeColor)),
          ],
        ),
      ),
    );
  }
}
