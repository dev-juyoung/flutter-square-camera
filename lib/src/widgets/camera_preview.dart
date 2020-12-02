import 'package:flutter/material.dart';
import 'package:camera/camera.dart' show CameraPreview;

import 'camera_controller.dart';
import '../extensions/extensions.dart';

class SquareCameraPreview extends StatefulWidget {
  final SquareCameraController controller;

  SquareCameraPreview({
    @required this.controller,
  }) : assert(controller != null, 'SquareCameraController cannot be null.');

  @override
  _SquareCameraPreviewState createState() => _SquareCameraPreviewState();
}

class _SquareCameraPreviewState extends State<SquareCameraPreview> {
  @protected
  void updateIfNecessary() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    if (widget.controller.isInitialized) {
      return;
    }

    await widget.controller.initialize();
    updateIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    return widget.controller.isInitialized
        ? AspectRatio(
            aspectRatio: 1.0,
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Container(
                  width: context.width,
                  height: context.width / widget.controller.aspectRatio,
                  child: CameraPreview(widget.controller.camera),
                ),
              ),
            ),
          )
        : Container();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}
