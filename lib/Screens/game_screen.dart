import 'package:airmail/Games/Color_Guess/guess_color.dart';
import 'package:airmail/Games/Rock_Paper_Scissor/rock_paper_scissor.dart';
import 'package:airmail/Games/Tic_Tac_Toe/tic_tac_toe.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: ListView(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RockPaperScissor()));
            },
            child: CardContants(
                "assets/images/rock_paper_scissor.png", "Rock Paper Scissor"),
          ),
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TicTacToy()));
              },
              child:
                  CardContants("assets/images/tic_tac_toe.png", "Tic Tac Toe")),
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ColorGuess()));
              },
              child: CardContants(
                  "assets/images/color_guessing.png", "Guess the Color")),
        ],
      ),
    );
  }

  Widget CardContants(String img, String txt) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.3,
          // color: Colors.green,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(img),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                txt,
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
