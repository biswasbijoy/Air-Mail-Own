import 'package:flutter/material.dart';

class CameraIndivisual extends StatelessWidget {
  const CameraIndivisual({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Take a photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x0f0f1a),
                Color(0x1a1a2e),
                Color(0x25253b),
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0x08080c),
      ),
    );
  }
}