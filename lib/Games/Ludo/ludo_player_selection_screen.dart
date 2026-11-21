import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'ludo_game.dart';

class LudoPlayerSelectionScreen extends StatefulWidget {
  const LudoPlayerSelectionScreen({super.key});

  @override
  State<LudoPlayerSelectionScreen> createState() =>
      _LudoPlayerSelectionScreenState();
}

class _LudoPlayerSelectionScreenState extends State<LudoPlayerSelectionScreen> {
  int _selectedCount = 4;

  final List<_PlayerModeOption> _options = const [
    _PlayerModeOption(
      count: 2,
      title: '2 Players',
      subtitle: 'Red vs Yellow',
      description: 'Face-off duel across opposing bases for a quick match',
      colors: [Color(0xFFE53935), Color(0xFFFDD835)],
    ),
    _PlayerModeOption(
      count: 3,
      title: '3 Players',
      subtitle: 'Red, Green & Yellow',
      description: '3-way board showdown with intense competition',
      colors: [Color(0xFFE53935), Color(0xFF43A047), Color(0xFFFDD835)],
    ),
    _PlayerModeOption(
      count: 4,
      title: '4 Players',
      subtitle: 'All Colors (Classic)',
      description: 'Full chaotic multiplayer with all 4 quadrants active',
      colors: [
        Color(0xFFE53935),
        Color(0xFF43A047),
        Color(0xFFFDD835),
        Color(0xFF1E88E5),
      ],
    ),
  ];

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LudoGame(initialPlayerCount: _selectedCount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo Multiplayer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        // Header Icon & Title
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.casino_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Choose Players',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select how many players will join this local match',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Option cards
                        ..._options.map((option) {
                          final isSelected = _selectedCount == option.count;
                          return _buildOptionCard(option, isSelected, scheme, isDark);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Start button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Start Game',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    _PlayerModeOption option,
    bool isSelected,
    ColorScheme scheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? scheme.primary
              : scheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedCount = option.count),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Radio/Check indicator
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? scheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? scheme.primary : scheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? scheme.primary.withValues(alpha: 0.85)
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Color dots
                      Row(
                        children: option.colors.map((c) {
                          return Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerModeOption {
  final int count;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> colors;

  const _PlayerModeOption({
    required this.count,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.colors,
  });
}
