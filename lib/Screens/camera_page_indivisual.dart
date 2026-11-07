import 'package:flutter/material.dart';
import 'package:airmail/theme/app_colors.dart';

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
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: Container(
        color: AppColors.darkBg,
      ),
    );
  }
}