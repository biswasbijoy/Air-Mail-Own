import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'settings_service.dart';

class NotificationSoundService {
  NotificationSoundService._();
  static final NotificationSoundService instance =
      NotificationSoundService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  AudioPlayer? _ringPlayer;
  AudioPlayer? _chimePlayer;

  Timer? _vibrationTimer;
  bool _isRinging = false;
  bool _initialized = false;

  VoidCallback? onReturnToCall;

  static const int callNotificationId = 8888;
  static const int messageNotificationBaseId = 1000;
  static int _messageCount = 0;

  static Uint8List? _ringtoneWav;
  static Uint8List? _chimeWav;
  static Uint8List? _ringbackWav;

  Future<void> init() async {
    if (_initialized) return;

    try {
      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.id == callNotificationId) {
            onReturnToCall?.call();
          }
        },
      );

      // Pre-synthesize tone wav bytes
      _ringtoneWav ??= _generateToneWav(
        frequencies: [440.0, 480.0],
        durationMs: 1600,
        pauseMs: 1400,
      );
      _chimeWav ??= _generateChimeWav();
      _ringbackWav ??= _generateToneWav(
        frequencies: [440.0, 480.0],
        durationMs: 1200,
        pauseMs: 2000,
      );

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationSoundService init error: $e');
    }
  }

  // --- Sound & Ringtone Handling ---

  Future<void> startIncomingRingtone() async {
    stopAllSounds();
    _isRinging = true;

    final settings = SettingsService.instance;

    // Start periodic vibration if enabled
    if (settings.vibrate) {
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
        if (!_isRinging) return;
        HapticFeedback.vibrate();
      });
      HapticFeedback.vibrate();
    }

    // Play ringtone audio if enabled
    if (settings.sound) {
      try {
        _ringPlayer = AudioPlayer();
        await _ringPlayer?.setReleaseMode(ReleaseMode.loop);
        if (_ringtoneWav != null) {
          await _ringPlayer?.play(BytesSource(_ringtoneWav!));
        } else {
          SystemSound.play(SystemSoundType.alert);
        }
      } catch (_) {
        SystemSound.play(SystemSoundType.alert);
      }
    }
  }

  Future<void> startOutgoingRingback() async {
    stopAllSounds();
    _isRinging = true;

    if (SettingsService.instance.sound) {
      try {
        _ringPlayer = AudioPlayer();
        await _ringPlayer?.setReleaseMode(ReleaseMode.loop);
        if (_ringbackWav != null) {
          await _ringPlayer?.play(BytesSource(_ringbackWav!));
        }
      } catch (_) {}
    }
  }

  Future<void> playMessageChime() async {
    final settings = SettingsService.instance;
    if (settings.vibrate) {
      HapticFeedback.mediumImpact();
    }
    if (settings.sound) {
      try {
        _chimePlayer?.stop();
        _chimePlayer?.dispose();
        _chimePlayer = AudioPlayer();
        if (_chimeWav != null) {
          await _chimePlayer?.play(BytesSource(_chimeWav!));
        } else {
          SystemSound.play(SystemSoundType.alert);
        }
      } catch (_) {
        SystemSound.play(SystemSoundType.alert);
      }
    }
  }

  void stopAllSounds() {
    _isRinging = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;

    try {
      _ringPlayer?.stop();
      _ringPlayer?.dispose();
      _ringPlayer = null;
    } catch (_) {}
  }

  // --- System Notifications ---

  Future<void> showMessageNotification({
    required String senderName,
    required String message,
    String? senderId,
  }) async {
    if (!SettingsService.instance.notifications) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'airmail_messages',
        'Messages',
        channelDescription: 'Notifications for incoming chat messages',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final id = messageNotificationBaseId + (++_messageCount % 50);
      await _notifications.show(
        id: id,
        title: senderName.isEmpty ? 'New Message' : senderName,
        body: message,
        notificationDetails: details,
        payload: senderId,
      );
    } catch (e) {
      debugPrint('Show message notification error: $e');
    }
  }

  Future<void> showIncomingCallNotification({required String callerName}) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'airmail_calls',
        'Incoming Calls',
        channelDescription: 'Notifications for incoming calls',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.call,
        ongoing: true,
        autoCancel: false,
        fullScreenIntent: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        id: callNotificationId,
        title: 'Incoming Call',
        body: '$callerName is calling you on AirMail',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Show call notification error: $e');
    }
  }

  Future<void> showActiveCallNotification({
    required String peerName,
    required String durationText,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'airmail_calls',
        'Active Call',
        channelDescription: 'Ongoing audio call in progress',
        importance: Importance.low,
        priority: Priority.low,
        category: AndroidNotificationCategory.call,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      await _notifications.show(
        id: callNotificationId,
        title: 'AirMail Call ($durationText)',
        body: 'Call in progress with $peerName (Tap to return)',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Show active call notification error: $e');
    }
  }

  Future<void> cancelCallNotification() async {
    try {
      await _notifications.cancel(id: callNotificationId);
    } catch (_) {}
  }

  // --- Synthesis of tone WAV buffers ---

  static Uint8List _generateToneWav({
    required List<double> frequencies,
    required int durationMs,
    required int pauseMs,
  }) {
    const sampleRate = 22050;
    final toneSamples = (sampleRate * (durationMs / 1000.0)).round();
    final pauseSamples = (sampleRate * (pauseMs / 1000.0)).round();
    final totalSamples = toneSamples + pauseSamples;
    final byteData = ByteData(44 + totalSamples * 2);

    // Write WAV Header
    byteData.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    byteData.setUint32(4, 36 + totalSamples * 2, Endian.little);
    byteData.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    byteData.setUint32(12, 0x666d7420, Endian.big); // "fmt "
    byteData.setUint32(16, 16, Endian.little); // PCM chunk size
    byteData.setUint16(20, 1, Endian.little); // Audio format: PCM
    byteData.setUint16(22, 1, Endian.little); // Channels: 1 (Mono)
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little); // Byte rate
    byteData.setUint16(32, 2, Endian.little); // Block align
    byteData.setUint16(34, 16, Endian.little); // Bits per sample
    byteData.setUint32(36, 0x64617461, Endian.big); // "data"
    byteData.setUint32(40, totalSamples * 2, Endian.little);

    // Tone PCM samples
    int offset = 44;
    for (int i = 0; i < toneSamples; i++) {
      double sample = 0;
      for (final freq in frequencies) {
        sample += sin(2 * pi * freq * i / sampleRate);
      }
      sample /= frequencies.length;
      // Apply smooth attack & release envelope to prevent clicking
      final double env;
      if (i < 200) {
        env = i / 200.0;
      } else if (i > toneSamples - 200) {
        env = (toneSamples - i) / 200.0;
      } else {
        env = 1.0;
      }
      final int val = (sample * env * 16000).clamp(-32768, 32767).toInt();
      byteData.setInt16(offset, val, Endian.little);
      offset += 2;
    }

    // Silence PCM samples
    for (int i = 0; i < pauseSamples; i++) {
      byteData.setInt16(offset, 0, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  static Uint8List _generateChimeWav() {
    const sampleRate = 22050;
    const durationMs = 380;
    final totalSamples = (sampleRate * (durationMs / 1000.0)).round();
    final byteData = ByteData(44 + totalSamples * 2);

    byteData.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    byteData.setUint32(4, 36 + totalSamples * 2, Endian.little);
    byteData.setUint32(8, 0x57415645, Endian.big);
    byteData.setUint32(12, 0x666d7420, Endian.big);
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, 1, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);
    byteData.setUint32(36, 0x64617461, Endian.big);
    byteData.setUint32(40, totalSamples * 2, Endian.little);

    int offset = 44;
    final half = totalSamples ~/ 2;
    for (int i = 0; i < totalSamples; i++) {
      final freq = i < half ? 587.33 : 880.0; // D5 -> A5 chime
      final sample = sin(2 * pi * freq * i / sampleRate);
      final decay = exp(-i / (sampleRate * 0.12));
      final val = (sample * decay * 22000).clamp(-32768, 32767).toInt();
      byteData.setInt16(offset, val, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }
}
