#import "SquareCameraPlugin.h"
#if __has_include(<square_camera/square_camera-Swift.h>)
#import <square_camera/square_camera-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "square_camera-Swift.h"
#endif

@implementation SquareCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSquareCameraPlugin registerWithRegistrar:registrar];
}
@end
