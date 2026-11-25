package com.cemilkorkmaz.altin_hesaplama

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val linkChannel = "altin_hesaplama/links"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, linkChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "open") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val url = call.argument<String>("url")
                val uri = url?.let { Uri.parse(it) }
                val scheme = uri?.scheme?.lowercase()

                // Yalnızca web bağlantılarına izin verilir.
                if (uri == null || (scheme != "https" && scheme != "http")) {
                    result.error("invalid_url", null, null)
                    return@setMethodCallHandler
                }

                try {
                    startActivity(Intent(Intent.ACTION_VIEW, uri))
                    result.success(null)
                } catch (error: Exception) {
                    result.error("open_failed", error.message, null)
                }
            }
    }
}
