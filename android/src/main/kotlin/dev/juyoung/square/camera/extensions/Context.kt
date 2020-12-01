package dev.juyoung.square.camera.extensions

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import dev.juyoung.square.camera.SquareCameraPlugin

val Context.isDebuggable: Boolean
    get() = 0 != applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE

val Context.isRequiredPermissionAcquired: Boolean
    get() = SquareCameraPlugin.permissionGroup.all {
        ActivityCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
    }
