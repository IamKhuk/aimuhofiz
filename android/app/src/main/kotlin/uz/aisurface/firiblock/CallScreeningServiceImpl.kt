package uz.aisurface.firiblock

import android.os.Handler
import android.os.Looper
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

class CallScreeningServiceImpl : CallScreeningService() {
    private val TAG = "CallScreeningService"

    override fun onScreenCall(callDetails: Call.Details) {
        val number = callDetails.handle?.schemeSpecificPart ?: "unknown"
        Log.d(TAG, "Incoming call from: $number")

        // Notify Flutter about the incoming call
        Handler(Looper.getMainLooper()).post {
            try {
                MainActivity.callScreeningChannel?.invokeMethod(
                    "onIncomingCall",
                    mapOf("number" to number)
                )
            } catch (e: Exception) {
                Log.e(TAG, "Error notifying Flutter: ${e.message}")
            }
        }

        val response = CallResponse.Builder()
            .setDisallowCall(false)
            .setRejectCall(false)
            .setSkipCallLog(false)
            .setSkipNotification(false)
            .build()

        respondToCall(callDetails, response)
    }
}
