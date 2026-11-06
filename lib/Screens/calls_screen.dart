import 'package:airmail/Model/chat_model.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    List<ChatModel> calls = [
      ChatModel(
        name: 'Bill Gates',
        icon: "assets/images/BillGates.jpeg",
      ),
      ChatModel(
        name: 'Boris Johnson',
        icon: "assets/images/BorisJohnson.jpg",
      ),
      ChatModel(
        name: 'Donald Trump',
        icon: "assets/images/DonaldTrump.jpg",
      ),
      ChatModel(
        name: 'Recep Tayyip Erdogan',
        icon: "assets/images/Erdogan.jpg",
      ),
      ChatModel(
        name: 'Jack Ma',
        icon: "assets/images/JackMa.jpg",
      ),
      ChatModel(
        name: 'Joe Biden',
        icon: "assets/images/JoeBiden.jpg",
      ),
      ChatModel(
        name: 'John Abrahm',
        icon: "assets/images/JohnAbraham.jpg",
      ),
      ChatModel(
        name: 'Steve Jobs',
        icon: "assets/images/SteveJobs.jpg",
      ),
      ChatModel(
        name: 'Sundor Pichai',
        icon: "assets/images/SundorPichai.jpg",
      ),
      ChatModel(
        name: 'Vladimir Putin',
        icon: "assets/images/VladimirPutin.jpg",
      )
    ];
    return Scaffold(
      backgroundColor: const Color(0x08080c),
      body: ListView.builder(
        itemCount: calls.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0x1a1a25),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(calls[index].icon),
              ),
              title: Text(calls[index].name,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
              subtitle: Row(
                children: [
                  Icon(Icons.call_missed_outgoing,
                      color: Color(0x00d4aa),
                      size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "10:00 AM",
                    style: const TextStyle(fontSize: 13, color: Color(0xa0a0a0)),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.call,
                size: 25,
                color: Color(0xfafafa),
              ),
            ),
          );
        },
      ),
    );
  }
}