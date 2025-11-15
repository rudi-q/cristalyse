import 'package:flutter/material.dart';

/// Base class for all render data
/// These classes contain pre-calculated geometry and styling information,
/// ready to be rendered by any backend (Canvas, SVG, etc.)
abstract class RenderData {
  const RenderData();
}

/// Represents a single bar ready to be rendered
class BarRenderData extends RenderData {
  /// The rectangle defining the bar's position and size (full size, no animation applied)
  final Rect rect;

  /// The color or gradient to fill the bar with
  final dynamic colorOrGradient; // Color or Gradient

  /// Alpha transparency (0.0-1.0)
  final double alpha;

  /// Optional border radius for rounded corners
  final BorderRadius? borderRadius;

  /// Border width (0 for no border)
  final double borderWidth;

  /// Border color (if borderWidth > 0)
  final Color? borderColor;

  /// The original data point this bar represents
  final Map<String, dynamic> dataPoint;

  const BarRenderData({
    required this.rect,
    required this.colorOrGradient,
    required this.alpha,
    this.borderRadius,
    required this.borderWidth,
    this.borderColor,
    required this.dataPoint,
  });

  BarRenderData copyWith({
    Rect? rect,
    dynamic colorOrGradient,
    double? alpha,
    BorderRadius? borderRadius,
    double? borderWidth,
    Color? borderColor,
    Map<String, dynamic>? dataPoint,
  }) {
    return BarRenderData(
      rect: rect ?? this.rect,
      colorOrGradient: colorOrGradient ?? this.colorOrGradient,
      alpha: alpha ?? this.alpha,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      dataPoint: dataPoint ?? this.dataPoint,
    );
  }
}

/// Represents a line ready to be rendered
class LineRenderData extends RenderData {
  /// All points in the line (fully calculated, no animation applied)
  final List<Offset> points;

  /// Line color
  final Color color;

  /// Stroke width
  final double strokeWidth;

  /// Alpha transparency (0.0-1.0)
  final double alpha;

  /// Line style (solid, dashed, dotted)
  final LineStyle style;

  /// Dash pattern for dashed/dotted lines
  final List<double>? dashPattern;

  const LineRenderData({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.alpha,
    required this.style,
    this.dashPattern,
  });
}

/// Enum for line styles
enum LineStyle {
  solid,
  dashed,
  dotted,
}

/// Represents a point (scatter plot point) ready to be rendered
class PointRenderData extends RenderData {
  /// The center position of the point
  final Offset position;

  /// Size (diameter/width) of the point (full size, no animation applied)
  final double size;

  /// The color or gradient to fill the point with
  final dynamic colorOrGradient; // Color or Gradient

  /// Alpha transparency (0.0-1.0)
  final double alpha;

  /// Shape of the point
  final PointShape shape;

  /// Border width (0 for no border)
  final double borderWidth;

  /// Border color (if borderWidth > 0)
  final Color? borderColor;

  /// The original data point
  final Map<String, dynamic> dataPoint;

  const PointRenderData({
    required this.position,
    required this.size,
    required this.colorOrGradient,
    required this.alpha,
    required this.shape,
    required this.borderWidth,
    this.borderColor,
    required this.dataPoint,
  });

  PointRenderData copyWith({
    Offset? position,
    double? size,
    dynamic colorOrGradient,
    double? alpha,
    PointShape? shape,
    double? borderWidth,
    Color? borderColor,
    Map<String, dynamic>? dataPoint,
  }) {
    return PointRenderData(
      position: position ?? this.position,
      size: size ?? this.size,
      colorOrGradient: colorOrGradient ?? this.colorOrGradient,
      alpha: alpha ?? this.alpha,
      shape: shape ?? this.shape,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      dataPoint: dataPoint ?? this.dataPoint,
    );
  }
}

/// Enum for point shapes
enum PointShape {
  circle,
  square,
  triangle,
}

/// Represents a bubble (sized point) ready to be rendered
class BubbleRenderData extends PointRenderData {
  /// Optional label text to display
  final String? labelText;

  /// Position of the label relative to the bubble
  final Offset? labelPosition;

  const BubbleRenderData({
    required super.position,
    required super.size,
    required super.colorOrGradient,
    required super.alpha,
    required super.shape,
    required super.borderWidth,
    super.borderColor,
    required super.dataPoint,
    this.labelText,
    this.labelPosition,
  });
}

