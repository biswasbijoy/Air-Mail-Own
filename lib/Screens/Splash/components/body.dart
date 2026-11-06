import 'package:airmail/Screens/Splash/components/introduction.dart';
import 'package:airmail/Screens/Splash/components/splash_contents.dart';
import 'package:airmail/Screens/login_screen.dart';
import 'package:airmail/defaultButton.dart';
import 'package:airmail/size_config.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: Color(0x00d4aa),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}