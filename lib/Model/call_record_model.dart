import 'chat_model.dart';

enum CallDirection { incoming, outgoing }

enum CallStatus { completed, missed, declined, cancelled, failed }

class CallRecordModel {
  final String id;
  final ChatModel peer;
  final CallDirection direction;
  final CallStatus status;
  final int duration;
  final DateTime createdAt;

  CallRecordModel({
    required this.id,
    required this.peer,
    required this.direction,
    required this.status,
    required this.duration,
    required this.createdAt,
  });

  factory CallRecordModel.fromJson(Map<String, dynamic> json) {
    final rawPeer = json['peer'] is Map
        ? Map<String, dynamic>.from(json['peer'] as Map)
        : <String, dynamic>{};

    final directionStr = json['direction']?.toString().toLowerCase();
    final direction = directionStr == 'incoming'
        ? CallDirection.incoming
        : CallDirection.outgoing;

    final statusStr = json['status']?.toString().toLowerCase();
    final CallStatus status;
    switch (statusStr) {
      case 'completed':
        status = CallStatus.completed;
        break;
      case 'missed':
        status = CallStatus.missed;
        break;
      case 'declined':
        status = CallStatus.declined;
        break;
      case 'cancelled':
        status = CallStatus.cancelled;
        break;
      default:
        status = CallStatus.failed;
        break;
    }

    final rawDuration = json['duration'];
    final duration = rawDuration is num
        ? rawDuration.toInt()
        : int.tryParse(rawDuration?.toString() ?? '') ?? 0;

    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();

    final idStr = (json['callId'] ?? json['id'] ?? json['_id'])?.toString() ?? '';

    return CallRecordModel(
      id: idStr,
      peer: ChatModel.fromUserJson(rawPeer),
      direction: direction,
      status: status,
      duration: duration,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callId': id,
      'peer': {
        'id': peer.id,
        'name': peer.name,
        'email': peer.email,
        'online': peer.status == 'online',
      },
      'direction': direction == CallDirection.incoming ? 'incoming' : 'outgoing',
      'status': status.name,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
