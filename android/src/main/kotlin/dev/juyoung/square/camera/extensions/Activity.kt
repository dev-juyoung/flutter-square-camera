package dev.juyoung.square.camera.extensions

import android.app.Activity
import androidx.core.app.ActivityCompat
import dev.juyoung.square.camera.SquareCameraPlugin
import timber.log.Timber

val Activity.shouldShowRequestPermissionRationale: Boolean
    get() = SquareCameraPlugin.permissionGroup.all {
        Timber.i("[shouldShowRequestPermissionRationale]::$it")
        ActivityCompat.shouldShowRequestPermissionRationale(this, it)
    }
