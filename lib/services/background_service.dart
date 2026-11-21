import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BackgroundService {
  BackgroundService._();
  static const MethodChannel _channel =
      MethodChannel('com.example.airmail/background');

  static Future<void> start() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('startService');
    } catch (e) {
      debugPrint('BackgroundService start error: $e');
    }
  }

  static Future<void> stop() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('stopService');
    } catch (e) {
      debugPrint('BackgroundService stop error: $e');
    }
  }

  static Future<void> bringToForeground() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('bringToForeground');
    } catch (e) {
      debugPrint('BackgroundService bringToForeground error: $e');
    }
  }
}
