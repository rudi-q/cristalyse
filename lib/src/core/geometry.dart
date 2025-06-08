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