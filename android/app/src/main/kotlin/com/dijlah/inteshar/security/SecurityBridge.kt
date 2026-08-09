package com.dijlah.inteshar.security

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.net.Socket
import java.security.MessageDigest

class SecurityBridge(private val context: Context) {

    companion object {
        private const val TAG = "SecurityBridge"
    }

    /**
     * Performs a comprehensive device security audit returning a Map of results.
     */
    fun checkDeviceIntegrity(expectedSignatureSha256: String?): Map<String, Any> {
        val isRooted = checkRoot()
        val isEmulator = checkEmulator()
        val isFridaDetected = checkFrida()
        val signatureResult = checkApkSignature(expectedSignatureSha256)

        Log.d(TAG, "===============================================")
        Log.d(TAG, "🔒 Security Audit Completed:")
        Log.d(TAG, "   Is Rooted: $isRooted")
        Log.d(TAG, "   Is Emulator: $isEmulator")
        Log.d(TAG, "   Is Frida Detected: $isFridaDetected")
        Log.d(TAG, "   Is Signature Valid: ${signatureResult["isValid"]}")
        Log.d(TAG, "   Current Signature SHA-256: ${signatureResult["sha256"]}")
        Log.d(TAG, "===============================================")

        return mapOf(
            "isRooted" to isRooted,
            "isEmulator" to isEmulator,
            "isFridaDetected" to isFridaDetected,
            "isSignatureValid" to (signatureResult["isValid"] ?: true),
            "currentSignatureSha256" to (signatureResult["sha256"] ?: ""),
            "installerPackage" to (getInstallerPackageName() ?: "unknown")
        )
    }

    /**
     * 1. Root Detection
     */
    private fun checkRoot(): Boolean {
        val suPaths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/data/adb/magisk",
            "/sbin/.magisk"
        )

        for (path in suPaths) {
            if (File(path).exists()) {
                Log.w(TAG, "🚨 Root check trigger: Found su binary at $path")
                return true
            }
        }

        val buildTags = Build.TAGS
        if (buildTags != null && buildTags.contains("test-keys")) {
            Log.w(TAG, "🚨 Root check trigger: Build.TAGS contains test-keys")
            return true
        }

