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
    return Scaffold(
      backgroundColor: const Color(0x08080c),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return ButtonCard(name: 'New Contact', icon: Icons.person_add);
        },
      ),
    );
  }
}