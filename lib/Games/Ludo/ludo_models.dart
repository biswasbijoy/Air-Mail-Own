import 'package:flutter/material.dart';

enum LudoPlayerColor {
  red,
  green,
  yellow,
  blue,
}

extension LudoColorExt on LudoPlayerColor {
  String get label {
    switch (this) {
      case LudoPlayerColor.red:
        return 'Red';
      case LudoPlayerColor.green:
        return 'Green';
      case LudoPlayerColor.yellow:
        return 'Yellow';
      case LudoPlayerColor.blue:
        return 'Blue';
    }
  }

  Color get color {
    switch (this) {
      case LudoPlayerColor.red:
        return const Color(0xFFE53935);
      case LudoPlayerColor.green:
        return const Color(0xFF2E7D32);
      case LudoPlayerColor.yellow:
        return const Color(0xFFF9A825);
      case LudoPlayerColor.blue:
        return const Color(0xFF1565C0);
    }
  }

  Color get brightColor {
    switch (this) {
      case LudoPlayerColor.red:
        return const Color(0xFFFF5252);
      case LudoPlayerColor.green:
        return const Color(0xFF4CAF50);
      case LudoPlayerColor.yellow:
        return const Color(0xFFFFD600);
      case LudoPlayerColor.blue:
        return const Color(0xFF2196F3);
    }
  }

  Color get containerColor {
    switch (this) {
      case LudoPlayerColor.red:
        return const Color(0xFFFFEBEE);
      case LudoPlayerColor.green:
        return const Color(0xFFE8F5E9);
      case LudoPlayerColor.yellow:
        return const Color(0xFFFFFDE7);
      case LudoPlayerColor.blue:
        return const Color(0xFFE3F2FD);
    }
  }

  /// Start offset on the 52-tile circuit
  int get startOffset {
    switch (this) {
      case LudoPlayerColor.red:
        return 0;
      case LudoPlayerColor.green:
        return 13;
      case LudoPlayerColor.yellow:
        return 26;
      case LudoPlayerColor.blue:
        return 39;
    }
  }

  /// Center row, col of the yard
  List<GridPos> get yardSlots {
    switch (this) {
      case LudoPlayerColor.red:
        return const [
          GridPos(1, 1),
          GridPos(1, 4),
          GridPos(4, 1),
          GridPos(4, 4),
        ];
      case LudoPlayerColor.green:
        return const [
          GridPos(1, 10),
          GridPos(1, 13),
          GridPos(4, 10),
          GridPos(4, 13),
        ];
      case LudoPlayerColor.yellow:
        return const [
          GridPos(10, 10),
          GridPos(10, 13),
          GridPos(13, 10),
          GridPos(13, 13),
        ];
      case LudoPlayerColor.blue:
        return const [
          GridPos(10, 1),
          GridPos(10, 4),
          GridPos(13, 1),
          GridPos(13, 4),
        ];
    }
  }
}

class GridPos {
  final int row;
  final int col;

  const GridPos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPos && runtimeType == other.runtimeType && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class LudoToken {
  final int id;
  final LudoPlayerColor color;

  /// -1: In yard
  /// 0..50: On common track (0 is color's start tile)
  /// 51..55: In home runway (5 steps)
  /// 56: Home (finished)
  int step;

  LudoToken({
    required this.id,
    required this.color,
    this.step = -1,
  });

  bool get isInYard => step == -1;
  bool get isHome => step >= 56;
  bool get isOnBoard => step >= 0 && step < 56;

  bool canMove(int dice) {
    if (isHome) return false;
    if (isInYard) return dice == 6;
    return step + dice <= 56;
  }

  void reset() {
    step = -1;
  }
}

class LudoConstants {
  static const int totalPathSteps = 56;