        return try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val inReader = BufferedReader(java.io.InputStreamReader(process.inputStream))
            val hasSu = inReader.readLine() != null
            if (hasSu) Log.w(TAG, "🚨 Root check trigger: Executed su command successfully")
            hasSu
        } catch (e: Exception) {
            false
        }
    }

    /**
     * 2. Emulator Detection (Comprehensive API 21-35+)
     */
    private fun checkEmulator(): Boolean {
        Log.d(TAG, "🔍 Checking Emulator Specs:")
        Log.d(TAG, "   Build.FINGERPRINT: ${Build.FINGERPRINT}")
        Log.d(TAG, "   Build.MODEL: ${Build.MODEL}")
        Log.d(TAG, "   Build.MANUFACTURER: ${Build.MANUFACTURER}")
        Log.d(TAG, "   Build.BRAND: ${Build.BRAND}")
        Log.d(TAG, "   Build.DEVICE: ${Build.DEVICE}")
        Log.d(TAG, "   Build.PRODUCT: ${Build.PRODUCT}")
        Log.d(TAG, "   Build.HARDWARE: ${Build.HARDWARE}")
        Log.d(TAG, "   Build.BOARD: ${Build.BOARD}")
        Log.d(TAG, "   Build.HOST: ${Build.HOST}")

        // 1. Build Property Checks
        val checkBuildProps = (Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.FINGERPRINT.contains("google/sdk_gphone")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MODEL.contains("Medium Phone")
                || Build.MODEL.lowercase().contains("sdk")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.HOST.startsWith("Build")
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || "google_sdk" == Build.PRODUCT
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("google_sdk")
                || Build.PRODUCT.contains("sdk_gphone")
                || Build.PRODUCT.contains("vbox86p")
                || Build.PRODUCT.contains("emulator")
                || Build.PRODUCT.contains("simulator")
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.HARDWARE.contains("vbox86")
                || Build.HARDWARE.lowercase().contains("nox")
                || Build.BOARD.contains("goldfish")
                || Build.BOARD.contains("vbox86"))

        if (checkBuildProps) {
            Log.w(TAG, "🚨 Emulator detected via Build Properties!")
            return true
        }

        // 2. QEMU / Emulator Driver Files Check
        val qemuFiles = arrayOf(
            "/dev/socket/qemud",
            "/dev/qemu_pipe",
            "/system/lib/libc_malloc_debug_qemu.so",
            "/sys/qemu_trace",
            "/system/bin/qemu-props"
        )
        for (file in qemuFiles) {
            if (File(file).exists()) {
                Log.w(TAG, "🚨 Emulator detected via QEMU file: $file")
                return true
            }
        }

        // 3. System Property Check
        try {
            val systemPropClass = Class.forName("android.os.SystemProperties")
            val getMethod = systemPropClass.getMethod("get", String::class.java)
            val qemuProp = getMethod.invoke(null, "ro.kernel.qemu") as? String
            val hardwareProp = getMethod.invoke(null, "ro.hardware") as? String

            if ("1" == qemuProp || "goldfish" == hardwareProp || "ranchu" == hardwareProp) {
                Log.w(TAG, "🚨 Emulator detected via SystemProperties: ro.kernel.qemu=$qemuProp, ro.hardware=$hardwareProp")
                return true
            }
        } catch (ignored: Exception) {
        }

        // 4. Proc CPU Info Check
        try {
            val cpuInfo = File("/proc/cpuinfo")
            if (cpuInfo.exists()) {
                val reader = BufferedReader(FileReader(cpuInfo))
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    val lowerLine = line?.lowercase() ?: ""
                    if (lowerLine.contains("intel") || lowerLine.contains("amd") || lowerLine.contains("goldfish")) {
                        // Many x86 host emulators show Intel/AMD in cpuinfo
                        if (lowerLine.contains("goldfish") || lowerLine.contains("qemu")) {
                            reader.close()
                            Log.w(TAG, "🚨 Emulator detected via /proc/cpuinfo!")
                            return true
                        }
                    }
                }
                reader.close()
            }
        } catch (ignored: Exception) {
        }

        return false
    }

    /**
     * 3. Frida / Hooking Detection
     */
    private fun checkFrida(): Boolean {
        val defaultPorts = intArrayOf(27042, 27043)
        for (port in defaultPorts) {
            try {
                val socket = Socket("127.0.0.1", port)
                socket.close()
                Log.w(TAG, "🚨 Frida detected via open port $port")
                return true
            } catch (ignored: Exception) {
            }
        }

        try {
            val mapsFile = File("/proc/self/maps")
            if (mapsFile.exists()) {
                val reader = BufferedReader(FileReader(mapsFile))
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    val lowerLine = line?.lowercase() ?: ""
                    if (lowerLine.contains("frida") ||
                        lowerLine.contains("gadget") ||
                        lowerLine.contains("xposed") ||
                        lowerLine.contains("substrate")
                    ) {
                        reader.close()
                        Log.w(TAG, "🚨 Frida/Hooking library detected in memory maps: $line")
                        return true
                    }
                }
                reader.close()
            }
        } catch (ignored: Exception) {
        }

        val tempFiles = arrayOf(
            "/data/local/tmp/frida-server",
            "/data/local/tmp/re.frida.server"
        )
        for (filePath in tempFiles) {
            if (File(filePath).exists()) {
                Log.w(TAG, "🚨 Frida server binary detected at $filePath")
                return true
            }
        }

        return false
    }

    /**
     * 4. Runtime Integrity & APK Signature Verification
     */
    private fun checkApkSignature(expectedSignatureSha256: String?): Map<String, Any> {
        try {
            var signatures: Array<out android.content.pm.Signature>? = null

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                try {
                    val packageInfo = context.packageManager.getPackageInfo(
                        context.packageName,
                        PackageManager.GET_SIGNING_CERTIFICATES
                    )
                    val signingInfo = packageInfo.signingInfo
                    if (signingInfo != null) {
                        if (!signingInfo.signingCertificateHistory.isNullOrEmpty()) {
                            signatures = signingInfo.signingCertificateHistory
                        } else if (!signingInfo.apkContentsSigners.isNullOrEmpty()) {
                            signatures = signingInfo.apkContentsSigners
                        }
                    }
                } catch (ignored: Exception) {}
            }

            if (signatures.isNullOrEmpty()) {
                @Suppress("DEPRECATION")
                val legacyPackageInfo = context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
                @Suppress("DEPRECATION")
                signatures = legacyPackageInfo.signatures
            }

            if (signatures.isNullOrEmpty()) {
                Log.e(TAG, "🚨 Could not extract APK signatures from PackageManager!")
                return mapOf("isValid" to false, "sha256" to "")
            }

            val currentSha256List = signatures.map { sig ->
                val certBytes = sig.toByteArray()
                val md = MessageDigest.getInstance("SHA-256")
                val digest = md.digest(certBytes)
                digest.joinToString("") { "%02X".format(it) }.uppercase()
            }
            val primarySha256 = currentSha256List.firstOrNull() ?: ""

            Log.d(TAG, "🔑 Extracted Runtime APK Signatures SHA-256: $currentSha256List")

            if (!expectedSignatureSha256.isNullOrBlank()) {
                val allowedSignatures = expectedSignatureSha256.split(",", "|", ";")
                    .map { it.replace(":", "").replace(" ", "").trim().uppercase() }
                    .filter { it.isNotEmpty() }

                val isValid = currentSha256List.any { allowedSignatures.contains(it) }
                if (!isValid) {
                    Log.e(TAG, "🚨 APK Signature Mismatch!")
                    Log.e(TAG, "🚨 Current Runtime Signatures: $currentSha256List")
                    Log.e(TAG, "🚨 Allowed Signatures List: $allowedSignatures")
                }
                return mapOf("isValid" to isValid, "sha256" to primarySha256)
            }

            return mapOf("isValid" to true, "sha256" to primarySha256)
        } catch (e: Exception) {
            Log.e(TAG, "🚨 Error in checkApkSignature: ${e.message}", e)
            return mapOf("isValid" to false, "sha256" to "", "error" to (e.message ?: ""))
        }
    }

    private fun getInstallerPackageName(): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                context.packageManager.getInstallSourceInfo(context.packageName).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getInstallerPackageName(context.packageName)
            }
        } catch (e: Exception) {
            null
        }
    }
}
