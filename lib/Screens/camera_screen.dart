import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? imageFile;
  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 50),
          imageFile != null
              ? Stack(
                  children: [
                    Container(
                      child: Image.file(imageFile!),
                    ),
                    Positioned(
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.08,
                          child: Icon(
                            Icons.done,
                            size: MediaQuery.of(context).size.width * 0.13,
                            color: Colors.purpleAccent[400],
                          ),
                          backgroundColor: Colors.amber[100],
                        ),
                        bottom: 12,
                        right: 10),
                  ],
                )
              : Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: IconButton(
              onPressed: () {
                _getFromCamera();
              },
              icon: Icon(
                Icons.photo_camera_outlined,
                color: Colors.purpleAccent[400],
                size: MediaQuery.of(context).size.width * 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
