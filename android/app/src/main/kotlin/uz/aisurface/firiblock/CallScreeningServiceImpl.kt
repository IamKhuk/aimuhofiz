package uz.aisurface.firiblock

import android.telecom.Call
import android.telecom.CallScreeningService

class CallScreeningServiceImpl : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {

        val number =
            callDetails.handle?.schemeSpecificPart ?: "unknown"

        // TODO: send number to Flutter / show overlay / evaluate fraud

        val response = CallResponse.Builder()
            .setDisallowCall(false)    // true = block
            .setRejectCall(false)
            .setSkipCallLog(false)
            .setSkipNotification(false)
            .build()

        respondToCall(callDetails, response)
    }
}