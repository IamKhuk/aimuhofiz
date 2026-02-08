package uz.aisurface.firiblock

import android.content.Context
import android.app.role.RoleManager
import android.content.Intent
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
    private val CHANNEL_CALL_STATE = "uz.aisurface.firiblock/call_state"
    private val CHANNEL_CALL_SCREENING = "call_screening"
    private val CHANNEL_CALL_SCREENING_PERMISSION = "call_screening_permission"
    private var phoneStateReceiver: PhoneStateReceiver? = null
    private var callManager: CallManager? = null
    private var callScreeningChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "configureFlutterEngine called")

        callManager = CallManager(this)

        // Call State channel
        val callStateChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_CALL_STATE)
        PhoneStateReceiver.setChannel(callStateChannel)
        Log.d(TAG, "MethodChannel configured")

        callStateChannel.setMethodCallHandler { call, result ->
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

        // Call Screening channel
        callScreeningChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_CALL_SCREENING)
        Companion.callScreeningChannel = callScreeningChannel
        callScreeningChannel?.setMethodCallHandler { call, result ->
            if (call.method == "onIncomingCall") {
                val number = call.argument<String>("number")
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Call Screening Permission channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_CALL_SCREENING_PERMISSION)
            .setMethodCallHandler { call, result ->
                if (call.method == "request_call_screening") {
                    requestCallScreening()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate called")
        registerPhoneStateReceiver()
    }

    private fun registerPhoneStateReceiver() {
        try {
            phoneStateReceiver = PhoneStateReceiver()
            val filter = IntentFilter().apply {
                addAction(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
                addAction("android.intent.action.PHONE_STATE")
            }

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
        phoneStateReceiver?.let {
            try {
                unregisterReceiver(it)
                Log.d(TAG, "Receiver unregistered")
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering receiver: ${e.message}")
            }
        }
    }

    private fun requestCallScreening() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            if (roleManager != null && !roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                startActivityForResult(intent, REQUEST_CALL_SCREENING)
            }
        }
    }

    companion object {
        private const val REQUEST_CALL_SCREENING = 1001
        var callScreeningChannel: MethodChannel? = null
    }
}
