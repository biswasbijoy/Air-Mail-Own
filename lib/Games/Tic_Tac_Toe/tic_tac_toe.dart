import 'package:airmail/Games/Tic_Tac_Toe/Tic_game_function.dart';
import 'package:flutter/material.dart';

class TicTacToy extends StatelessWidget {
  const TicTacToy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameFunctionTic(),
    );
  }
}
