import 'package:flutter/material.dart';

List<String> choices = ['Rock', 'Paper', 'Scissors'];

Widget gameHeader(String title) {
  return Container(
    margin: const EdgeInsets.all(20),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget choiceButton(String choice, Color color, BuildContext context) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: () {},
        child: Text(
          choice,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget scoreDisplay(String label, int score) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.darkRaised,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      '$label: $score',
      style: const TextStyle(
        fontSize: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}