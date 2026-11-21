import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ludo_models.dart';

class LudoBoard extends StatefulWidget {
  final List<LudoToken> tokens;
  final Set<LudoToken> movableTokens;
  final LudoToken? movingToken;
  final ValueChanged<LudoToken> onTokenTap;

  const LudoBoard({
    super.key,
    required this.tokens,
    required this.movableTokens,
    this.movingToken,
    required this.onTokenTap,
  });

  @override
  State<LudoBoard> createState() => _LudoBoardState();
}

class _LudoBoardState extends State<LudoBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.movableTokens.isNotEmpty) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LudoBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movableTokens.isNotEmpty && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (widget.movableTokens.isEmpty && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFF37474F), width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / 15.0;

            return Stack(
              children: [
                // Base Board Grid and Colors
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _LudoBoardPainter(cellSize: cellSize),
                ),

                // Interactive Yards (for tapping when rolled a 6)
                ..._buildYardTapTargets(cellSize),

                // Tokens positioned on the board
                ..._buildTokens(cellSize),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildYardTapTargets(double cellSize) {
    final yardSize = cellSize * 6;
    final List<Widget> targets = [];

    final Map<LudoPlayerColor, Offset> origins = {
      LudoPlayerColor.red: const Offset(0, 0),
      LudoPlayerColor.green: Offset(cellSize * 9, 0),
      LudoPlayerColor.yellow: Offset(cellSize * 9, cellSize * 9),
      LudoPlayerColor.blue: Offset(0, cellSize * 9),
    };

    for (final entry in origins.entries) {
      final color = entry.key;
      final offset = entry.value;
      final colorMovableYardTokens = widget.movableTokens.where(
        (t) => t.color == color && t.isInYard,
      );

      if (colorMovableYardTokens.isNotEmpty) {
        final token = colorMovableYardTokens.first;
        targets.add(
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: yardSize,
            height: yardSize,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => widget.onTokenTap(token),
            ),
          ),
        );
      }
    }

    return targets;
  }

  List<Widget> _buildTokens(double cellSize) {
    final Map<GridPos, List<LudoToken>> grouped = {};

    for (final token in widget.tokens) {
      final pos = LudoConstants.getTokenPosition(token);
      grouped.putIfAbsent(pos, () => []).add(token);
    }

    final List<Widget> widgets = [];

    for (final entry in grouped.entries) {
      final pos = entry.key;
      final list = entry.value;

      final count = list.length;
      final left = pos.col * cellSize;
      final top = pos.row * cellSize;

      for (int i = 0; i < count; i++) {
        final token = list[i];
        final isMovable = widget.movableTokens.contains(token);

        // Compute sub-pixel offset if multiple tokens share the cell
        double dx = 0;
        double dy = 0;
        double scale = 0.88;

        if (count > 1 && !token.isInYard) {
          scale = 0.62;
          final angle = (i * 2 * math.pi) / count;
          final radius = cellSize * 0.22;
          dx = math.cos(angle) * radius;
          dy = math.sin(angle) * radius;
        }

        final tokenSize = cellSize * scale;
        final tokenLeft = left + (cellSize - tokenSize) / 2 + dx;
        final tokenTop = top + (cellSize - tokenSize) / 2 + dy;
        final isJumping = token == widget.movingToken;

        widgets.add(
          AnimatedPositioned(
            key: ValueKey('ludo_token_${token.color.name}_${token.id}'),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeInOutQuad,
            left: tokenLeft,
            top: tokenTop,
            width: tokenSize,
            height: tokenSize,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isMovable ? () => widget.onTokenTap(token) : null,
              child: _TokenWidget(
                token: token,
                isMovable: isMovable,
                isJumping: isJumping,
                glowAnimation: isMovable ? _glowAnimation : null,
                size: tokenSize,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

class _TokenWidget extends StatelessWidget {
  final LudoToken token;
  final bool isMovable;
  final bool isJumping;
  final Animation<double>? glowAnimation;
  final double size;

  const _TokenWidget({
    required this.token,
    required this.isMovable,
    this.isJumping = false,
    this.glowAnimation,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = token.color.color;
    final brightColor = token.color.brightColor;

    if (isMovable && glowAnimation != null) {
      return AnimatedBuilder(
        animation: glowAnimation!,
        builder: (context, child) {
          final t = glowAnimation!.value;
          return AnimatedScale(
            scale: isJumping ? 1.20 : (1.0 + 0.04 * t),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutBack,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.35),
                  colors: [
                    brightColor,
                    color,
                    Color.lerp(color, Colors.black, 0.35)!,
                  ],
                ),
                boxShadow: [
                  // Outer soft faded glow halo
                  BoxShadow(
                    color: brightColor.withValues(alpha: 0.12 + 0.36 * t),
                    blurRadius: 12 + 10 * t,
                    spreadRadius: 2.5 + 3.5 * t,
                  ),
                  // Inner focused glowing core
                  BoxShadow(
                    color: brightColor.withValues(alpha: 0.25 + 0.65 * t),
                    blurRadius: 6 + 6 * t,
                    spreadRadius: 1.5 + 2.0 * t,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.70 + 0.30 * t),
                  width: 2.0 + 0.8 * t,
                ),
              ),
              child: child,
            ),
          );
        },
        child: Center(
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      );
    }

    return AnimatedScale(
      scale: isJumping ? 1.20 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.35),
            colors: [
              brightColor,
              color,
              Color.lerp(color, Colors.black, 0.35)!,
            ],
          ),
          boxShadow: [
            if (isJumping)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
                spreadRadius: 2.5,
                offset: const Offset(0, 5),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color: isJumping ? Colors.white : Colors.white.withValues(alpha: 0.85),
            width: isJumping ? 2.4 : 1.4,
          ),
        ),
        child: Center(
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}

class _LudoBoardPainter extends CustomPainter {
  final double cellSize;

  _LudoBoardPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 1. Draw 4 Corner Yards (6x6 cells each)
    _drawYard(canvas, 0, 0, LudoPlayerColor.red);
    _drawYard(canvas, 9 * cellSize, 0, LudoPlayerColor.green);
    _drawYard(canvas, 9 * cellSize, 9 * cellSize, LudoPlayerColor.yellow);
    _drawYard(canvas, 0, 9 * cellSize, LudoPlayerColor.blue);

    // 2. Draw Grid Lines on Arms
    _drawGridLines(canvas, size);

    // 3. Draw Home Paths (colored runway columns)
    _drawHomeRunways(canvas);

    // 4. Draw Starting Positions (colored start boxes with arrows)
    _drawStartCells(canvas);

    // 5. Draw Classic Safe Star spots
    _drawSafeStars(canvas);

    // 6. Draw Center Home Triangles (3x3 center)
    _drawCenterHome(canvas);
  }

  void _drawYard(Canvas canvas, double left, double top, LudoPlayerColor color) {
    final yardSize = cellSize * 6;
    final yardRect = Rect.fromLTWH(left, top, yardSize, yardSize);

    final fillPaint = Paint()..color = color.color;
    canvas.drawRect(yardRect, fillPaint);

    // Inner White Base
    final innerMargin = cellSize * 0.85;
    final innerRect = Rect.fromLTWH(
      left + innerMargin,
      top + innerMargin,
      yardSize - innerMargin * 2,
      yardSize - innerMargin * 2,
    );
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.6)),
      innerPaint,
    );

    // 4 Circular Slots for Tokens
    final slotRadius = cellSize * 0.75;
    for (final slot in color.yardSlots) {
      final cx = slot.col * cellSize + cellSize / 2;
      final cy = slot.row * cellSize + cellSize / 2;

      final slotPaint = Paint()
        ..color = color.containerColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), slotRadius, slotPaint);

      final slotBorder = Paint()
        ..color = color.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(cx, cy), slotRadius, slotBorder);
    }

    // Border around yard
    final borderPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(yardRect, borderPaint);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw arm cells
    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        // Skip yards and center
        final inTopLeftYard = r < 6 && c < 6;
        final inTopRightYard = r < 6 && c >= 9;
        final inBottomLeftYard = r >= 9 && c < 6;
        final inBottomRightYard = r >= 9 && c >= 9;
        final inCenter = r >= 6 && r <= 8 && c >= 6 && c <= 8;

        if (!inTopLeftYard && !inTopRightYard && !inBottomLeftYard && !inBottomRightYard && !inCenter) {
          final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
          canvas.drawRect(rect, linePaint);
        }
      }
    }
  }

  void _drawHomeRunways(Canvas canvas) {
    for (final entry in LudoConstants.homePaths.entries) {
      final color = entry.key;
      final pathList = entry.value;
      final paint = Paint()..color = color.color;

      for (final pos in pathList) {
        final rect = Rect.fromLTWH(pos.col * cellSize, pos.row * cellSize, cellSize, cellSize);
        canvas.drawRect(rect, paint);

        final border = Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRect(rect, border);
      }
    }
  }

  void _drawStartCells(Canvas canvas) {
    final starts = {
      LudoPlayerColor.red: const GridPos(6, 1),
      LudoPlayerColor.green: const GridPos(1, 8),
      LudoPlayerColor.yellow: const GridPos(8, 13),
      LudoPlayerColor.blue: const GridPos(13, 6),
    };

    for (final entry in starts.entries) {
      final color = entry.key;
      final pos = entry.value;
      final rect = Rect.fromLTWH(pos.col * cellSize, pos.row * cellSize, cellSize, cellSize);
      final paint = Paint()..color = color.color;
      canvas.drawRect(rect, paint);
    }
  }

  void _drawSafeStars(Canvas canvas) {
    for (final pos in LudoConstants.safePositions) {
      final cx = pos.col * cellSize + cellSize / 2;
      final cy = pos.row * cellSize + cellSize / 2;
      _drawStar(canvas, cx, cy, cellSize * 0.34, Colors.white.withValues(alpha: 0.95));
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const int points = 5;
    const double step = math.pi / points;

    for (int i = 0; i < 2 * points; i++) {
      final r = (i.isEven) ? radius : radius * 0.45;
      final angle = i * step - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final border = Paint()
      ..color = const Color(0xFF263238).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, border);
  }

  void _drawCenterHome(Canvas canvas) {
    final centerLeft = 6 * cellSize;
    final centerTop = 6 * cellSize;
    final centerSize = 3 * cellSize;
    final cx = centerLeft + centerSize / 2;
    final cy = centerTop + centerSize / 2;

    // Red triangle (Left)
    final redPath = Path()
      ..moveTo(centerLeft, centerTop)
      ..lineTo(centerLeft, centerTop + centerSize)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(redPath, Paint()..color = LudoPlayerColor.red.color);

    // Green triangle (Top)
    final greenPath = Path()
      ..moveTo(centerLeft, centerTop)
      ..lineTo(centerLeft + centerSize, centerTop)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = LudoPlayerColor.green.color);

    // Yellow triangle (Right)
    final yellowPath = Path()
      ..moveTo(centerLeft + centerSize, centerTop)
      ..lineTo(centerLeft + centerSize, centerTop + centerSize)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = LudoPlayerColor.yellow.color);

    // Blue triangle (Bottom)
    final bluePath = Path()
      ..moveTo(centerLeft, centerTop + centerSize)
      ..lineTo(centerLeft + centerSize, centerTop + centerSize)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = LudoPlayerColor.blue.color);

    // Center Golden Circle & Trophy
    final centerBadgeRadius = cellSize * 0.72;
    canvas.drawCircle(
      Offset(cx, cy),
      centerBadgeRadius,
      Paint()..color = const Color(0xFFFFD700),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      centerBadgeRadius,
      Paint()
        ..color = const Color(0xFFB78103)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Outline around center
    final border = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(Rect.fromLTWH(centerLeft, centerTop, centerSize, centerSize), border);
  }

  @override
  bool shouldRepaint(covariant _LudoBoardPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize;
}
