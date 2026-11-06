import 'dart:convert';
import 'package:airmail/Model/message_model.dart';
import 'package:socket_io_client/socket_io.dart' as IO;
import 'package:airmail/DesignUI/reply_side_card.dart';
import 'package:airmail/DesignUI/user_side_card.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/camera_page_indivisual.dart';
// import 'package:airmail/Screens/camera_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  late IO.Socket socket;
  bool sendButton = false;
  List<MessageModel> messages = [];

  TextEditingController _controller = TextEditingController();
  String? _token;
  String? _currentUserId;

  @override
  void initState() {
    // TODO: implement initState
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
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io(
      'http://192.168.0.120:5000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );
    socket.connect();
    socket.onConnect((data) {
      print('connected');
      socket.on("message", (msg) {
        print(msg);
        setMessage("destination", msg["message"]);
      });
    });
    print(socket.connected);
    socket.emit("signin", widget.sourceChat.id);
  }

  void _sendMessageToBackend(String message) async {
    if (_token != null && _currentUserId != null) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/messages'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: json.encode({
            'senderId': _currentUserId,
            'receiverId': widget.chatModel.id,
            'message': message,
          }),
        );
        if (response.statusCode != 200) {
          print('Failed to save message to backend: ${response.body}');
        }
      } catch (e) {
        print('Error saving message: $e');
      }
    }
  }

  void _sendMessage(String message) {
    // Send via Socket.IO
    socket.emit("message",
        {"message": message, "sourceId": _currentUserId, "targetId": widget.chatModel.id});

    // Also save to backend
    _sendMessageToBackend(message);

    setState(() {
      _controller.clear();
      sendButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/background.png',
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
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
                      backgroundImage: AssetImage(widget.chatModel.icon),
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
                      Text(widget.chatModel.name,
                          style: TextStyle(
                              fontSize: 18.5, fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                        "Last seen today at ${widget.chatModel.time}",
                        style: TextStyle(fontSize: 13, color: Color(0xa0a0a0)),
                      ),
                    ],
                  ),
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x0f0f1a),
                      Color(0x1a1a2e),
                      Color(0x25253b),
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
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
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: WillPopScope(
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height - 150,
                    child: ListView.builder(
                      shrinkWrap: true,
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
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 55,
                              child: Card(
                                margin: EdgeInsets.only(
                                    left: 2, right: 2, bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextFormField(
                                  controller: _controller,
                                  focusNode: focusNode,
                                  textAlignVertical: TextAlignVertical.center,
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
                                        focusNode.canRequestFocus = false;
                                        setState(
                                          () {
                                            showEmoji = !showEmoji;
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.emoji_emotions),
                                      color: Color(0x00d4aa),
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (builder) =>
                                                    bottomsheet());
                                          },
                                          icon: Icon(Icons.attach_file),
                                          color: Color(0x00d4aa),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CameraIndivisual(),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.camera_alt),
                                          color: Color(0x00d4aa),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8, right: 2),
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
                                      _sendMessage(_controller.text);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        showEmoji ? emojiSelect() : Container(),
                      ],
                    ),
                  ),
                ],
              ),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomsheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconcreation(
                    Icons.insert_drive_file,
                    Color(0x00d4aa),
                    "Document",
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.camera_alt,
                    Color(0xff6b6b),
                    "Camera",
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.insert_photo,
                    Color(0x00d4aa),
                    "Gallery",
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconcreation(
                    Icons.audiotrack,
                    Color(0xff6b6b),
                    "Audio",
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.location_pin,
                    Color(0x00d4aa),
                    "Location",
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.person,
                    Color(0xff6b6b),
                    "Contact",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconcreation(IconData icon, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(
            icon,
            size: 29,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ]),
    ]);
  }

  Widget emojiSelect() {
    return Expanded(
      child: EmojiPicker(
        onEmojiSelected: (Category? category, Emoji? emoji) {
          setState(() {
            _controller.text = _controller.text + emoji!.emoji;
          });
        },
        config: Config(
          columns: 5,
          verticalSpacing: 4,
        ),
      ),
    );
  }
}