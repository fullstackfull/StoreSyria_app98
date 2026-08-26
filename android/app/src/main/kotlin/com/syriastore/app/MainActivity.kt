package com.syriastore.app

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "navigation_mode"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "is3ButtonNav" -> {
                    try {
                        val mode = Settings.Secure.getInt(
                            contentResolver,
                            "navigation_mode"
                        )

                        // Android:
                        // 0 = 3-button
                        // 1 = 2-button
                        // 2 = Gesture

                        result.success(mode == 0)

                    } catch (e: Exception) {
                        // إذا الجهاز/الإصدار لا يدعم قراءة navigation_mode
                        result.success(false)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}