import 'package:airmail/Screens/camera_screen.dart';
import 'package:flutter/material.dart';

class CameraIndivisual extends StatelessWidget {
  const CameraIndivisual({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Take a photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.redAccent,
                Colors.purple,
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: CameraScreen(),
    );
  }
}
