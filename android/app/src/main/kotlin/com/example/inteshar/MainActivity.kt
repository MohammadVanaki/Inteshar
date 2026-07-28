package com.dijlah.inteshar

import android.view.WindowManager
import androidx.annotation.NonNull
import com.dijlah.inteshar.security.PlayIntegrityManager
import com.dijlah.inteshar.security.SecurityBridge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.inteshar.app/security"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val securityBridge = SecurityBridge(applicationContext)
        val playIntegrityManager = PlayIntegrityManager(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkDeviceIntegrity" -> {
                    val expectedSignature = call.argument<String>("expectedSignatureSha256")
                    val auditResult = securityBridge.checkDeviceIntegrity(expectedSignature)
                    result.success(auditResult)
                }

                "requestPlayIntegrityToken" -> {
                    val nonce = call.argument<String>("nonce")
                    playIntegrityManager.requestIntegrityToken(nonce, object : PlayIntegrityManager.IntegrityCallback {
                        override fun onSuccess(token: String) {
                            result.success(token)
                        }

                        override fun onError(errorMessage: String) {
                            result.error("PLAY_INTEGRITY_ERROR", errorMessage, null)
                        }
                    })
                }

                "enableSecureScreen" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    result.success(true)
                }

                "disableSecureScreen" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
