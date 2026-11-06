import 'dart:math';
import 'package:airmail/Games/Rock_Paper_Scissor/how_to_play.dart';
import 'package:airmail/Games/Rock_Paper_Scissor/rock_paper_scissor.dart';
import 'package:flutter/material.dart';

class GameFunction extends StatefulWidget {
  const GameFunction({Key? key}) : super(key: key);

  @override
  _GameFunctionState createState() => _GameFunctionState();
}

class _GameFunctionState extends State<GameFunction> {
  String userChoise = "";
  String compChoise = "";
  String message = "";
  bool hasChosen = false;

  List<String> _choises = [
    "Rock",
    "Paper",
    "Scissor",
  ];
  Widget userPicked = Container();
  Widget compPicked = Container();
  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
            child: hasChosen
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              userPicked,
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 20,
                              ),
                              Text(
                                "You picked",
                                style: TextStyle(
                                    color: Colors.purple, fontSize: 20),
                              ),
                            ],
                          ),
                          Text(
                            'VS',
                            style:
                                TextStyle(fontSize: 40, color: Colors.purple),
                          ),
                          Column(
                            children: [
                              compPicked,
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 20,
                              ),
                              Text(
                                'Computer picked',
                                style: TextStyle(
                                    color: Colors.purple, fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Text(
                        "${message}!",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 40,
                            fontWeight: FontWeight.w600),
                      ),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height * 0.2,
                      // ),
                      Container(
                        // alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08),
                        width: double.infinity,
                        child: RawMaterialButton(
                          onPressed: () {
                            setState(
                              () {
                                hasChosen = false;
                              },
                            );
                            print(hasChosen);
                          },
                          // padding: EdgeInsets.all(16.0),
                          shape: StadiumBorder(
                            side: BorderSide(color: Colors.purple, width: 3),
                          ),
                          child: Text(
                            'Play Again!',
                            style:
                                TextStyle(color: Colors.purple, fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Text(
                          'Play Now!',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          debugPrint('You chose scissors');
                          userChoise = "Scissor";
                          userClicked();
                        },
                        child: Container(
                          // padding: EdgeInsets.only(top: 140, left: 15),
                          child: Image.asset('assets/images/scissor.png'),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.14,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              debugPrint('You chose rock');
                              userChoise = "Rock";
                              userClicked();
                            },
                            child: Container(
                              child: Image.asset('assets/images/rock.png'),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              debugPrint('You chose paper');
                              userChoise = "Paper";
                              userClicked();
                            },
                            child: Container(
                              child: Image.asset('assets/images/paper.png'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Container(
            // alignment: Alignment.center,
            width: double.infinity,
            child: RawMaterialButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HowToPlay()));
              },
              // padding: EdgeInsets.all(16.0),
              shape: StadiumBorder(
                side: BorderSide(color: Colors.purple, width: 3),
              ),
              child: Text(
                'Rules of the game',
                style: TextStyle(color: Colors.purple, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void compChoises() {
    Random random = Random();
    int randomNumber = random.nextInt(3);
    compChoise = _choises[randomNumber];
  }

  result(userC, compC) {
    var rpsChoise = {
      'Rock': {'Scissor': 1, 'Paper': 0, 'Rock': 0.5},
      'Paper': {'Scissor': 0, 'Paper': 0.5, 'Rock': 1},
      'Scissor': {'Scissor': 0.5, 'Paper': 1, 'Rock': 0},
    };
    var points = rpsChoise[userC]?[compC];
    upDatePoints(points);
    picked();
    hasChosen = true;
  }

  upDatePoints(points) {
    if (points == 0) {
      return {message = 'You Lost'};
    } else if (points == 0.5) {
      return {message = 'Draw'};
    } else {
      return {message = 'You Won'};
    }
  }

  picked() {
    if (userChoise == 'Rock') {
      userPicked = Container(
        child: Image.asset('assets/images/rock.png'),
      );
    } else if (userChoise == 'Paper') {
      userPicked = Container(
        child: Image.asset('assets/images/paper.png'),
      );
    } else if (userChoise == 'Scissor') {
      userPicked = Container(
        child: Image.asset('assets/images/scissor.png'),
      );
    }

    //Computer

    if (compChoise == 'Rock') {
      compPicked = Container(
        child: Image.asset('assets/images/rock.png'),
      );
    } else if (compChoise == 'Paper') {
      compPicked = Container(
        child: Image.asset('assets/images/paper.png'),
      );
    } else if (compChoise == 'Scissor') {
      compPicked = Container(
        child: Image.asset('assets/images/scissor.png'),
      );
    }
  }

  userClicked() {
    compChoises();
    result(userChoise, compChoise);
    setState(
      () {
        hasChosen;
      },
    );
  }
}
