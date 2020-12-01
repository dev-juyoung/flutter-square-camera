import 'dart:async';

import 'package:flutter/services.dart';

class SquareCamera {
  static const MethodChannel _channel = const MethodChannel(
    'plugins.juyoung.dev/square_camera',
  );

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
