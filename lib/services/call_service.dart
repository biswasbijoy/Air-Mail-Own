import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../Model/call_event.dart';
import '../Model/chat_model.dart';
import 'realtime_service.dart';

enum CallState { idle, outgoing, incoming, connecting, active }

class CallService extends ChangeNotifier {
  CallService._();

  static final CallService instance = CallService._();

  static const List<Map<String, dynamic>> _iceServers = [
    {
      'urls': [
        'stun:stun.l.google.com:19302',
        'stun:stun1.l.google.com:19302',
      ],
    },
  ];

  static const String _turnUrl = String.fromEnvironment('AIRMAIL_TURN_URL');
  static const String _turnUsername =
      String.fromEnvironment('AIRMAIL_TURN_USERNAME');
  static const String _turnCredential =
      String.fromEnvironment('AIRMAIL_TURN_CREDENTIAL');

  CallState _state = CallState.idle;
  ChatModel? _peer;
  String? _callId;
  bool _isCaller = false;
  bool _starting = false;
  bool _muted = false;
  bool _speakerOn = false;
  String? _lastError;
  String? _lastEndReason;
  DateTime? _connectedAt;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer? _remoteRenderer;
  final List<RTCIceCandidate> _pendingCandidates = <RTCIceCandidate>[];
  bool _remoteDescriptionSet = false;
  Future<void> _signalQueue = Future<void>.value();

  Timer? _ringTimeout;
  StreamSubscription<CallEvent>? _callSubscription;
  bool _attached = false;

  CallState get state => _state;
  ChatModel? get peer => _peer;
  bool get isCaller => _isCaller;
  bool get muted => _muted;
  bool get speakerOn => _speakerOn;
  bool get isBusy => _state != CallState.idle || _starting;
  String? get lastError => _lastError;
  String? get lastEndReason => _lastEndReason;
  DateTime? get connectedAt => _connectedAt;
  MediaStream? get remoteStream => _remoteStream;

  static List<Map<String, dynamic>> get _configuredIceServers {
    final servers = <Map<String, dynamic>>[..._iceServers];
    if (_turnUrl.isNotEmpty) {
      servers.add({
        'urls': _turnUrl.split(',').map((url) => url.trim()).toList(),
        'username': _turnUsername,
        'credential': _turnCredential,
      });
    }
    return servers;
  }

  void attach() {
    if (_attached) return;
    _attached = true;
    _callSubscription =
        RealtimeService.instance.callEvents.listen(_handleCallEvent);
    RealtimeService.instance.connected.addListener(_handleConnectionChanged);
  }

  void detach() {
    if (!_attached) return;
    _attached = false;
    _callSubscription?.cancel();
    _callSubscription = null;
    RealtimeService.instance.connected.removeListener(_handleConnectionChanged);

    final callId = _callId;
    if (callId != null) {
      RealtimeService.instance.endCall(callId);
    }
    unawaited(_teardown());
  }

  Future<bool> startCall(ChatModel peer) async {
    if (isBusy) {
      _lastError = 'You are already in a call.';
      notifyListeners();
      return false;
    }

    final receiverId = peer.id;
    if (receiverId == null || receiverId.isEmpty) {
      _lastError = 'This contact cannot be called.';
      notifyListeners();
      return false;
    }

    _starting = true;
    _peer = peer;
    _isCaller = true;
    _lastError = null;
    _lastEndReason = null;
    _muted = false;
    _speakerOn = false;

    try {
      await _preparePeer();

      final response = await RealtimeService.instance.inviteCall(receiverId);
      if (response['ok'] != true) {
        throw _CallFailure(
          response['error']?.toString() ?? 'Could not start the call.',
        );
      }

      final callId = response['callId']?.toString();
      if (callId == null || callId.isEmpty) {
        throw const _CallFailure('The server did not return a call id.');
      }

      _callId = callId;
      _state = CallState.outgoing;
      _armRingTimeout();
      return true;
    } catch (error) {
      _lastError = _messageFor(error);
      await _teardown(notify: false);
      return false;
    } finally {
      _starting = false;
      notifyListeners();
    }
  }

  Future<bool> acceptCall() async {
    final callId = _callId;
    if (_state != CallState.incoming || callId == null) return false;

    _state = CallState.connecting;
    notifyListeners();

    try {
      await _preparePeer();
      final response = await RealtimeService.instance.acceptCall(callId);
      if (response['ok'] != true) {
        throw _CallFailure(
          response['error']?.toString() ?? 'Could not answer the call.',
        );
      }
      _cancelRingTimeout();
      return true;
    } catch (error) {
      _lastError = _messageFor(error);
      unawaited(RealtimeService.instance.rejectCall(callId));
      await _teardown(notify: false);
      notifyListeners();
      return false;
    }
  }

