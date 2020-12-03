import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pedantic/pedantic.dart';

class SquareCameraController {
  final CameraLensDirection lensDirection;
  final ResolutionPreset resolutionPreset;

  CameraController _camera;

  CameraController get camera => _camera;

  bool get isInitialized => _camera?.value?.isInitialized ?? false;

  double get aspectRatio => _camera?.value?.aspectRatio ?? 1.0;

  SquareCameraController({
    this.lensDirection = CameraLensDirection.back,
    this.resolutionPreset = ResolutionPreset.high,
  });

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
        orElse: () => null,
      );

      if (_camera != null && isInitialized) {
        unawaited(dispose());
      }

      _camera = CameraController(camera, resolutionPreset, enableAudio: false);
      await _camera.initialize();
    } on CameraException {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<String> takePicture(String fileName) async {
    final path = join(
      (await getTemporaryDirectory()).path,
      fileName,
    );

    // 이미지 촬영 후 지정된 경로에 파일을 생성한다.
    await _camera.takePicture(path);

    // 촬영된 이미지를 1:1 비율로 Crop 한다.
    final source = decodeImage(File(path).readAsBytesSync());
    final size = min(source.width, source.height);
    final offsetX = (source.width - size) ~/ 2;
    final offsetY = (source.height - size) ~/ 2;
    final output = encodeJpg(copyCrop(source, offsetX, offsetY, size, size));
    await File(path).writeAsBytes(output);

    // 임시 저장된 파일 경로를 이용하여 갤러리에 사진을 저장한다.
    final data = await ImageGallerySaver.saveFile(
      path,
      isReturnPathOfIOS: true,
    ) as Map;

    return data.containsKey('filePath') ? data['filePath'] : null;
  }

  Future<void> dispose() async {
    unawaited(_camera?.dispose());
    _camera = null;
  }
}
