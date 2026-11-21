import '../services/profile_store.dart';

class ChatModel {
  String? name;
  String? icon;
  String? avatar;
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
    this.avatar,
    this.time,
    this.status,
    this.currentMessage,
    this.id,
    this.email,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatModel.fromUserJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['_id'])?.toString();
    final avatar = (json['avatar'] ?? json['icon'])?.toString();
    if (id != null && avatar != null && avatar.isNotEmpty) {
      ProfileStore.instance.setAvatar(id, avatar);
    }
    return ChatModel(
      id: id,
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      avatar: avatar,
      icon: json['icon']?.toString(),
      status: json['online'] == true ? 'online' : 'offline',
    );
  }

  factory ChatModel.fromChatJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    final id = (user['id'] ?? user['_id'])?.toString();
    final avatar =
        (user['avatar'] ?? user['icon'] ?? json['avatar'])?.toString();
    if (id != null && avatar != null && avatar.isNotEmpty) {
      ProfileStore.instance.setAvatar(id, avatar);
    }
    final lastMessageAt =
        DateTime.tryParse(json['lastMessageAt']?.toString() ?? '');
    final rawUnread = json['unreadCount'];
    final unreadCount = rawUnread is num
        ? rawUnread.toInt()
        : int.tryParse(rawUnread?.toString() ?? '') ?? 0;

    return ChatModel(
      id: id,
      name: user['name']?.toString(),
      email: user['email']?.toString(),
      avatar: avatar,
      icon: user['icon']?.toString(),
      currentMessage: json['lastMessage']?.toString(),
      lastMessageAt: lastMessageAt,
      status: user['online'] == true ? 'online' : 'offline',
      unreadCount: unreadCount < 0 ? 0 : unreadCount,
    );
  }
}
