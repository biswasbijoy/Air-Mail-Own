import 'package:airmail/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirMail',
      theme: ThemeData(
        fontFamily: "Lato",
        scaffoldBackgroundColor: const Color(0x08080c),
        primaryColor: const Color(0x00d4aa),
        cardColor: const Color(0x1a1a25),
        dividerColor: const Color(0x33ffffff),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xfafafa)),
          bodyMedium: TextStyle(color: Color(0xa0a0a0)),
          titleLarge: TextStyle(color: Colors.white, fontSize: 20),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x55ffffff)),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00d4aa)),
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: Color(0x1a1a25),
          hintStyle: TextStyle(color: Color(0x80a0a0a0)),
          contentPadding: EdgeInsets.all(15),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: "Lato",
        scaffoldBackgroundColor: const Color(0x08080c),
        primaryColor: const Color(0x00d4aa),
        cardColor: const Color(0x1a1a25),
        dividerColor: const Color(0x33ffffff),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xfafafa)),
          bodyMedium: TextStyle(color: Color(0xa0a0a0)),
          titleLarge: TextStyle(color: Colors.white, fontSize: 20),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x55ffffff)),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00d4aa)),
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: Color(0x1a1a25),
          hintStyle: TextStyle(color: Color(0x80a0a0a0)),
          contentPadding: EdgeInsets.all(15),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}