## Square Camera

[![pub package](https://img.shields.io/pub/v/square_camera)](https://pub.dartlang.org/packages/square_camera)

이 플러그인은 [camera plugin](https://pub.dev/packages/camera) 을 래핑하여 정사각형 카메라 프리뷰와 이미지를 저장하기 위한 플러그인 입니다.

## Related Document

:point_right: [English](README-EN.md)

## Getting Started

자세한 사용법은 샘플 앱을 참고하세요.

#### Add pubspec.yaml

해당 플러그인을 사용하려면 `square_camera`를 [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/) 문서를 참고하여 추가하세요.

#### Android Integration

- `android/app/build.gradle` 파일에서 최소 Android SDK 버전을 21 이상으로 설정하세요.

```
minSdkVersion 21
```

- Android 10 이상에서 스토리지 기능을 활성화 하기 위해 `AndroidManifest.xml` 파일에 아래의 속성을 추가하세요.

```xml
<application android:requestLegacyExternalStorage="true">
```

#### iOS Integration

- `ios/Runner/Info.plist` 파일을 열고 아래의 속성을 추가하세요.

```
<key>NSCameraUsageDescription</key>
<string>여기에 카메라 권한이 필요한 이유에 대한 설명을 기재하세요.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>여기에 갤러리 사용과 관련된 권한이 필요한 이유에 대한 설명을 기재하세요.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>여기에 갤러리 사용과 관련된 권한이 필요한 이유에 대한 설명을 기재하세요.</string>
```

## Usage

#### SquareCamera.hasPermissions

카메라 및 갤러리 사용을 위해 필요한 권한을 획득했는지 확인합니다.

```dart
void _hasPermissions() async {
  final result = await SquareCamera.hasPermissions();
}
```

#### SquareCamera.requestPermissions

카메라 및 갤러리 사용을 위해 필요한 권한을 요청합니다.

```dart
void _requestPermissions() async {
  final result = await SquareCamera.requestPermissions();
}
```

#### SquareCamera.openAppSettings

해당 애플리케이션의 설정 화면으로 이동합니다.

> Note:
>
> 플러그인 사용을 위한 권한 획득 과정에서 `hasPermissions` 와 `requestPermissions`  요청 결과가 모두 `false`인 경우, 사용자가 해당 권한을 영구적으로 거부하였다고 간주할 수 있습니다.
>
> 사용자가 해당 권한을 영구적으로 거부한 경우 플러그인의 정상적인 사용을 위해 애플리케이션 설정 화면으로 이동하여 사용자가 직접 권한을 허용하도록 유도하여야 합니다.

```dart
void _openAppSettings() async {
  final result = await SquareCamera.openAppSettings();
}
```

## Example

아래의 코드는 SquareCamera를 사용하는 간략한 예제입니다.

```dart
import 'package:flutter/material.dart';
import 'package:square_camera/square_camera.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  /// 카메라 제어를 위한 컨트롤러 객체
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

    if (_isAvailable == result) {
      return;
    }

    setState(() {
      _isAvailable = result;
    });
  }

  void _requestPermissions() async {
    final result = await SquareCamera.requestPermissions();

    /// 권한 획득에 실패한 경우 앱 설정으로 이동하여 사용자가 직접 설정하도록 유도
    if (!result) {
      await SquareCamera.openAppSettings();
      return;
    }

    /// 권한 획득 완료 후 화면 갱신을 위해 권한 획득 여부를 다시 한번 체크한다
    _hasPermissions();
  }

  void _takePicture() async {
    final epochMillis = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${epochMillis}.jpg';
    /// 갤러리 저장 성공 후, 실제 저장된 갤러리의 전체 경로를 반환한다
    /// 해당 경로를 이용하여 Image 위젯등을 이용하여 표출하면 된다
    final result = await _controller.takePicture(fileName);
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
```
