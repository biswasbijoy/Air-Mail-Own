import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
  });

  final ChatModel contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = contact.icon;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: RealtimeService.instance.onlineUsers,
      builder: (context, _, __) {
        final isOnline = RealtimeService.instance.effectiveOnline(
          contact.id,
          fallback: contact.status == 'online',
        );
        final scheme = Theme.of(context).colorScheme;
        final onlineColor = Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkOnline
            : AppColors.lightOnline;

        return ListTile(
          onTap: onTap,
          leading: icon != null && icon.isNotEmpty
              ? CircleAvatar(radius: 25, backgroundImage: AssetImage(icon))
              : AppAvatar(name: contact.name, size: 50, online: isOnline),
          title: Text(
            contact.name ?? 'Unknown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          subtitle: Text(
            contact.email ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
          trailing: Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOnline ? onlineColor : scheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
