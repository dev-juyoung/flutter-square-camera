import Flutter
import UIKit
import AVFoundation
import Photos

public class SwiftSquareCameraPlugin: NSObject, FlutterPlugin {
    static let TAG = "[Plugins] SquareCamera"
    private static let METHOD_CHANNEL = "plugins.juyoung.dev/square_camera"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftSquareCameraPlugin()
        let channel = FlutterMethodChannel(name: METHOD_CHANNEL, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "hasPermissions":
            hasPermissions(call: call, result: result)
        case "requestPermissions":
            requestPermissions(call: call, result: result)
        case "openAppSettings":
            openAppSettings(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func hasPermissions() -> Bool {
        return AVCaptureDevice.isPermissionGranted(for: .video) && PHPhotoLibrary.isPermissionGranted()
    }
    
    private func hasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(hasPermissions())
    }
    
    private func requestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let semaphore = DispatchSemaphore(value: 0)
        
        // 카메라 권한 획득
        AVCaptureDevice.requestAccess(for: .video) { _ in semaphore.signal() }
        semaphore.wait()
        
        // 갤러리 권한 획득
        PHPhotoLibrary.requestAuthorization { status in semaphore.signal() }
        semaphore.wait()
        
        result(AVCaptureDevice.isPermissionGranted(for: .video) && PHPhotoLibrary.isPermissionGranted())
    }
    
    private func openAppSettings(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let url = URL(string: UIApplication.openSettingsURLString)!
        guard UIApplication.shared.canOpenURL(url) else {
            result(false)
            return;
        }
        
        UIApplication.shared.open(url, options: [:]) { opened in
            result(opened)
        }
    }
}

extension AVCaptureDevice {
    class func isPermissionGranted(for mediaType: AVMediaType) -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            return true
        default:
            return false
        }
    }
}

extension PHPhotoLibrary {
    class func isPermissionGranted() -> Bool {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            return true
        default:
            return false
        }
    }
}
