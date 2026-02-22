package uz.aisurface.firiblock

import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.telecom.Connection
import android.telecom.ConnectionRequest
import android.telecom.ConnectionService
import android.telecom.DisconnectCause
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.util.Log

/**
 * ConnectionService with CAPABILITY_SELF_MANAGED for VoIP calls.
 * Registers VoIP calls with the Android Telecom framework for
 * audio focus management and call log integration.
 */
class FiribConnectionService : ConnectionService() {

    companion object {
        private const val TAG = "FiribConnectionService"
        var activeConnection: FiribConnection? = null
    }

    override fun onCreateOutgoingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ): Connection {
        Log.d(TAG, "onCreateOutgoingConnection")
        val connection = FiribConnection()
        connection.setAddress(request?.address ?: Uri.EMPTY, TelecomManager.PRESENTATION_ALLOWED)
        connection.setInitializing()
        activeConnection = connection
        return connection
    }

    override fun onCreateIncomingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ): Connection {
        Log.d(TAG, "onCreateIncomingConnection")
        val connection = FiribConnection()
        val extras = request?.extras
        val number = extras?.getString("number") ?: "Unknown"
        connection.setAddress(Uri.parse("tel:$number"), TelecomManager.PRESENTATION_ALLOWED)
        connection.setRinging()
        activeConnection = connection
        return connection
    }

    override fun onCreateOutgoingConnectionFailed(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ) {
        Log.e(TAG, "onCreateOutgoingConnectionFailed")
    }

    override fun onCreateIncomingConnectionFailed(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ) {
        Log.e(TAG, "onCreateIncomingConnectionFailed")
    }
}

/**
 * Represents a single VoIP call connection managed by the system.
 */
class FiribConnection : Connection() {

    companion object {
        private const val TAG = "FiribConnection"
    }

    init {
        connectionProperties = PROPERTY_SELF_MANAGED
        connectionCapabilities = CAPABILITY_HOLD or CAPABILITY_MUTE or CAPABILITY_SUPPORT_HOLD
        audioModeIsVoip = true
    }

    override fun onAnswer() {
        Log.d(TAG, "onAnswer")
        setActive()
    }

    override fun onReject() {
        Log.d(TAG, "onReject")
        setDisconnected(DisconnectCause(DisconnectCause.REJECTED))
        destroy()
        FiribConnectionService.activeConnection = null
    }

    override fun onDisconnect() {
        Log.d(TAG, "onDisconnect")
        setDisconnected(DisconnectCause(DisconnectCause.LOCAL))
        destroy()
        FiribConnectionService.activeConnection = null
    }

    override fun onHold() {
        Log.d(TAG, "onHold")
        setOnHold()
    }

    override fun onUnhold() {
        Log.d(TAG, "onUnhold")
        setActive()
    }

    override fun onAbort() {
        Log.d(TAG, "onAbort")
        setDisconnected(DisconnectCause(DisconnectCause.CANCELED))
        destroy()
        FiribConnectionService.activeConnection = null
    }

    /** Called from Flutter to mark the call as active (answered/connected). */
    fun setCallActive() {
        setActive()
    }

    /** Called from Flutter to disconnect the call. */
    fun setCallDisconnected(cause: Int = DisconnectCause.LOCAL) {
        setDisconnected(DisconnectCause(cause))
        destroy()
        FiribConnectionService.activeConnection = null
    }
}