  Future<void> declineCall() async {
    final callId = _callId;
    if (_state != CallState.incoming || callId == null) return;

    _lastEndReason = 'Call declined';
    unawaited(RealtimeService.instance.rejectCall(callId));
    await _teardown();
  }

  Future<void> endCall({String? reason}) async {
    final callId = _callId;
    if (callId == null) {
      if (_state != CallState.idle) {
        _lastEndReason = reason ?? 'Call ended';
        await _teardown();
      }
      return;
    }

    RealtimeService.instance.endCall(callId);
    _lastEndReason = reason ??
        (_state == CallState.active ? 'Call ended' : 'Call cancelled');
    await _teardown();
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    final tracks = _localStream?.getAudioTracks() ?? const <MediaStreamTrack>[];
    for (final track in tracks) {
      track.enabled = !_muted;
    }
    notifyListeners();
  }

  Future<void> toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _applySpeaker(_speakerOn);
    notifyListeners();
  }

  Future<void> _preparePeer() async {
    await _closePeer();

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await Helper.ensureAudioSession();
    }

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });

    _peerConnection = await createPeerConnection({
      'iceServers': _configuredIceServers,
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    });

    final connection = _peerConnection!;
    connection.onIceCandidate = _handleLocalCandidate;
    connection.onConnectionState = _handleConnectionState;
    connection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        unawaited(_attachRemoteStream(event.streams.first));
      }
    };

    for (final track in _localStream!.getAudioTracks()) {
      await connection.addTrack(track, _localStream!);
    }

    await _applySpeaker(false);
  }

  void _handleLocalCandidate(RTCIceCandidate candidate) {
    final callId = _callId;
    if (callId == null || _state == CallState.idle) return;

    final value = candidate.candidate;
    if (value == null || value.isEmpty) return;

    RealtimeService.instance.sendCallSignal(callId, {
      'type': 'candidate',
      'candidate': value,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  void _handleConnectionState(RTCPeerConnectionState connectionState) {
    switch (connectionState) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        if (_state == CallState.idle) return;
        _cancelRingTimeout();
        _connectedAt = DateTime.now();
        _state = CallState.active;
        notifyListeners();
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        if (_state == CallState.idle) return;
        unawaited(endCall(reason: 'Connection failed'));
        break;
      default:
        break;
    }
  }

  void _handleCallEvent(CallEvent event) {
    switch (event.type) {
      case CallEventType.incoming:
        unawaited(_handleIncoming(event));
        break;
      case CallEventType.accepted:
        unawaited(_handleAccepted(event));
        break;
      case CallEventType.ended:
        unawaited(_handleRemoteEnded(event));
        break;
      case CallEventType.signal:
        _queueSignal(event);
        break;
    }
  }

  Future<void> _handleIncoming(CallEvent event) async {
    final callId = event.callId;
    final caller = event.peer;
    if (callId == null || caller?.id == null) return;

    if (isBusy) {
      unawaited(RealtimeService.instance.rejectCall(callId));
      return;
    }

    _peer = caller;
    _callId = callId;
    _isCaller = false;
    _state = CallState.incoming;
    _lastError = null;
    _lastEndReason = null;
    _muted = false;
    _speakerOn = false;
    _armRingTimeout();
    notifyListeners();
  }

  Future<void> _handleAccepted(CallEvent event) async {
    if (event.callId != _callId || !_isCaller) return;
    if (_state != CallState.outgoing) return;

    _cancelRingTimeout();
    _state = CallState.connecting;
    notifyListeners();

    try {
      await _sendOffer();
    } catch (error) {
      _lastError = _messageFor(error);
      unawaited(_failCall('Could not establish the call.'));
    }
  }

  Future<void> _handleRemoteEnded(CallEvent event) async {
    if (event.callId != _callId || _state == CallState.idle) return;

    _lastEndReason = event.reason ?? 'Call ended';
    await _teardown();
  }

  void _queueSignal(CallEvent event) {
    _signalQueue = _signalQueue.then((_) => _handleSignal(event)).catchError(
      (Object error, StackTrace stack) {
        debugPrint('Call signal error: $error');
      },
    );
  }

  Future<void> _handleSignal(CallEvent event) async {
    if (event.callId != _callId || _state == CallState.idle) return;

    final data = event.data;
    final type = data?['type']?.toString();
    if (data == null || type == null) return;

    final connection = _peerConnection;
    if (connection == null) return;

    switch (type) {
      case 'offer':
        if (_isCaller) return;
        final sdp = data['sdp']?.toString();
        if (sdp == null || sdp.isEmpty) return;
        await connection.setRemoteDescription(
          RTCSessionDescription(sdp, 'offer'),
        );
        _remoteDescriptionSet = true;
        await _flushPendingCandidates();
        final answer = await connection.createAnswer();
        await connection.setLocalDescription(answer);
        final callId = _callId;
        if (callId != null) {
          RealtimeService.instance.sendCallSignal(callId, {
            'type': answer.type,
            'sdp': answer.sdp,
          });
        }
        break;
      case 'answer':
        if (!_isCaller) return;
        final sdp = data['sdp']?.toString();
        if (sdp == null || sdp.isEmpty) return;
        await connection.setRemoteDescription(
          RTCSessionDescription(sdp, 'answer'),
        );
        _remoteDescriptionSet = true;
        await _flushPendingCandidates();
        break;
      case 'candidate':
        final candidate = data['candidate']?.toString();
        if (candidate == null || candidate.isEmpty) return;
        final iceCandidate = RTCIceCandidate(
          candidate,
          data['sdpMid']?.toString(),
          (data['sdpMLineIndex'] as num?)?.toInt(),
        );
        if (!_remoteDescriptionSet) {
          _pendingCandidates.add(iceCandidate);
        } else {
          await connection.addCandidate(iceCandidate);
        }
        break;
    }
  }

  Future<void> _sendOffer() async {
    final connection = _peerConnection;
    final callId = _callId;
    if (connection == null || callId == null) {
      throw const _CallFailure('Call session is not ready.');
    }

    final offer = await connection.createOffer();
    await connection.setLocalDescription(offer);
    RealtimeService.instance.sendCallSignal(callId, {
      'type': offer.type,
      'sdp': offer.sdp,
    });
  }

  Future<void> _flushPendingCandidates() async {
    final connection = _peerConnection;
    if (connection == null) return;

    final candidates = List<RTCIceCandidate>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final candidate in candidates) {
      await connection.addCandidate(candidate);
    }
  }

  Future<void> _attachRemoteStream(MediaStream stream) async {
    _remoteStream = stream;
    if (!kIsWeb) return;

    var renderer = _remoteRenderer;
    if (renderer == null) {
      renderer = RTCVideoRenderer();
      await renderer.initialize();
      if (_remoteStream != stream || _state == CallState.idle) {
        await renderer.dispose();
        return;
      }
      _remoteRenderer = renderer;
    }
    if (_remoteStream == stream) {
      renderer.srcObject = stream;
    }
  }

  Future<void> _disposeRemoteRenderer() async {
    final renderer = _remoteRenderer;
    _remoteRenderer = null;
    if (renderer != null) {
      renderer.srcObject = null;
      await renderer.dispose();
    }
  }

  Future<void> _failCall(String reason) async {
    final callId = _callId;
    if (callId != null) {
      RealtimeService.instance.endCall(callId);
    }
    _lastEndReason = reason;
    await _teardown();
  }

  void _armRingTimeout() {
    _cancelRingTimeout();
    _ringTimeout = Timer(const Duration(seconds: 50), () {
      if (_state == CallState.outgoing || _state == CallState.incoming) {
        unawaited(_failCall('No answer'));
      }
    });
  }

  void _cancelRingTimeout() {
    _ringTimeout?.cancel();
    _ringTimeout = null;
  }

  void _handleConnectionChanged() {
    if (RealtimeService.instance.connected.value) return;
    if (_callId == null) return;

    _lastEndReason = 'Connection lost';
    unawaited(_teardown());
  }

  Future<void> _teardown({bool notify = true}) async {
    _cancelRingTimeout();
    _callId = null;
    _isCaller = false;
    _state = CallState.idle;
    _connectedAt = null;
    _muted = false;
    _speakerOn = false;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
    _remoteStream = null;
    await _disposeRemoteRenderer();

    final stream = _localStream;
    final connection = _peerConnection;
    _localStream = null;
    _peerConnection = null;

    if (stream != null) {
      for (final track in stream.getTracks()) {
        await track.stop();
      }
      await stream.dispose();
    }
    if (connection != null) {
      await connection.close();
      await connection.dispose();
    }

    if (!kIsWeb) {
      try {
        await Helper.setSpeakerphoneOn(false);
      } catch (_) {}
    }

    if (notify) notifyListeners();
  }

  Future<void> _closePeer() async {
    final stream = _localStream;
    final connection = _peerConnection;
    _localStream = null;
    _peerConnection = null;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
    _remoteStream = null;
    await _disposeRemoteRenderer();

    if (stream != null) {
      for (final track in stream.getTracks()) {
        await track.stop();
      }
      await stream.dispose();
    }
    if (connection != null) {
      await connection.close();
      await connection.dispose();
    }
  }

  Future<void> _applySpeaker(bool enabled) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await Helper.setSpeakerphoneOn(enabled);
    } catch (_) {}
  }

  String _messageFor(Object error) {
    if (error is _CallFailure) return error.message;
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}

class _CallFailure implements Exception {
  const _CallFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
