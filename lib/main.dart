import 'package:airmail/Screens/Splash/splash_screen.dart';
import 'package:airmail/Screens/login.dart';
import 'package:airmail/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

int? isviewed;
// void main() async {
//   SystemChrome.setSystemUIOverlayStyle(
//     SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//     ),
//   );
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   isviewed = prefs.getInt('SplashScreen');
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: "Lato",
//         primaryColor: Colors.purpleAccent[400],
//         accentColor: Colors.pinkAccent[400],
//         primarySwatch: Colors.blue,
//       ),
//       // home: isviewed != 0 ? SplashScreen() : LoginPage(),
//       home: SplashScreen(),
//     );
//   }
// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Lato",
        primaryColor: Colors.purpleAccent[400],
        accentColor: Colors.pinkAccent[400],
      ),
      home: LoginPage(),
    );
  }
}
