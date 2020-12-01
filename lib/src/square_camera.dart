import 'dart:async';

import 'package:flutter/services.dart';

class SquareCamera {
  static const MethodChannel _channel = const MethodChannel(
    'plugins.juyoung.dev/square_camera',
  );

  SquareCamera._();

  static Future<bool> hasPermissions() async {
    return await _channel.invokeMethod('hasPermissions');
  }

  static Future<bool> requestPermissions() async {
    return await _channel.invokeMethod('requestPermissions');
  }

  static Future<bool> openAppSettings() async {
    return await _channel.invokeMethod('openAppSettings');
  }
}
