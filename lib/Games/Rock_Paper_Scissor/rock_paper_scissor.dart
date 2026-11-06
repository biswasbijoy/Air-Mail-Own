import 'package:flutter/material.dart';

import 'game_function.dart';

class RockPaperScissor extends StatelessWidget {
  const RockPaperScissor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.redAccent,
                Colors.purple,
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        title: Text('Rock Paper Scissor'),
        centerTitle: true,
      ),
      body: GameFunction(),
    );
  }
}
