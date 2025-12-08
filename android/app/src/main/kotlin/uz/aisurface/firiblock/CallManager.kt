package uz.aisurface.firiblock

import android.content.Context
import android.os.Build
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import java.lang.reflect.Method

/**
 * Manager class to handle call operations like ending calls
 */
class CallManager(private val context: Context) {

    /**
     * End the current active call
     * Uses TelecomManager on Android 9+ or reflection on older versions
     */
    fun endCall(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // Android 9+ use TelecomManager
                val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                telecomManager.endCall()
            } else {
                // Older Android versions use reflection
                endCallViaReflection()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * End call using reflection for older Android versions
     */
    private fun endCallViaReflection(): Boolean {
        return try {
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val clazz = Class.forName(telephonyManager.javaClass.name)
            val method: Method = clazz.getDeclaredMethod("getITelephony")
            method.isAccessible = true
            val telephony = method.invoke(telephonyManager)
            val telephonyClass = Class.forName(telephony.javaClass.name)
            val endCallMethod: Method = telephonyClass.getDeclaredMethod("endCall")
            endCallMethod.invoke(telephony)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
