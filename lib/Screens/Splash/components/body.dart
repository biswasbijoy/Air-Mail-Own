import 'package:airmail/Screens/Splash/components/introduction.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Introduction());
  }
}
