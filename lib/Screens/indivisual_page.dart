import 'package:airmail/Model/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:airmail/DesignUI/reply_side_card.dart';
import 'package:airmail/DesignUI/user_side_card.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Screens/camera_page_indivisual.dart';
// import 'package:airmail/Screens/camera_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class IndivisualPage extends StatefulWidget {
  const IndivisualPage(
      {Key? key, required this.chatModel, required this.sourceChat})
      : super(key: key);
  final ChatModel chatModel;
  final ChatModel sourceChat;

  @override
  _IndivisualPageState createState() => _IndivisualPageState();
}

class _IndivisualPageState extends State<IndivisualPage> {
  bool showEmoji = false;
  FocusNode focusNode = FocusNode();
  late IO.Socket socket;
  bool sendButton = false;
  List<MessageModel> messages = [];

  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
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

  void connect() {
    socket = IO.io(
      'http://192.168.0.120:5000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );
    socket.connect();
    socket.onConnect(
      (data) {
        print('connected');
        socket.on("message", (msg) {
          print(msg);
          setMessage("destination", msg["message"]);
        });
      },
    );
    print(socket.connected);
    socket.emit("signin", widget.sourceChat.id);
  }

  void sendMessage(String message, var sourceId, var targetId) {
    setMessage("source", message);
    socket.emit("message",
        {"message": message, "sourceId": sourceId, "targetId": targetId});
  }

  void setMessage(String type, String message) {
    MessageModel messageModel = MessageModel(
      type: type,
      message: message,
    );
    setState(
      () {
        setState(() {
          messages.add(messageModel);
        });
      },
    );
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
                              fontSize: 18.5, fontWeight: FontWeight.bold)),
                      Text(
                        "Last seen today at ${widget.chatModel.time}",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
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
              actions: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.videocam),
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
                                      color: Colors.purpleAccent[400],
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
                                          color: Colors.purpleAccent[400],
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
                                          color: Colors.purpleAccent[400],
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
                                backgroundColor: Colors.purpleAccent[400],
                                child: IconButton(
                                  icon: Icon(
                                    sendButton ? Icons.send : Icons.mic,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (sendButton) {
                                      sendMessage(
                                        _controller.text,
                                        widget.sourceChat.id,
                                        widget.chatModel.id,
                                      );
                                      _controller.clear();
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
                    Colors.indigo,
                    "Document",
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.camera_alt,
                    Colors.pink,
                    "Camera",
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.insert_photo,
                    Colors.purple,
                    "Gallery",
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconcreation(
                    Icons.audiotrack,
                    Colors.orange,
                    "Audio",
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.location_pin,
                    Colors.pink,
                    "Location",
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.person,
                    Colors.blue,
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
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
          ),
        ),
      ]),
    );
  }

  Widget emojiSelect() {
    return Expanded(
      child: EmojiPicker(
        onEmojiSelected: (Category category, Emoji emoji) {
          setState(() {
            _controller.text = _controller.text + emoji.emoji;
          });
          config:
          Config(
            columns: 5,
            verticalSpacing: 4,
          );
        },
      ),
    );
  }
}
