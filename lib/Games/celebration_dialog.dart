import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final Color primaryColor;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const CelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryColor = const Color(0xFFF59E0B),
    required this.onPlayAgain,
    required this.onExit,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    Color primaryColor = const Color(0xFFF59E0B),
    required VoidCallback onPlayAgain,
    required VoidCallback onExit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CelebrationDialog(
        title: title,
        message: message,
        primaryColor: primaryColor,
        onPlayAgain: onPlayAgain,
        onExit: onExit,
      ),
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Generate confetti particles
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      Colors.amber,
    ];

    for (int i = 0; i < 60; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _rng.nextDouble(),
          y: -_rng.nextDouble(),
          speed: 0.15 + _rng.nextDouble() * 0.45,
          size: 5 + _rng.nextDouble() * 7,
          color: colors[_rng.nextInt(colors.length)],
          rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
          wobbleSpeed: 2 + _rng.nextDouble() * 4,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Confetti Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),

          // Main Card
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Trophy
                _TrophyWidget(color: widget.primaryColor),
                const SizedBox(height: 18),

                // Victory Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle / message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: scheme.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        onPressed: widget.onExit,
                        child: const Text('Exit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: widget.onPlayAgain,
                        child: const Text('Play Again'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyWidget extends StatefulWidget {
  final Color color;
  const _TrophyWidget({required this.color});

  @override
  State<_TrophyWidget> createState() => _TrophyWidgetState();
}

class _TrophyWidgetState extends State<_TrophyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.color.withValues(alpha: 0.35),
              widget.color.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.emoji_events_rounded,
            size: 52,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final double wobbleSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.wobbleSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentY = ((p.y + progress * p.speed * 3) % 1.4) * size.height - (0.2 * size.height);
      final wobble = sin(progress * pi * 2 * p.wobbleSpeed) * 12;
      final currentX = p.x * size.width + wobble;

      paint.color = p.color;
      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(progress * pi * 2 * p.rotationSpeed);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
