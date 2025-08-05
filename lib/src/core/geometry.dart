import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'label_formatter.dart';

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

/// Pie geometry for pie and donut charts
class PieGeometry extends Geometry {
  /// Static formatter as a default; don't create NumberFormat on every label render
  static final _defaultPercentageFormatter = intl.NumberFormat.percentPattern();

  final double innerRadius; // For donut charts (0.0 for full pie)
  final double outerRadius;
  final Color? strokeColor;
  final double strokeWidth;
  final bool showLabels;
  final TextStyle? labelStyle;
  final double labelRadius; // Distance from center for labels
  final double startAngle; // Starting angle in radians
  final bool showPercentages;
  final bool explodeSlices;
  final double explodeDistance;
  final LabelCallback labelFormatter;

  PieGeometry({
    this.innerRadius = 0.0,
    this.outerRadius = 100.0,
    this.strokeColor,
    this.strokeWidth = 1.0,
    this.showLabels = true,
    this.labelStyle,
    this.labelRadius = 120.0,
    this.startAngle = -1.5707963267948966, // -π/2 (start at top)
    this.showPercentages = true,
    this.explodeSlices = false,
    this.explodeDistance = 10.0,
    LabelCallback? labelFormatter,
    super.interactive = true,
  })  : labelFormatter = labelFormatter ?? _defaultPercentageFormatter.format,
        super(yAxis: YAxis.primary); // Pie charts don't use Y-axis
}
