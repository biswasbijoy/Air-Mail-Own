import 'package:flutter/material.dart';

class SplashContents extends StatelessWidget {
  const SplashContents({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 20,
            color: Color(0x88ffffff),
          ),
        ),
        const Text(
          'AirMail',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xfafafa),
          ),
        ),
      ],
    );
  }
}