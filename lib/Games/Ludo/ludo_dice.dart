import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ludo_models.dart';

class LudoDice extends StatefulWidget {
  final int? value;
  final bool isRolling;
  final bool canRoll;
  final LudoPlayerColor activeColor;
  final VoidCallback onRoll;

  const LudoDice({
    super.key,
    required this.value,
    required this.isRolling,
    required this.canRoll,
    required this.activeColor,
    required this.onRoll,
  });

  @override
  State<LudoDice> createState() => _LudoDiceState();
}

class _LudoDiceState extends State<LudoDice> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(LudoDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _anim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor.color;
    final canRoll = widget.canRoll && !widget.isRolling;

    return GestureDetector(
      onTap: canRoll ? widget.onRoll : null,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final angle = _anim.value * 2 * math.pi * 2;
          final scale = 1.0 + math.sin(_anim.value * math.pi) * 0.18;

          return Transform.scale(
            scale: widget.isRolling ? scale : 1.0,
            child: Transform.rotate(
              angle: widget.isRolling ? angle : 0.0,
              child: child,
            ),
          );
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: canRoll ? color : Colors.grey.shade400,
              width: canRoll ? 3.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: canRoll
                    ? color.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: canRoll ? 14 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isRolling
                ? _buildShufflingDots()
                : _buildDiceFace(widget.value ?? 6, color),
          ),
        ),
      ),
    );
  }

  Widget _buildShufflingDots() {
    return Icon(
      Icons.casino,
      size: 40,
      color: widget.activeColor.color,
    );
  }

  Widget _buildDiceFace(int val, Color pipColor) {
    final effectiveVal = val.clamp(1, 6);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: _DiceFacePainter(value: effectiveVal, pipColor: pipColor),
        ),
      ),
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  final int value;
  final Color pipColor;

  _DiceFacePainter({required this.value, required this.pipColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pipColor
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.11;
    final left = size.width * 0.24;
    final center = size.width * 0.50;
    final right = size.width * 0.76;
    final top = size.height * 0.24;
    final middle = size.height * 0.50;
    final bottom = size.height * 0.76;

    void draw(double x, double y) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }

    switch (value) {
      case 1:
        draw(center, middle);
        break;
      case 2:
        draw(left, top);
        draw(right, bottom);
        break;
      case 3:
        draw(left, top);
        draw(center, middle);
        draw(right, bottom);
        break;
      case 4:
        draw(left, top);
        draw(right, top);
        draw(left, bottom);
        draw(right, bottom);
        break;
      case 5:
        draw(left, top);
        draw(right, top);
        draw(center, middle);
        draw(left, bottom);
        draw(right, bottom);
        break;
      case 6:
        draw(left, top);
        draw(right, top);
        draw(left, middle);
        draw(right, middle);
        draw(left, bottom);
        draw(right, bottom);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.pipColor != pipColor;
}
