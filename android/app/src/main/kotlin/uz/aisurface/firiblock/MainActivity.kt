package uz.aisurface.firiblock

import android.app.role.RoleManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"

    private val CHANNEL_TELECOM = "uz.aisurface.firiblock/telecom"
    private val CHANNEL_DIALER = "uz.aisurface.firiblock/dialer"
    private val CHANNEL_INCALL = "uz.aisurface.firiblock/incall"

    private var telecomChannel: MethodChannel? = null
    private var dialerChannel: MethodChannel? = null
    private var phoneAccountHandle: PhoneAccountHandle? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "configureFlutterEngine called")

        // Telecom bridge channel
        telecomChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL_TELECOM
        )
        telecomChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "registerPhoneAccount" -> {
                    registerPhoneAccount()
                    result.success(true)
                }
                "requestDefaultDialer" -> {
                    requestDefaultDialer()
                    result.success(true)
                }
                "isDefaultDialer" -> {
                    result.success(isDefaultDialer())
                }
                "reportOutgoingCall" -> {
                    val number = call.argument<String>("number")
                    reportOutgoingCall(number)
                    result.success(true)
                }
                "reportIncomingCall" -> {
                    val number = call.argument<String>("number")
                    reportIncomingCall(number)
                    result.success(true)
                }
                "endTelecomCall" -> {
                    endTelecomCall()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Dialer intent channel (receives ACTION_DIAL intents)
        dialerChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL_DIALER
        )

        // InCall service channel (for native call notifications)
        val inCallChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL_INCALL
        )
        FiribInCallService.methodChannel = inCallChannel
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate called")

        // Register the PhoneAccount on startup
        registerPhoneAccount()

        // Handle the initial intent (if app launched via ACTION_DIAL)
        handleDialIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDialIntent(intent)
    }

    private fun handleDialIntent(intent: Intent?) {
        if (intent == null) return

        when (intent.action) {
            Intent.ACTION_DIAL, Intent.ACTION_VIEW -> {
                val number = intent.data?.schemeSpecificPart
                if (number != null) {
                    Log.d(TAG, "Received dial intent for: $number")
                    dialerChannel?.invokeMethod("onDialRequest", mapOf("number" to number))
                }
            }
        }
    }

    /**
     * Register a self-managed PhoneAccount with the TelecomManager.
     * This tells Android our app manages its own VoIP calls.
     */
    private fun registerPhoneAccount() {
        try {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val componentName = ComponentName(this, FiribConnectionService::class.java)
            phoneAccountHandle = PhoneAccountHandle(componentName, "FiribLockVoIP")

            val phoneAccount = PhoneAccount.builder(phoneAccountHandle!!, "AI Muhofiz VoIP")
                .setCapabilities(PhoneAccount.CAPABILITY_SELF_MANAGED)
                .setShortDescription("AI Muhofiz VoIP Calling")
                .setSupportedUriSchemes(listOf(PhoneAccount.SCHEME_SIP, PhoneAccount.SCHEME_TEL))
                .build()

            telecomManager.registerPhoneAccount(phoneAccount)
            Log.d(TAG, "PhoneAccount registered successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register PhoneAccount: ${e.message}")
        }
    }

    /**
     * Request the ROLE_DIALER via RoleManager (Android 10+).
     */
    private fun requestDefaultDialer() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            if (roleManager != null && !roleManager.isRoleHeld(RoleManager.ROLE_DIALER)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                startActivityForResult(intent, REQUEST_DEFAULT_DIALER)
            }
        } else {
            // For Android 9 and below, use the older TelecomManager API
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivityForResult(intent, REQUEST_DEFAULT_DIALER)
        }
    }

    /**
     * Check if this app is currently the default dialer.
     */
    private fun isDefaultDialer(): Boolean {
        val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        return telecomManager.defaultDialerPackage == packageName
    }

    /**
     * Report an outgoing VoIP call to the Telecom framework.
     */
    private fun reportOutgoingCall(number: String?) {
        try {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val extras = Bundle()
            extras.putParcelable(
                TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE,
                phoneAccountHandle
            )
            if (number != null) {
                val uri = Uri.parse("tel:$number")
                telecomManager.placeCall(uri, extras)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to report outgoing call: ${e.message}")
        }
    }

    /**
     * Report an incoming VoIP call to the Telecom framework.
     */
    private fun reportIncomingCall(number: String?) {
        try {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val extras = Bundle()
            extras.putString("number", number ?: "Unknown")
            telecomManager.addNewIncomingCall(phoneAccountHandle, extras)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to report incoming call: ${e.message}")
        }
    }

    /**
     * End the active Telecom connection.
     */
    private fun endTelecomCall() {
        FiribConnectionService.activeConnection?.setCallDisconnected()
    }

    companion object {
        private const val REQUEST_DEFAULT_DIALER = 1002
    }
}
