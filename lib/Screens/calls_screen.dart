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
      backgroundColor: Colors.indigoAccent,
      body: ListView.builder(
        itemCount: calls.length,
        itemBuilder: (context, index) {
          return callCard(calls[index].name, Icons.call_missed_outgoing,
              Colors.red, "10:00 AM", calls[index].icon);
        },
      ),
    );
  }

  Widget callCard(
      String name, IconData icon, Color color, String time, String img) {
    return Card(
      color: Colors.indigoAccent,
      margin: EdgeInsets.only(bottom: 0.5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(img),
        ),
        title: Text(name,
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        subtitle: Row(
          children: [
            Icon(
              icon,
              color: color,
            ),
            SizedBox(width: 6),
            Text(
              time,
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        trailing: Icon(
          Icons.call,
          size: 25,
          color: Colors.white,
        ),
      ),
    );
  }
}
