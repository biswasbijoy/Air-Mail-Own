class ChatModel {
  var name;
  var icon;
  var time;
  var status;
  var currentMessage;
  var id;
  String? email;
  ChatModel({
    required this.name,
    this.icon,
    this.time,
    this.status,
    this.currentMessage,
    this.id,
    this.email,
  });
}