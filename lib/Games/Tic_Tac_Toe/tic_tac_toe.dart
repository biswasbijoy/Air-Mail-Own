import 'package:flutter/material.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  static const _winningLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;
  bool _isDraw = false;
  int _xWins = 0;
  int _oWins = 0;

  void _handleTap(int index) {
    if (_board[index].isNotEmpty || _winner != null || _isDraw) return;

    setState(() {
      _board[index] = _currentPlayer;
      final winner = _checkWinner();

      if (winner != null) {
        _winner = winner;
        if (winner == 'X') {
          _xWins += 1;
        } else {
          _oWins += 1;
        }
      } else if (_board.every((cell) => cell.isNotEmpty)) {
        _isDraw = true;
      } else {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  String? _checkWinner() {
    for (final line in _winningLines) {
      final a = _board[line[0]];
      final b = _board[line[1]];
      final c = _board[line[2]];
      if (a.isNotEmpty && a == b && b == c) return a;
    }
    return null;
  }

  void _reset({bool resetScore = false}) {
    setState(() {
      for (var i = 0; i < _board.length; i++) {
        _board[i] = '';
      }
      _winner = null;
      _isDraw = false;
      _currentPlayer = 'X';
      if (resetScore) {
        _xWins = 0;
        _oWins = 0;
      }
    });
  }

  String get _status {
    if (_winner != null) return '$_winner wins!';
    if (_isDraw) return "It's a draw!";
    return '$_currentPlayer to move';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        actions: [
          IconButton(
            tooltip: 'Restart',
            onPressed: () => _reset(resetScore: true),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'X: $_xWins   •   O: $_oWins',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final mark = _board[index];
                      final isX = mark == 'X';

                      return Material(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => _handleTap(index),
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: Text(
                              mark,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: isX ? scheme.primary : scheme.error,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New round'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
