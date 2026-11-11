import 'package:airmail/Games/Color_Guess/guess_color.dart';
import 'package:airmail/Games/Rock_Paper_Scissor/rock_paper_scissor.dart';
import 'package:airmail/Games/Tic_Tac_Toe/tic_tac_toe.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.all(16),
          childAspectRatio: 1,
          children: [
            _GameTile(
              icon: Icons.back_hand_outlined,
              label: 'Rock Paper Scissors',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RockPaperScissor()),
              ),
            ),
            _GameTile(
              icon: Icons.grid_3x3,
              label: 'Tic Tac Toe',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TicTacToe()),
              ),
            ),
            _GameTile(
              icon: Icons.palette_outlined,
              label: 'Color Guess',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ColorGuess()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GameTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: scheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
