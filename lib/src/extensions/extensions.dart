import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  Size get size => MediaQuery.of(this).size;

  double get width => size.width;

  double get height => size.height;

  double get aspectRatio => size.aspectRatio;
}
