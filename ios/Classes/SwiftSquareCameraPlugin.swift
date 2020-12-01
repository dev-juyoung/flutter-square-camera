import Flutter
import UIKit
import AVFoundation

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
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    private func hasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(hasPermissions())
    }
    
    private func requestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            result(granted)
        }
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