/// Represents an area chart path ready to be rendered
class AreaRenderData extends RenderData {
  /// Points defining the top edge of the area
  final List<Offset> points;

  /// Y position of the baseline
  final double baselineY;

  /// Fill color or gradient
  final dynamic fillColorOrGradient;

  /// Fill alpha transparency (0.0-1.0)
  final double fillAlpha;

  /// Optional stroke color for the top edge
  final Color? strokeColor;

  /// Optional stroke width
  final double? strokeWidth;

  /// Alpha for the stroke
  final double strokeAlpha;

  const AreaRenderData({
    required this.points,
    required this.baselineY,
    required this.fillColorOrGradient,
    required this.fillAlpha,
    this.strokeColor,
    this.strokeWidth,
    required this.strokeAlpha,
  });
}

/// Represents a pie slice ready to be rendered
class PieSliceData extends RenderData {
  /// Start angle in radians
  final double startAngle;

  /// Sweep angle in radians (full angle, no animation applied)
  final double sweepAngle;

  /// Center point of the entire pie
  final Offset pieCenter;

  /// Center point of this slice (accounting for explosion)
  final Offset sliceCenter;

  /// Outer radius
  final double outerRadius;

  /// Inner radius (for donut charts, 0 for regular pie)
  final double innerRadius;

  /// Slice color
  final Color color;

  /// Alpha transparency (0.0-1.0)
  final double alpha;

  /// Category value for this slice
  final dynamic category;

  /// Numeric value of the slice
  final double value;

  /// Percentage of the total (0.0-1.0)
  final double percentage;

  /// Optional label text
  final String? labelText;

  /// Optional label position
  final Offset? labelPosition;

  const PieSliceData({
    required this.startAngle,
    required this.sweepAngle,
    required this.pieCenter,
    required this.sliceCenter,
    required this.outerRadius,
    required this.innerRadius,
    required this.color,
    required this.alpha,
    required this.category,
    required this.value,
    required this.percentage,
    this.labelText,
    this.labelPosition,
  });
}

/// Represents a heat map cell ready to be rendered
class HeatMapCellData extends RenderData {
  /// The rectangle defining the cell's position and size (full size, no animation applied)
  final Rect rect;

  /// Cell fill color
  final Color color;

  /// Alpha transparency (0.0-1.0)
  final double alpha;

  /// Normalized value (0.0-1.0) for this cell
  final double normalizedValue;

  /// Raw value
  final double value;

  /// Optional border radius
  final BorderRadius? borderRadius;

  /// Optional label text to display in the cell
  final String? labelText;

  /// X coordinate value
  final dynamic xValue;

  /// Y coordinate value
  final dynamic yValue;

  const HeatMapCellData({
    required this.rect,
    required this.color,
    required this.alpha,
    required this.normalizedValue,
    required this.value,
    this.borderRadius,
    this.labelText,
    required this.xValue,
    required this.yValue,
  });

  HeatMapCellData copyWith({
    Rect? rect,
    Color? color,
    double? alpha,
    double? normalizedValue,
    double? value,
    BorderRadius? borderRadius,
    String? labelText,
    dynamic xValue,
    dynamic yValue,
  }) {
    return HeatMapCellData(
      rect: rect ?? this.rect,
      color: color ?? this.color,
      alpha: alpha ?? this.alpha,
      normalizedValue: normalizedValue ?? this.normalizedValue,
      value: value ?? this.value,
      borderRadius: borderRadius ?? this.borderRadius,
      labelText: labelText ?? this.labelText,
      xValue: xValue ?? this.xValue,
      yValue: yValue ?? this.yValue,
    );
  }
}

/// Represents progress bar render data
class ProgressBarRenderData extends RenderData {
  /// The main rect or path defining the progress bar
  final Rect rect;

  /// Progress value (0.0-1.0)
  final double progress;

  /// Bar color or gradient
  final dynamic colorOrGradient;

  /// Alpha transparency (0.0-1.0)
  final double alpha;

  /// Optional border radius
  final BorderRadius? borderRadius;

  /// Optional label text
  final String? labelText;

  /// Optional label position
  final Offset? labelPosition;

  const ProgressBarRenderData({
    required this.rect,
    required this.progress,
    required this.colorOrGradient,
    required this.alpha,
    this.borderRadius,
    this.labelText,
    this.labelPosition,
  });
}
