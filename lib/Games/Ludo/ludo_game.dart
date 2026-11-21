import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../celebration_dialog.dart';
import 'ludo_board.dart';
import 'ludo_dice.dart';
import 'ludo_models.dart';

class LudoGame extends StatefulWidget {
  final int initialPlayerCount;

  const LudoGame({super.key, this.initialPlayerCount = 4});

  @override
  State<LudoGame> createState() => _LudoGameState();
}

class _LudoGameState extends State<LudoGame> {
  final math.Random _random = math.Random();

  int _playerCount = 4;
  late List<LudoPlayerColor> _activeColors;
  late List<LudoToken> _allTokens;

  int _currentTurnIndex = 0;
  int? _diceValue;
  bool _isRolling = false;
  bool _hasRolled = false;
  bool _isMovingToken = false;
  bool _hasGameStarted = false;
  LudoToken? _movingToken;
  Timer? _autoMoveTimer;
  int _moveSessionId = 0;
  String _statusMessage = 'Roll the dice to start!';
  final Set<LudoToken> _movableTokens = {};
  final List<LudoPlayerColor> _winners = [];

  LudoPlayerColor get _currentColor => _activeColors[_currentTurnIndex];

  bool get _isGameRunning =>
      _hasGameStarted ||
      _allTokens.any((t) => !t.isInYard) ||
      _isRolling ||
      _isMovingToken;

  @override
  void initState() {
    super.initState();
    _initGame(count: widget.initialPlayerCount);
  }

  @override
  void dispose() {
    _autoMoveTimer?.cancel();
    super.dispose();
  }

  void _initGame({int? count}) {
    if (count != null) {
      _playerCount = count;
    }
    _autoMoveTimer?.cancel();
    _autoMoveTimer = null;
    _moveSessionId++;
    _hasGameStarted = false;
    _activeColors = _getColorsForCount(_playerCount);
    _allTokens = [];

    for (final color in _activeColors) {
      for (int i = 0; i < 4; i++) {
        _allTokens.add(LudoToken(id: i, color: color));
      }
    }

    _currentTurnIndex = 0;
    _diceValue = 6;
    _isRolling = false;
    _hasRolled = false;
    _isMovingToken = false;
    _movingToken = null;
    _movableTokens.clear();
    _winners.clear();
    _statusMessage = '${_currentColor.label}\'s turn! Tap the dice to roll.';
  }

  List<LudoPlayerColor> _getColorsForCount(int count) {
    switch (count) {
      case 2:
        return [LudoPlayerColor.red, LudoPlayerColor.yellow];
      case 3:
        return [LudoPlayerColor.red, LudoPlayerColor.green, LudoPlayerColor.yellow];
      case 4:
      default:
        return [
          LudoPlayerColor.red,
          LudoPlayerColor.green,
          LudoPlayerColor.yellow,
          LudoPlayerColor.blue,
        ];
    }
  }

  Future<void> _rollDice() async {
    if (_isRolling || _hasRolled || _isMovingToken) return;

    _autoMoveTimer?.cancel();
    _autoMoveTimer = null;

    setState(() {
      _hasGameStarted = true;
      _isRolling = true;
      _movableTokens.clear();
      _statusMessage = '${_currentColor.label} is rolling...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final rolled = _random.nextInt(6) + 1;

    setState(() {
      _diceValue = rolled;
      _isRolling = false;
      _hasRolled = true;
    });

    _evaluateMoves(rolled);
  }

  void _evaluateMoves(int dice) {
    final playerTokens = _allTokens.where((t) => t.color == _currentColor && !t.isHome).toList();
    final validMoves = playerTokens.where((t) => t.canMove(dice)).toSet();

    if (validMoves.isEmpty) {
      setState(() {
        _movableTokens.clear();
        _statusMessage = 'No moves possible with a $dice.';
      });

      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _nextTurn(extraRoll: false);
      });
      return;
    }

    final bool allInYard = validMoves.every((t) => t.isInYard) &&
        playerTokens.every((t) => t.isInYard);
    final bool isSingleEligible = validMoves.length == 1 || allInYard;

    if (isSingleEligible) {
      final tokenToMove = validMoves.first;
      setState(() {
        _movableTokens.clear();
        _movableTokens.add(tokenToMove);
        _statusMessage = '${_currentColor.label} rolled $dice! Moving automatically...';
      });

      _autoMoveTimer?.cancel();
      _autoMoveTimer = Timer(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        _moveToken(tokenToMove);
      });
      return;
    }

