package com.gurme.gurme

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Dart tarafı haritayı açmadan önce anahtar olup olmadığını sorar.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gurme/maps")
            .setMethodCallHandler { call, result ->
                if (call.method == "isAvailable") {
                    result.success(!mapsKey().isNullOrBlank())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun mapsKey(): String? =
        packageManager
            .getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            .metaData
            ?.getString("com.google.android.geo.API_KEY")
}
