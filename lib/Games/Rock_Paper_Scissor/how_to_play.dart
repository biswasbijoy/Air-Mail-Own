import 'package:flutter/material.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text('Rule of the Game'),
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
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height * 0.08,
                width: double.infinity,
                child: Text(
                  "Condition of this Game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height * 0.79,
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "* You need to click an image from Screen that you want to bid.          ",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      "* A new scrren will appear. The image on the left side is selected by you and the one on the right side is by computer.",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
