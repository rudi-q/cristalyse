import 'package:flutter/material.dart';

/// Base class for all chart geometries
abstract class Geometry {}

/// Point geometry for scatter plots
class PointGeometry extends Geometry {
  final double? size;
  final Color? color;
  final double alpha;

  PointGeometry({
    this.size,
    this.color,
    required this.alpha,
  });
}

/// Line geometry for line charts
class LineGeometry extends Geometry {
  final double strokeWidth;
  final Color? color;
  final double alpha;
  final LineStyle style;

  LineGeometry({
    this.strokeWidth = 2.0,
    this.color,
    this.alpha = 1.0,
    this.style = LineStyle.solid,
  });
}

/// Line styles for line geometry
enum LineStyle {
  solid,
  dashed,
  dotted,
}