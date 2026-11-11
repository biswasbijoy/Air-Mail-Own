class ChatModel {
  String? name;
  String? icon;
  String? time;
  String? status;
  String? currentMessage;
  String? id;
  String? email;
  DateTime? lastMessageAt;
  int unreadCount;

  ChatModel({
    this.name,
    this.icon,
    this.time,
    this.status,
    this.currentMessage,
    this.id,
    this.email,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatModel.fromUserJson(Map<String, dynamic> json) {
    return ChatModel(
      id: (json['id'] ?? json['_id'])?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      status: json['online'] == true ? 'online' : 'offline',
    );
  }

  factory ChatModel.fromChatJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    final lastMessageAt =
        DateTime.tryParse(json['lastMessageAt']?.toString() ?? '');
    final rawUnread = json['unreadCount'];
    final unreadCount = rawUnread is num
        ? rawUnread.toInt()
        : int.tryParse(rawUnread?.toString() ?? '') ?? 0;

    return ChatModel(
      id: (user['id'] ?? user['_id'])?.toString(),
      name: user['name']?.toString(),
      email: user['email']?.toString(),
      currentMessage: json['lastMessage']?.toString(),
      lastMessageAt: lastMessageAt,
      status: user['online'] == true ? 'online' : 'offline',
      unreadCount: unreadCount < 0 ? 0 : unreadCount,
    );
  }
}
