package dev.juyoung.square.camera

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import dev.juyoung.square.camera.extensions.isRequiredPermissionAcquired
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import timber.log.Timber

class SquareCameraPlugin : FlutterPlugin, ActivityAware, MethodCallHandler,
    RequestPermissionsResultListener {
    private lateinit var channel: MethodChannel

    private lateinit var context: Context
    private lateinit var activityBinding: ActivityPluginBinding
    private var pendingResult: Result? = null

    companion object {
        const val TAG = "[Plugins] SquareCamera"
        const val CHANNEL = "plugins.juyoung.dev/square_camera"

        // permission request code
        const val REQUIRED_PERMISSIONS_REQUEST_CODE = 2172

        val permissionGroup = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        )
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPluginBinding) {
        Timber.i("$TAG::onAttachedToEngine::${binding.applicationContext}")

        context = binding.applicationContext

        MethodChannel(binding.binaryMessenger, CHANNEL).apply {
            channel = this
            setMethodCallHandler(this@SquareCameraPlugin)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
        Timber.i("$TAG::onDetachedFromEngine::${binding.applicationContext}")

        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Timber.i("$TAG::onAttachedToActivity::${binding.activity}")
        attachToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Timber.i("$TAG::onDetachedFromActivity")
        disposeActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Timber.i("$TAG::onReattachedToActivityForConfigChanges::${binding.activity}")
        attachToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Timber.i("$TAG::onDetachedFromActivityForConfigChanges")
        disposeActivity()
    }

    private fun attachToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding.also {
            it.addRequestPermissionsResultListener(this)
        }
    }

    private fun disposeActivity() {
        activityBinding.removeRequestPermissionsResultListener(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "hasPermissions" -> hasPermissions(call, result)
            "requestPermissions" -> requestPermissions(call, result)
            "openAppSettings" -> openAppSettings(call, result)
            else -> result.notImplemented()
        }
    }

    private fun hasPermissions(call: MethodCall, result: Result) {
        Timber.i("[METHOD][CALL]::hasPermissions")
        result.success(context.isRequiredPermissionAcquired)
    }

    private fun requestPermissions(call: MethodCall, result: Result) {
        Timber.i("[METHOD][CALL]::requestPermissions")
        if (context.isRequiredPermissionAcquired) {
            result.success(true)
            return
        }

        pendingResult = result
        ActivityCompat.requestPermissions(
            activityBinding.activity,
            permissionGroup,
            REQUIRED_PERMISSIONS_REQUEST_CODE
        )
    }

    private fun openAppSettings(call: MethodCall, result: Result) {
        try {
            val intent = Intent().apply {
                action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                data = Uri.parse("package:${context.packageName}")
                addCategory(Intent.CATEGORY_DEFAULT)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
            }
            context.startActivity(intent)

            result.success(true)
        } catch (e: Throwable) {
            result.success(false)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ): Boolean {
        Timber.i("$TAG::onRequestPermissionsResult::$requestCode")
        return when (requestCode) {
            REQUIRED_PERMISSIONS_REQUEST_CODE -> {
                pendingResult?.success(grantResults != null && grantResults.size > 1 && grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED)
                pendingResult = null
                true
            }
            else -> false
        }
    }
}

