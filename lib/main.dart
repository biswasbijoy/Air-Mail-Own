import 'package:airmail/Screens/login_screen.dart';
import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xF7F9FC),
        primaryColor: const Color(0x00d4aa),
        cardColor: const Color(0xFFFFFF),
        dividerColor: const Color(0xCCCCCC),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0x1A1A1A)),
          bodyMedium: TextStyle(color: Color(0x333333)),
          titleLarge: TextStyle(color: Colors.white, fontSize: 20),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x99CCCCCC)),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00d4aa)),
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Color(0x666666)),
          contentPadding: EdgeInsets.all(15),
        ),
        colorScheme: ColorScheme.light(
          primary: Color(0x00d4aa),
          surface: Color(0xF7F9FC),
          background: Color(0xF7F9FC),
          onPrimary: Color(0x000000),
          onSurface: Color(0x1A1A1A),
          onBackground: Color(0xFFFFFF),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: "Lato",
        scaffoldBackgroundColor: const Color(0x08080c),
        primaryColor: const Color(0x00d4aa),
        cardColor: const Color(0x1A1A25),
        dividerColor: const Color(0x333333),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFafafa)),
          bodyMedium: TextStyle(color: Color(0xA0A0A0)),
          titleLarge: TextStyle(color: Colors.white, fontSize: 20),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x55CCCCCC)),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x00d4aa)),
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: Color(0x1A1A25),
          hintStyle: TextStyle(color: Color(0x8899AA)),
          contentPadding: EdgeInsets.all(15),
        ),
        colorScheme: ColorScheme.dark(
          primary: Color(0x00d4aa),
          surface: Color(0x08080c),
          background: Color(0x08080c),
          onPrimary: Color(0x000000),
          onSurface: Color(0xFafafa),
          onBackground: Color(0xFafafa),
        ),
      ),
      themeMode: ThemeMode.system,
      home: LoginScreen(),
    );
  }
}