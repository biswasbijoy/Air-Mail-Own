package com.example.airmail

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SHARE_CHANNEL = "com.example.airmail/share"
    private val BG_CHANNEL = "com.example.airmail/background"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "share") {
                val text = call.argument<String>("text")
                val title = call.argument<String>("title") ?: "Invite friends to AirMail"
                if (text != null) {
                    val sendIntent = Intent().apply {
                        action = Intent.ACTION_SEND
                        putExtra(Intent.EXTRA_TEXT, text)
                        type = "text/plain"
                    }
                    val shareIntent = Intent.createChooser(sendIntent, title)
                    startActivity(shareIntent)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BG_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    AirMailForegroundService.start(applicationContext)
                    result.success(true)
                }
                "stopService" -> {
                    AirMailForegroundService.stop(applicationContext)
                    result.success(true)
                }
                "bringToForeground" -> {
                    try {
                        val intent = Intent(applicationContext, MainActivity::class.java).apply {
                            action = Intent.ACTION_MAIN
                            addCategory(Intent.CATEGORY_LAUNCHER)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
