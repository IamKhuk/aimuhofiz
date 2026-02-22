package uz.aisurface.firiblock

import android.os.Build
import android.telecom.Call
import android.telecom.InCallService
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * InCallService implementation required for ROLE_DIALER.
 * When Android has a call (native or VoIP), this service is bound
 * and receives Call objects for UI management.
 */
class FiribInCallService : InCallService() {

    companion object {
        private const val TAG = "FiribInCallService"
        var methodChannel: MethodChannel? = null
        var currentCall: Call? = null
    }

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        currentCall = call
        Log.d(TAG, "onCallAdded: ${call.details?.handle}")

        call.registerCallback(callCallback)

        // Notify Flutter about the call
        val number = call.details?.handle?.schemeSpecificPart ?: "Unknown"
        val direction = if (call.details?.callDirection == Call.Details.DIRECTION_INCOMING) {
            "incoming"
        } else {
            "outgoing"
        }

        methodChannel?.invokeMethod("onNativeCallAdded", mapOf(
            "number" to number,
            "direction" to direction
        ))
    }

    override fun onCallRemoved(call: Call) {
        super.onCallRemoved(call)
        Log.d(TAG, "onCallRemoved: ${call.details?.handle}")
        call.unregisterCallback(callCallback)
        currentCall = null

        methodChannel?.invokeMethod("onNativeCallRemoved", null)
    }

    private val callCallback = object : Call.Callback() {
        override fun onStateChanged(call: Call, state: Int) {
            super.onStateChanged(call, state)
            val stateStr = when (state) {
                Call.STATE_RINGING -> "RINGING"
                Call.STATE_DIALING -> "DIALING"
                Call.STATE_ACTIVE -> "ACTIVE"
                Call.STATE_HOLDING -> "HOLDING"
                Call.STATE_DISCONNECTED -> "DISCONNECTED"
                Call.STATE_CONNECTING -> "CONNECTING"
                else -> "UNKNOWN"
            }
            Log.d(TAG, "Call state changed: $stateStr")

            methodChannel?.invokeMethod("onNativeCallStateChanged", mapOf(
                "state" to stateStr,
                "number" to (call.details?.handle?.schemeSpecificPart ?: "Unknown")
            ))
        }
    }
}
