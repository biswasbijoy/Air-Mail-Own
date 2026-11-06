import 'package:flutter/material.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x08080c),
      appBar: AppBar(
        title: const Text('How to Play'),
        backgroundColor: Color(0x00d4aa),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Rules',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xfafafa),
              ),
            ),
            const SizedBox(height: 20),
            _buildRuleItem('Rock beats Scissors', context),
            _buildRuleItem('Scissors beats Paper', context),
            _buildRuleItem('Paper beats Rock', context),
            const SizedBox(height: 30),
            const Text(
              'How to Play',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xfafafa),
              ),
            ),
            const SizedBox(height: 10),
            _buildStepItem('1. Choose Rock, Paper, or Scissors'),
            _buildStepItem('2. Wait for your opponent to choose'),
            _buildStepItem('3. See who wins based on the rules'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0x00d4aa),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Back to Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Color(0x00d4aa),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, {int index = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0x00d4aa),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}