import 'dart:math';

import 'package:flutter/material.dart';

class ColorGuess extends StatefulWidget {
  const ColorGuess({super.key});

  @override
  State<ColorGuess> createState() => _ColorGuessState();
}

class _ColorGuessState extends State<ColorGuess> {
  static const _colors = <String, Color>{
    'Red': Color(0xFFE53935),
    'Green': Color(0xFF43A047),
    'Blue': Color(0xFF1E88E5),
    'Purple': Color(0xFF8E24AA),
    'Orange': Color(0xFFFB8C00),
  };

  final Random _random = Random();

  late String _targetName;
  late Color _targetColor;
  String? _message;
  int _score = 0;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _pickColor();
  }

  void _pickColor() {
    final names = _colors.keys.toList();
    _targetName = names[_random.nextInt(names.length)];
    _targetColor = _colors[_targetName]!;
    _message = null;
  }

  void _guess(String name) {
    setState(() {
      _attempts += 1;
      if (name == _targetName) {
        _score += 1;
        _message = 'Correct! It was $_targetName.';
        _pickColor();
      } else {
        _message = 'Not quite. Try again.';
      }
    });
  }

  void _next() {
    setState(_pickColor);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final options = _colors.keys.toList()..shuffle(_random);

    return Scaffold(
      appBar: AppBar(title: const Text('Guess the Color')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Text(
                  'Which color is shown below?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: _targetColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _message ?? 'Score: $_score / $_attempts',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: options.map((name) {
                    return FilledButton.tonal(
                      onPressed: () => _guess(name),
                      child: Text(name),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Skip color'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: use the color names to learn them.',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
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
