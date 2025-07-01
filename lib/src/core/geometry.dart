import 'package:flutter/material.dart';

/// Enum for specifying which Y-axis to use
enum YAxis { primary, secondary }

/// Base class for all chart geometries
abstract class Geometry {
  final YAxis yAxis;
  final bool interactive;

  Geometry({this.yAxis = YAxis.primary, this.interactive = true});
}

/// Enum for point shapes
enum PointShape { circle, square, triangle }

/// Point geometry for scatter plots
class PointGeometry extends Geometry {
  final double? size;
  final Color? color;
  final double alpha;
  final PointShape shape;
  final double borderWidth;

  PointGeometry({
    this.size,
    this.color,
    this.alpha = 1.0,
    this.shape = PointShape.circle,
    this.borderWidth = 0.0,
    super.yAxis,
    super.interactive,
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
    super.yAxis,
    super.interactive,
  });
}

/// Bar geometry for bar charts
class BarGeometry extends Geometry {
  final double width;
  final Color? color;
  final double alpha;
  final BarOrientation orientation;
  final BarStyle style;
  final BorderRadius? borderRadius;
  final double borderWidth;

  BarGeometry({
    this.width = 0.8,
    this.color,
    this.alpha = 1.0,
    this.orientation = BarOrientation.vertical,
    this.style = BarStyle.grouped,
    this.borderRadius,
    this.borderWidth = 0.0,
    super.yAxis,
    super.interactive,
  });
}

/// Line styles for line geometry
enum LineStyle { solid, dashed, dotted }

/// Bar orientation options
enum BarOrientation { vertical, horizontal }

/// Bar styling options
enum BarStyle {
  grouped, // Multiple series side-by-side
  stacked, // Multiple series stacked on top
}

/// Area geometry for area charts
class AreaGeometry extends Geometry {
  final double strokeWidth;
  final Color? color;
  final double alpha;
  final LineStyle style;
  final bool fillArea;

  AreaGeometry({
    this.strokeWidth = 2.0,
    this.color,
    this.alpha = 0.3,
    this.style = LineStyle.solid,
    this.fillArea = true,
    super.yAxis,
    super.interactive,
  });
}
