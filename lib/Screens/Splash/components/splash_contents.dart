import 'package:flutter/material.dart';

class SplashContents extends StatelessWidget {
  const SplashContents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          'AirMail',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
