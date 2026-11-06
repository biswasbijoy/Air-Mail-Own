import 'package:airmail/DesignUI/button_card.dart';
import 'package:airmail/DesignUI/contact_card.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:flutter/material.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({Key? key}) : super(key: key);
  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  @override
  Widget build(BuildContext context) {
    List<ChatModel> contacts = [
      ChatModel(
        name: 'Bill Gates',
        icon: "assets/images/BillGates.jpeg",
        status: "I love Money!",
      ),
      ChatModel(
          name: 'Boris Johnson',
          icon: "assets/images/BorisJohnson.jpg",
          status: "I want power more and more!"),
      ChatModel(
          name: 'Donald Trump',
          icon: "assets/images/DonaldTrump.jpg",
          status: "I want to be the president of the USA again!"),
      ChatModel(
          name: 'Recep Tayyip Erdogan',
          icon: "assets/images/Erdogan.jpg",
          status: "I want some special weapons!"),
      ChatModel(
          name: 'Jack Ma',
          icon: "assets/images/JackMa.jpg",
          status: "Time is money!"),
      ChatModel(
          name: 'Joe Biden',
          icon: "assets/images/JoeBiden.jpg",
          status: "I want to be the president of the USA again!"),
      ChatModel(
          name: 'John Abrahm',
          icon: "assets/images/JohnAbraham.jpg",
          status: "I love acting!"),
      ChatModel(
          name: 'Steve Jobs',
          icon: "assets/images/SteveJobs.jpg",
          status: "I love Apple!"),
      ChatModel(
          name: 'Sundor Pichai',
          icon: "assets/images/SundorPichai.jpg",
          status: "I love Google!"),
      ChatModel(
          name: 'Vladimir Putin',
          icon: "assets/images/VladimirPutin.jpg",
          status: "I am the most powerful man in the world!"),
    ];
    return Scaffold(
      // appBar: AppBar(
      //   title: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         'Select Contact',
      //         style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      //       ),
      //       Text(
      //         contacts.length.toString() + ' Contacts',
      //         style: TextStyle(
      //           fontSize: 15,
      //         ),
      //       ),
      //     ],
      //   ),
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [
      //           Colors.blueAccent,
      //           Colors.redAccent,
      //           Colors.purple,
      //         ],
      //         begin: Alignment.bottomRight,
      //         end: Alignment.topLeft,
      //       ),
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(
      //         Icons.search,
      //         size: 26,
      //       ),
      //       onPressed: () {},
      //     ),
      //     PopupMenuButton<String>(
      //       onSelected: (value) {},
      //       itemBuilder: (context) => [
      //         PopupMenuItem(
      //           value: "Invite a friend",
      //           child: Text("Invite a friend"),
      //         ),
      //         PopupMenuItem(
      //           value: "Contacts",
      //           child: Text("Contacts"),
      //         ),
      //         PopupMenuItem(
      //           value: "Refresh",
      //           child: Text("Refresh"),
      //         ),
      //         PopupMenuItem(
      //           value: "Help",
      //           child: Text("Help"),
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
      backgroundColor: Colors.indigoAccent,
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ButtonCard(name: 'New Contact', icon: Icons.person_add);
          }
          return ContactCard(contact: contacts[index]);
        },
      ),
    );
  }
}
