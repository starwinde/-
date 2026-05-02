package com.starwinde.routinemon

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.starwinde.routinemon.bridge.DisturbanceApiImpl
import com.starwinde.routinemon.bridge.UsageApiImpl

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        UsageApi.setUp(messenger, UsageApiImpl(this))
        DisturbanceApi.setUp(messenger, DisturbanceApiImpl(this))
    }
}
