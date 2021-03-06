import 'package:flutter/material.dart';
import 'package:square_camera/square_camera.dart';

void main() {
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  SquareCameraController _controller;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller = SquareCameraController();
    _hasPermissions();
  }

  void _hasPermissions() async {
    final result = await SquareCamera.hasPermissions();
    print('[hasPermissions]::$result');

    if (_isAvailable == result) {
      return;
    }

    setState(() {
      _isAvailable = result;
    });
  }

  void _requestPermissions() async {
    final result = await SquareCamera.requestPermissions();
    print('[requestPermissions]::$result');

    /// 권한 획득에 실패한 경우 앱 설정으로 이동하여 사용자가 직접 설정하도록 유도.
    if (!result) {
      await SquareCamera.openAppSettings();
      return;
    }

    _hasPermissions();
  }

  void _takePicture() async {
    final epochMillis = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${epochMillis}.jpg';
    final result = await _controller.takePicture(fileName);
    print('[RESULT]::$result');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Square Camera Demo'),
        ),
        body: _isAvailable
            ? SquareCameraPreview(controller: _controller)
            : Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('사진 촬영 및 저장을 위해 권한을 획득하세요.'),
                    SizedBox(height: 8.0),
                    RaisedButton.icon(
                      icon: Icon(Icons.lock_open_rounded),
                      label: Text('권한 획득'),
                      onPressed: _requestPermissions,
                    ),
                  ],
                ),
              ),
        floatingActionButton: _isAvailable
            ? FloatingActionButton(
                child: Icon(Icons.camera_rounded),
                onPressed: _takePicture,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
