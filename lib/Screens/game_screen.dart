import 'package:flutter/material.dart';
import 'package:airmail/theme/app_colors.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
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
                color: AppColors.primary,
              ),
              _GameTile(
                icon: Icons.grid_3x3,
                label: 'Tic Tac Toe',
                color: AppColors.primary,
              ),
              _GameTile(
                icon: Icons.palette_outlined,
                label: 'Color Guess',
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _GameTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: AppColors.onPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}