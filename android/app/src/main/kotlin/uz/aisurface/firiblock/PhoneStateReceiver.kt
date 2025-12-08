package uz.aisurface.firiblock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * BroadcastReceiver that listens for phone call state changes
 * and notifies the Flutter side via MethodChannel
 */
class PhoneStateReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "PhoneStateReceiver"
        var methodChannel: MethodChannel? = null
        private var lastState = TelephonyManager.CALL_STATE_IDLE
        private var lastNumber: String? = null

        fun setChannel(channel: MethodChannel) {
            Log.d(TAG, "MethodChannel set")
            methodChannel = channel
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d(TAG, "onReceive called with action: ${intent?.action}")

        if (intent?.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED ||
            intent?.action == "android.intent.action.PHONE_STATE") {

            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            Log.d(TAG, "Phone state: $state, number: $number")

            // Get current call state
            val callState = when (state) {
                TelephonyManager.EXTRA_STATE_RINGING -> "RINGING"
                TelephonyManager.EXTRA_STATE_OFFHOOK -> "OFFHOOK"
                TelephonyManager.EXTRA_STATE_IDLE -> "IDLE"
                else -> "UNKNOWN"
            }

            // Store number if available (only comes with RINGING state)
            if (number != null && number.isNotEmpty()) {
                lastNumber = number
                Log.d(TAG, "Stored number: $lastNumber")
            }

            // Send to Flutter on main thread
            val args = hashMapOf<String, Any?>(
                "state" to callState,
                "number" to (lastNumber ?: "Unknown")
            )

            Log.d(TAG, "Sending to Flutter: state=$callState, number=${lastNumber ?: "Unknown"}")

            Handler(Looper.getMainLooper()).post {
                try {
                    methodChannel?.invokeMethod("onCallStateChanged", args)
                    Log.d(TAG, "Successfully sent to Flutter")
                } catch (e: Exception) {
                    Log.e(TAG, "Error sending to Flutter: ${e.message}")
                }
            }

            // Reset number when call ends
            if (callState == "IDLE") {
                lastNumber = null
            }
        }
    }
}
