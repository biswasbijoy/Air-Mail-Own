import 'package:flutter/material.dart';

class RockPaperScissor extends StatelessWidget {
  const RockPaperScissor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors'),
        backgroundColor: Color(0x00d4aa),
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Rock Paper Scissors Game',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}