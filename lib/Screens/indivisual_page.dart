import 'dart:convert';
import 'package:airmail/Model/message_model.dart';
import 'package:airmail/DesignUI/reply_side_card.dart';
import 'package:airmail/DesignUI/user_side_card.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/camera_page_indivisual.dart';
// import 'package:airmail/Screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IndivisualPage extends StatefulWidget {
  const IndivisualPage(
      {Key? key, required this.chatModel, required this.sourceChat})
      : super(key: key);
  final ChatModel chatModel;
  final ChatModel sourceChat;

  @override
  State<IndivisualPage> createState() => _IndivisualPageState();
}

class _IndivisualPageState extends State<IndivisualPage> {
  bool showEmoji = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  List<MessageModel> messages = [];

  TextEditingController _controller = TextEditingController();
  String? _token;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _token = '';
    _currentUserId = 'current_user';
    focusNode.addListener(
      () {
        if (focusNode.hasFocus) {
          setState(
            () {
              showEmoji = false;
            },
          );
        }
      },
    );
  }

  void _sendMessage() async {
    if (_token != null && _currentUserId != null && _controller.text.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('https://airmail-backend.onrender.com/api/messages'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: json.encode({
            'senderId': _currentUserId,
            'receiverId': widget.chatModel.id,
            'message': _controller.text,
          }),
        );
        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          setState(() {
            messages.add(MessageModel(
              type: "source",
              message: _controller.text,
              time: DateTime.now().toString(),
            ));
          });
        } else {
          print('Failed to send message: ${response.body}');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
      setState(() {
        _controller.clear();
        sendButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 70,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                size: 24,
                color: Colors.white,
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(widget.chatModel.icon ?? 'assets/images/default_avatar.png'),
              )
            ],
          ),
        ),
        title: InkWell(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chatModel.name ?? 'Unknown',
                    style: TextStyle(
                        fontSize: 18.5, fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                  "Last seen today at ${widget.chatModel.time ?? ''}",
                  style: TextStyle(fontSize: 13, color: Color(0xa0a0a0)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Color(0x00d4aa)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: Color(0x00d4aa)),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "View Profile",
                child: Text("View Profile"),
              ),
              PopupMenuItem(
                value: "Search",
                child: Text("Search"),
              ),
              PopupMenuItem(
                value: "Mute Notification",
                child: Text("Mute Notification"),
              ),
              PopupMenuItem(
                value: "Block",
                child: Text("Block"),
              ),
            ],
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () {
          if (showEmoji) {
            setState(() {
              showEmoji = false;
            });
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Stack(
          children: [
            Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
            ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                if (messages[index].type == "source") {
                  return OwnMessageCard(
                    message: messages[index].message,
                  );
                } else {
                  return ReplyCard(
                    message: messages[index].message,
                  );
                }
              },
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Card(
                margin: EdgeInsets.only(left: 2, right: 2, bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        onChanged: (value) {
                          if (value.length > 0) {
                            setState(() {
                              sendButton = true;
                            });
                          } else {
                            sendButton = false;
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          contentPadding: EdgeInsets.all(5),
                          prefixIcon: IconButton(
                            onPressed: () {
                              focusNode.unfocus();
                              setState(() {
                                showEmoji = !showEmoji;
                              });
                            },
                            icon: Icon(Icons.emoji_emotions),
                            color: Color(0x00d4aa),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.camera_alt),
                            color: Color(0x00d4aa),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8, right: 2),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0x00d4aa),
                        child: IconButton(
                          icon: Icon(
                            sendButton ? Icons.send : Icons.mic,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (sendButton) {
                              _sendMessage();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}