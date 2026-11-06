import 'package:flutter/material.dart';

class ColorGuess extends StatelessWidget {
  const ColorGuess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x08080c),
      appBar: AppBar(
        title: const Text('Guess the Color'),
        backgroundColor: Color(0x00d4aa),
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Color Guessing Game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xfafafa),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xffff6b6b),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x00d4aa),
                foregroundColor: Colors.black,
              ),
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}