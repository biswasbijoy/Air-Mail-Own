import 'package:flutter/material.dart';

class GameFunctionTic extends StatefulWidget {
  const GameFunctionTic({Key? key}) : super(key: key);

  @override
  _GameFunctionTicState createState() => _GameFunctionTicState();
}

class _GameFunctionTicState extends State<GameFunctionTic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        centerTitle: true,
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
      ),
    );
  }
}