  /// 52 main circuit positions in clockwise order (starts at Red Start)
  static const List<GridPos> circuit = [
    GridPos(6, 1),  // 0  Red Start (Safe)
    GridPos(6, 2),  // 1
    GridPos(6, 3),  // 2
    GridPos(6, 4),  // 3
    GridPos(6, 5),  // 4
    GridPos(5, 6),  // 5
    GridPos(4, 6),  // 6
    GridPos(3, 6),  // 7
    GridPos(2, 6),  // 8  (Safe)
    GridPos(1, 6),  // 9
    GridPos(0, 6),  // 10
    GridPos(0, 7),  // 11
    GridPos(0, 8),  // 12
    GridPos(1, 8),  // 13 Green Start (Safe)
    GridPos(2, 8),  // 14
    GridPos(3, 8),  // 15
    GridPos(4, 8),  // 16
    GridPos(5, 8),  // 17
    GridPos(6, 9),  // 18
    GridPos(6, 10), // 19
    GridPos(6, 11), // 20
    GridPos(6, 12), // 21 (Safe)
    GridPos(6, 13), // 22
    GridPos(6, 14), // 23
    GridPos(7, 14), // 24
    GridPos(8, 14), // 25
    GridPos(8, 13), // 26 Yellow Start (Safe)
    GridPos(8, 12), // 27
    GridPos(8, 11), // 28
    GridPos(8, 10), // 29
    GridPos(8, 9),  // 30
    GridPos(9, 8),  // 31
    GridPos(10, 8), // 32
    GridPos(11, 8), // 33
    GridPos(12, 8), // 34 (Safe)
    GridPos(13, 8), // 35
    GridPos(14, 8), // 36
    GridPos(14, 7), // 37
    GridPos(14, 6), // 38
    GridPos(13, 6), // 39 Blue Start (Safe)
    GridPos(12, 6), // 40
    GridPos(11, 6), // 41
    GridPos(10, 6), // 42
    GridPos(9, 6),  // 43
    GridPos(8, 5),  // 44
    GridPos(8, 4),  // 45
    GridPos(8, 3),  // 46
    GridPos(8, 2),  // 47 (Safe)
    GridPos(8, 1),  // 48
    GridPos(8, 0),  // 49
    GridPos(7, 0),  // 50
    GridPos(6, 0),  // 51
  ];

  /// Home runways (steps 51..55)
  static const Map<LudoPlayerColor, List<GridPos>> homePaths = {
    LudoPlayerColor.red: [
      GridPos(7, 1),
      GridPos(7, 2),
      GridPos(7, 3),
      GridPos(7, 4),
      GridPos(7, 5),
    ],
    LudoPlayerColor.green: [
      GridPos(1, 7),
      GridPos(2, 7),
      GridPos(3, 7),
      GridPos(4, 7),
      GridPos(5, 7),
    ],
    LudoPlayerColor.yellow: [
      GridPos(7, 13),
      GridPos(7, 12),
      GridPos(7, 11),
      GridPos(7, 10),
      GridPos(7, 9),
    ],
    LudoPlayerColor.blue: [
      GridPos(13, 7),
      GridPos(12, 7),
      GridPos(11, 7),
      GridPos(10, 7),
      GridPos(9, 7),
    ],
  };

  /// Home center positions (step 56)
  static const Map<LudoPlayerColor, GridPos> homeCenters = {
    LudoPlayerColor.red: GridPos(7, 6),
    LudoPlayerColor.green: GridPos(6, 7),
    LudoPlayerColor.yellow: GridPos(7, 8),
    LudoPlayerColor.blue: GridPos(8, 7),
  };

  /// 8 Classic Safe Positions
  static final Set<GridPos> safePositions = {
    GridPos(6, 1),  // Red Start
    GridPos(2, 6),  // Top Left Safe
    GridPos(1, 8),  // Green Start
    GridPos(6, 12), // Right Top Safe
    GridPos(8, 13), // Yellow Start
    GridPos(12, 8), // Bottom Right Safe
    GridPos(13, 6), // Blue Start
    GridPos(8, 2),  // Left Bottom Safe
  };

  static GridPos getTokenPosition(LudoToken token) {
    if (token.isInYard) {
      return token.color.yardSlots[token.id];
    }
    if (token.step == 56) {
      return homeCenters[token.color]!;
    }
    if (token.step >= 51) {
      final runwayIndex = token.step - 51;
      return homePaths[token.color]![runwayIndex];
    }
    final circuitIndex = (token.step + token.color.startOffset) % 52;
    return circuit[circuitIndex];
  }

  static bool isPositionSafe(GridPos pos) {
    return safePositions.contains(pos);
  }
}
