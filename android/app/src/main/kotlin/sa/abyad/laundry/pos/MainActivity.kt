package sa.abyad.laundry.pos

import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
/// Workaround for disabling the default-tag-detection while the app is foreground.
class MainActivity: FlutterActivity() {

    override fun onResume() {
        super.onResume()
        val intent = Intent(context, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
//        val pendingIntent = PendingIntent.getActivity(context, 0, intent, 0)
        val pendingIntent = PendingIntent.getActivity(context, 0, intent, 67108864)
        NfcAdapter.getDefaultAdapter(context)?.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        NfcAdapter.getDefaultAdapter(context)?.disableForegroundDispatch(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // This line is often automatic now, but keeping it ensures
        // plugins are registered correctly in Release mode.
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

}



//package sa.abyad.laundry.pos
//
//import android.app.PendingIntent
//import android.content.Intent
//import android.nfc.NfcAdapter
//import android.os.Build
//import androidx.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugins.GeneratedPluginRegistrant
//
//class MainActivity: FlutterActivity() {
//
//    override fun onResume() {
//        super.onResume()
//
//        // Use 'this' context explicitly
//        val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
//
//        // Fix for Android 12+ (API 31+) Mutability requirement
//        val flag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
//        } else {
//            PendingIntent.FLAG_UPDATE_CURRENT
//        }
//
//        val pendingIntent = PendingIntent.getActivity(this, 0, intent, flag)
//
//        // Null-safe call to NFC adapter
//        NfcAdapter.getDefaultAdapter(this)?.enableForegroundDispatch(this, pendingIntent, null, null)
//    }
//
//    override fun onPause() {
//        super.onPause()
//        NfcAdapter.getDefaultAdapter(this)?.disableForegroundDispatch(this)
//    }
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
//    }
//}

//package sa.abyad.laundry.pos
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import androidx.annotation.NonNull
//
//class MainActivity : FlutterActivity() {
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        // If you have MethodChannels, register them here
//    }
//
//}