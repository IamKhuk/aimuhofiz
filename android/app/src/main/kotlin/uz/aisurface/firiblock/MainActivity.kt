package uz.aisurface.firiblock

import android.content.Context
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "com.firiblock.app/call_state"
    private var phoneStateReceiver: PhoneStateReceiver? = null
    private var callManager: CallManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "configureFlutterEngine called")

        // Initialize CallManager
        callManager = CallManager(this)

        // Set up MethodChannel
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        PhoneStateReceiver.setChannel(channel)
        Log.d(TAG, "MethodChannel configured")

        // Handle method calls from Flutter
        channel.setMethodCallHandler { call, result ->
            Log.d(TAG, "Method call received: ${call.method}")
            when (call.method) {
                "endCall" -> {
                    val success = callManager?.endCall() ?: false
                    Log.d(TAG, "endCall result: $success")
                    result.success(success)
                }
                "isCallActive" -> {
                    val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
                    val isActive = telephonyManager.callState != TelephonyManager.CALL_STATE_IDLE
                    Log.d(TAG, "isCallActive result: $isActive")
                    result.success(isActive)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate called")

        // Register phone state receiver
        registerPhoneStateReceiver()
    }

    private fun registerPhoneStateReceiver() {
        try {
            phoneStateReceiver = PhoneStateReceiver()
            val filter = IntentFilter().apply {
                addAction(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
                addAction("android.intent.action.PHONE_STATE")
            }

            // For Android 12+ (API 31+), we need to specify receiver flags
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(phoneStateReceiver, filter, Context.RECEIVER_EXPORTED)
                Log.d(TAG, "Registered receiver with RECEIVER_EXPORTED flag (Android 13+)")
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                registerReceiver(phoneStateReceiver, filter)
                Log.d(TAG, "Registered receiver (Android 8-12)")
            } else {
                registerReceiver(phoneStateReceiver, filter)
                Log.d(TAG, "Registered receiver (Android <8)")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error registering phone state receiver: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy called")
        // Unregister receiver
        phoneStateReceiver?.let {
            try {
                unregisterReceiver(it)
                Log.d(TAG, "Receiver unregistered")
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering receiver: ${e.message}")
            }
        }
    }
}
