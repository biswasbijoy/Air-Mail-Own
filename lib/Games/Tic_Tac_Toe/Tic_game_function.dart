import 'package:flutter/material.dart';

Widget gameHeader(String title) {
  return Container(
    margin: const EdgeInsets.all(20),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.surface,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget cellBuilder(BuildContext context, int index, VoidCallback onTap) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.darkBorder,
        border: Border.all(color: Color(0x55ffffff)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Text(
              '',
              style: TextStyle(
                fontSize: 40,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}