    setState(() {
      _movableTokens.clear();
      _movableTokens.addAll(validMoves);
      _statusMessage = '${_currentColor.label} rolled $dice! Choose a token to move.';
    });
  }

  Future<void> _moveToken(LudoToken token) async {
    _autoMoveTimer?.cancel();
    _autoMoveTimer = null;

    if (!_hasRolled || _diceValue == null || _isMovingToken) return;
    if (!_movableTokens.contains(token)) return;

    final currentSession = ++_moveSessionId;
    final dice = _diceValue!;

    setState(() {
      _isMovingToken = true;
      _movingToken = token;
      _movableTokens.clear();
      _hasRolled = false;
      _statusMessage = '${_currentColor.label} is moving...';
    });

    bool extraRoll = dice == 6;
    String feedback = '';

    if (token.isInYard) {
      // Jump from yard to start cell
      setState(() {
        token.step = 0;
      });
      await Future.delayed(const Duration(milliseconds: 260));
      if (!mounted || _moveSessionId != currentSession) return;

      feedback = '${_currentColor.label} unlocked a token! Extra roll!';
      extraRoll = true;
    } else {
      // Jump one by one through each cell to the destination
      for (int i = 0; i < dice; i++) {
        setState(() {
          token.step += 1;
        });
        await Future.delayed(const Duration(milliseconds: 190));
        if (!mounted || _moveSessionId != currentSession) return;
      }

      if (token.isHome) {
        feedback = '🎉 ${_currentColor.label} reached Home! Extra roll!';
        extraRoll = true;
      } else {
        // Check for captures on common circuit
        final landedPos = LudoConstants.getTokenPosition(token);
        if (!LudoConstants.isPositionSafe(landedPos)) {
          final opponentsAtTile = _allTokens.where((t) =>
              t.color != _currentColor &&
              t.isOnBoard &&
              LudoConstants.getTokenPosition(t) == landedPos);

          if (opponentsAtTile.isNotEmpty) {
            for (final opp in opponentsAtTile.toList()) {
              opp.reset();
            }
            feedback = '💥 ${_currentColor.label} captured an opponent! Extra roll!';
            extraRoll = true;
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 250));
            if (!mounted || _moveSessionId != currentSession) return;
          }
        }
      }
    }

    setState(() {
      _isMovingToken = false;
      _movingToken = null;
    });

    // Check if player won
    final remainingTokens = _allTokens.where((t) => t.color == _currentColor && !t.isHome);
    if (remainingTokens.isEmpty && !_winners.contains(_currentColor)) {
      _winners.add(_currentColor);
      _showWinnerDialog(_currentColor);
      return;
    }

    if (feedback.isNotEmpty) {
      setState(() => _statusMessage = feedback);
    }

    if (extraRoll) {
      setState(() {
        _statusMessage = feedback.isNotEmpty
            ? feedback
            : '${_currentColor.label} rolled a 6! Roll again!';
      });
    } else {
      _nextTurn(extraRoll: false);
    }
  }

  void _nextTurn({required bool extraRoll}) {
    if (_winners.length >= _activeColors.length - 1) {
      // Game over
      setState(() {
        _statusMessage = 'Game Over! Thanks for playing!';
      });
      return;
    }

    setState(() {
      _hasRolled = false;
      _movableTokens.clear();

      if (!extraRoll) {
        int nextIndex = (_currentTurnIndex + 1) % _activeColors.length;
        // Skip already finished players
        while (_winners.contains(_activeColors[nextIndex]) && _winners.length < _activeColors.length) {
          nextIndex = (nextIndex + 1) % _activeColors.length;
        }
        _currentTurnIndex = nextIndex;
      }

      _statusMessage = '${_currentColor.label}\'s turn! Tap the dice to roll.';
    });
  }

  void _showWinnerDialog(LudoPlayerColor color) {
    CelebrationDialog.show(
      context: context,
      title: '${color.label} Wins!',
      message:
          'Congratulations to player ${color.label}! All 4 tokens have successfully reached home!',
      primaryColor: color.color,
      onPlayAgain: () {
        Navigator.of(context).pop();
        _initGame();
      },
      onExit: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _confirmReset() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.restart_alt, color: Color(0xFFE53935), size: 28),
              SizedBox(width: 10),
              Text('Reset Game?'),
            ],
          ),
          content: const Text(
            'Are you sure you want to reset the current match? All progress will be lost.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _autoMoveTimer?.cancel();
      _autoMoveTimer = null;
      setState(() => _initGame());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo Multiplayer'),
        actions: [
          IconButton(
            tooltip: 'Reset game',
            icon: const Icon(Icons.refresh),
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Active player banner & Dice area
              _buildTurnControlCard(scheme),
              const SizedBox(height: 16),

              // The 15x15 Ludo Board
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LudoBoard(
                  tokens: _allTokens,
                  movableTokens: _movableTokens,
                  movingToken: _movingToken,
                  onTokenTap: _moveToken,
                ),
              ),
              const SizedBox(height: 16),

              // Players Home Score Card
              _buildScoreSummary(scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnControlCard(ColorScheme scheme) {
    final activeColor = _currentColor;

    return Card(
      elevation: 0,
      color: activeColor.containerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: activeColor.color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Current turn indicator dot and player name
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: activeColor.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.color.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${activeColor.label}\'s Turn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: activeColor.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Animated interactive Dice
            LudoDice(
              value: _diceValue,
              isRolling: _isRolling,
              canRoll: !_hasRolled && !_isMovingToken && _winners.length < _activeColors.length - 1,
              activeColor: activeColor,
              onRoll: _rollDice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary(ColorScheme scheme) {
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _activeColors.map((color) {
            final homeCount = _allTokens.where((t) => t.color == color && t.isHome).length;
            final isCurrent = color == _currentColor;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      color.label,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: isCurrent ? color.color : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$homeCount / 4 Home',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
