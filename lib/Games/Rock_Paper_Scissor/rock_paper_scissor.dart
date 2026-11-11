import 'dart:math';

import 'package:airmail/Games/Rock_Paper_Scissor/how_to_play.dart';
import 'package:flutter/material.dart';

class RockPaperScissor extends StatefulWidget {
  const RockPaperScissor({super.key});

  @override
  State<RockPaperScissor> createState() => _RockPaperScissorState();
}

class _RockPaperScissorState extends State<RockPaperScissor> {
  static const _choices = ['Rock', 'Paper', 'Scissors'];
  static const _icons = {
    'Rock': Icons.back_hand_outlined,
    'Paper': Icons.description_outlined,
    'Scissors': Icons.content_cut,
  };

  final Random _random = Random();

  String? _playerChoice;
  String? _computerChoice;
  String _result = 'Choose an option to begin';
  int _playerScore = 0;
  int _computerScore = 0;

  void _play(String playerChoice) {
    final computerChoice = _choices[_random.nextInt(_choices.length)];
    final playerIndex = _choices.indexOf(playerChoice);
    final computerIndex = _choices.indexOf(computerChoice);
    final difference = (playerIndex - computerIndex + 3) % 3;

    setState(() {
      _playerChoice = playerChoice;
      _computerChoice = computerChoice;

      if (difference == 0) {
        _result = "It's a draw!";
      } else if (difference == 1) {
        _playerScore += 1;
        _result = 'You win!';
      } else {
        _computerScore += 1;
        _result = 'Computer wins!';
      }
    });
  }

  void _reset() {
    setState(() {
      _playerChoice = null;
      _computerChoice = null;
      _result = 'Choose an option to begin';
      _playerScore = 0;
      _computerScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HowToPlay()),
            ),
            child: const Text('Rules'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ScoreCard(
                        label: 'You',
                        score: _playerScore,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ScoreCard(
                        label: 'Computer',
                        score: _computerScore,
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _result,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ChoiceDisplay(
                      label: 'You',
                      choice: _playerChoice,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'vs',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    _ChoiceDisplay(
                      label: 'Computer',
                      choice: _computerChoice,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: _choices.map((choice) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilledButton.tonalIcon(
                          onPressed: () => _play(choice),
                          icon: Icon(_icons[choice]),
                          label: Text(choice),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset score'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceDisplay extends StatelessWidget {
  const _ChoiceDisplay({required this.label, required this.choice});

  final String label;
  final String? choice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = choice == null
        ? Icons.help_outline
        : _RockPaperScissorState._icons[choice];

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 42, color: scheme.primary),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          choice ?? '—',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
