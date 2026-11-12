import 'chat_model.dart';

enum CallEventType { incoming, accepted, ended, signal }

class CallEvent {
  const CallEvent({
    required this.type,
    this.callId,
    this.callType = 'audio',
    this.peer,
    this.reason,
    this.from,
    this.data,
  });

  final CallEventType type;
  final String? callId;
  final String callType;
  final ChatModel? peer;
  final String? reason;
  final String? from;
  final Map<String, dynamic>? data;

  static CallEvent? fromSocketEvent(String event, Map<String, dynamic> data) {
    final callId = data['callId']?.toString();
    if (callId == null || callId.isEmpty) return null;

    switch (event) {
      case 'call_incoming':
        final caller = data['caller'];
        if (caller is! Map) return null;
        final peer = ChatModel.fromUserJson(
          Map<String, dynamic>.from(caller),
        );
        if (peer.id == null || peer.id!.isEmpty) return null;
        return CallEvent(
          type: CallEventType.incoming,
          callId: callId,
          callType: data['callType']?.toString() ?? 'audio',
          peer: peer,
        );
      case 'call_accepted':
        return CallEvent(
          type: CallEventType.accepted,
          callId: callId,
          callType: data['callType']?.toString() ?? 'audio',
        );
      case 'call_ended':
        return CallEvent(
          type: CallEventType.ended,
          callId: callId,
          reason: data['reason']?.toString() ?? 'Call ended',
        );
      case 'webrtc_signal':
        final signal = data['data'];
        if (signal is! Map) return null;
        return CallEvent(
          type: CallEventType.signal,
          callId: callId,
          from: data['from']?.toString(),
          data: Map<String, dynamic>.from(signal),
        );
      default:
        return null;
    }
  }
}
