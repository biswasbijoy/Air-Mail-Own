import 'package:airmail/DesignUI/button_card.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/homeScreen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  static String routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ChatModel sourceChat;
  List<ChatModel> chatmodels = [
    ChatModel(
        name: 'Bill Gates',
        icon: "assets/images/BillGates.jpeg",
        time: "4.00",
        currentMessage: "Hi",
        id: 1),
    ChatModel(
        name: 'Boris Johnson',
        icon: "assets/images/BorisJohnson.jpg",
        time: "4.00",
        currentMessage: "Hello, How are you?",
        id: 2),
    ChatModel(
        name: 'Donald Trump',
        icon: "assets/images/DonaldTrump.jpg",
        time: "4.00",
        currentMessage: "Nice, I am fine",
        id: 3),
    ChatModel(
        name: 'Recep Tayyip Erdogan',
        icon: "assets/images/Erdogan.jpg",
        time: "4.00",
        currentMessage: "Hey, Whats up?",
        id: 4),
    ChatModel(
        name: 'Jack Ma',
        icon: "assets/images/JackMa.jpg",
        time: "4.00",
        currentMessage: "What About You?",
        id: 5),
    ChatModel(
        name: 'Joe Biden',
        icon: "assets/images/JoeBiden.jpg",
        time: "4.00",
        currentMessage: "Nice to meet you",
        id: 6),
    ChatModel(
        name: 'John Abrahm',
        icon: "assets/images/JohnAbraham.jpg",
        time: "4.00",
        currentMessage: "Nice to meet you",
        id: 7),
    ChatModel(
        name: 'Steve Jobs',
        icon: "assets/images/SteveJobs.jpg",
        time: "4.00",
        currentMessage: "Nice to meet you",
        id: 8),
    ChatModel(
        name: 'Sundor Pichai',
        icon: "assets/images/SundorPichai.jpg",
        time: "4.00",
        currentMessage: "Nice to meet you",
        id: 9),
    ChatModel(
        name: 'Vladimir Putin',
        icon: "assets/images/VladimirPutin.jpg",
        time: "4.00",
        currentMessage: "Nice to meet you",
        id: 10),
    ChatModel(
        name: 'Bijoy Biswas',
        icon: "assets/images/bijoy.jpg",
        time: "4.00",
        currentMessage: "Hi",
        id: 11),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Continue as"),
        centerTitle: true,
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
        elevation: 4,
      ),
      backgroundColor: Colors.pinkAccent[700],
      body: ListView.builder(
          itemCount: chatmodels.length,
          itemBuilder: (contex, index) => ListTile(
                onTap: () {
                  sourceChat = chatmodels.removeAt(index);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => HomeScreen(
                        chatmodels: chatmodels,
                        sourceChat: sourceChat,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: AssetImage(chatmodels[index].icon),
                ),
                title: Text(
                  chatmodels[index].name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
              )),
    );
  }
}
