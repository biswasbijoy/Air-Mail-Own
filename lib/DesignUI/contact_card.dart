import 'package:airmail/DesignUI/app_avatar.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.onRemove,
    this.trailing,
  });

  final ChatModel contact;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Widget? trailing;

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

        return ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          leading: icon != null && icon.isNotEmpty
              ? CircleAvatar(radius: 26, backgroundImage: AssetImage(icon))
              : AppAvatar(
                  userId: contact.id,
                  name: contact.name,
                  size: 52,
                  online: isOnline,
                ),
          title: Text(
            contact.name ?? 'Unknown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
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
          trailing: trailing ??
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOnline
                            ? const Color(0xFF10B981)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      tooltip: 'Remove contact',
                      icon: const Icon(
                        Icons.person_remove_outlined,
                        size: 20,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: onRemove,
                    ),
                ],
              ),
        );
      },
    );
  }
}
