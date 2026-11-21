import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? name;
  final double size;
  final bool? online; // null = hide the dot

  const AppAvatar({super.key, this.name, this.size = 52, this.online});

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = (name ?? '').trim();
    final initial = n.isEmpty ? '?' : n[0].toUpperCase();
    final dot = size * 0.28;
    final gradient = _gradientFor(n);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
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
          ),
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
  }
}
