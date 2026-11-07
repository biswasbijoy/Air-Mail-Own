import 'package:flutter/material.dart';

class TicTacToe extends StatelessWidget {
  const TicTacToe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Tic Tac Toe Game',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}