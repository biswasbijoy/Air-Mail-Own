import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/profile_store.dart';

class AppAvatar extends StatelessWidget {
  final String? name;
  final String? userId;
  final String? avatar;
  final double size;
  final bool? online; // null = hide the dot

  const AppAvatar({
    super.key,
    this.name,
    this.userId,
    this.avatar,
    this.size = 52,
    this.online,
  });

  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Blue
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Purple
    [Color(0xFFEC4899), Color(0xFFBE185D)], // Pink
    [Color(0xFF10B981), Color(0xFF047857)], // Emerald
    [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
    [Color(0xFF06B6D4), Color(0xFF0E7490)], // Cyan
    [Color(0xFF6366F1), Color(0xFF4338CA)], // Indigo
    [Color(0xFFF97316), Color(0xFFC2410C)], // Orange
    [Color(0xFF14B8A6), Color(0xFF0F766E)], // Teal
  ];

  List<Color> _gradientFor(String str) {
    if (str.isEmpty) return _avatarGradients[0];
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = (hash * 31 + str.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return _avatarGradients[hash % _avatarGradients.length];
  }

  Widget _buildFallback(String initial, List<Color> gradient) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.28),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildImageAvatar(String raw, String initial, List<Color> gradient) {
    try {
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        return ClipOval(
          child: Image.network(
            raw,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallback(initial, gradient),
          ),
        );
      }

      if (raw.startsWith('asset:')) {
        final path = raw.substring(6);
        return ClipOval(
          child: Image.asset(
            path,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallback(initial, gradient),
          ),
        );
      }

      String base64Data = raw;
      if (raw.contains(',')) {
        base64Data = raw.split(',').last;
      }
      final bytes = base64Decode(base64Data);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallback(initial, gradient),
          ),
        ),
      );
    } catch (_) {
      return _buildFallback(initial, gradient);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = (name ?? '').trim();
    final initial = n.isEmpty ? '?' : n[0].toUpperCase();
    final dot = size * 0.28;
    final gradient = _gradientFor(n);

    return ListenableBuilder(
      listenable: ProfileStore.instance,
      builder: (context, _) {
        final storedAvatar = avatar ?? ProfileStore.instance.getAvatar(userId);

        final Widget avatarContent = (storedAvatar != null && storedAvatar.isNotEmpty)
            ? _buildImageAvatar(storedAvatar, initial, gradient)
            : _buildFallback(initial, gradient);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              avatarContent,
              if (online != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: dot,
                    height: dot,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: online!
                          ? const Color(0xFF10B981)
                          : scheme.outline.withValues(alpha: 0.5),
                      border: Border.all(color: scheme.surface, width: 2.2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
