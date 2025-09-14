import 'package:flutter/material.dart';

import '../../../cristalyse.dart' show AnimatedCristalyseChartWidget;
import '../../widgets/animated_chart_painter.dart' show AnimatedChartPainter;

/// Factory function for creating [AnimatedChartPainter] instances with reduced boilerplate.
///
/// This utility function encapsulates the complex constructor call for [AnimatedChartPainter],
/// automatically extracting all necessary parameters from the provided widget and context.
/// It significantly reduces code duplication when creating painter instances in multiple locations.
///
/// The function handles the mapping of all chart configuration parameters including:
/// - Data columns (x, y, y2, color, size, pie, heatmap)
/// - Chart geometries and scales
/// - Theme and styling options
/// - Animation and interaction state
/// - Pan/zoom domain boundaries
///
/// Parameters:
/// - [widget]: The chart widget containing all configuration data.
/// - [context]: The build context (currently unused but maintained for API consistency).
/// - [size]: The canvas size for the chart (currently unused but maintained for API consistency).
/// - [animationProgress]: The current animation progress value (0.0 to 1.0).
/// - [panXDomain]: Optional pan domain for the X-axis. Used for interactive panning.
/// - [panYDomain]: Optional pan domain for the Y-axis. Used for interactive panning.
///
/// Returns a fully configured [AnimatedChartPainter] instance ready for use with [CustomPaint].
///
/// Example:
/// ```dart
/// final painter = chartPainterAnimated(
///   widget: myChartWidget,
///   context: context,
///   size: constraints.biggest,
///   animationProgress: 0.8,
///   panXDomain: [0.0, 100.0],
///   panYDomain: [0.0, 50.0],
/// );
///
/// CustomPaint(painter: painter, child: Container())
/// ```
AnimatedChartPainter chartPainterAnimated(
    {required AnimatedCristalyseChartWidget widget,
    required BuildContext context,
    required Size size,
    required double animationProgress,
    List<double>? panXDomain,
    List<double>? panYDomain}) {
  return AnimatedChartPainter(
    data: widget.data,
    xColumn: widget.xColumn,
    yColumn: widget.yColumn,
    y2Column: widget.y2Column,
    colorColumn: widget.colorColumn,
    sizeColumn: widget.sizeColumn,
    pieValueColumn: widget.pieValueColumn,
    pieCategoryColumn: widget.pieCategoryColumn,
    heatMapXColumn: widget.heatMapXColumn,
    heatMapYColumn: widget.heatMapYColumn,
    heatMapValueColumn: widget.heatMapValueColumn,
    progressValueColumn: widget.progressValueColumn,
    progressLabelColumn: widget.progressLabelColumn,
    progressCategoryColumn: widget.progressCategoryColumn,
    geometries: widget.geometries,
    xScale: widget.xScale,
    yScale: widget.yScale,
    y2Scale: widget.y2Scale,
    colorScale: widget.colorScale,
    sizeScale: widget.sizeScale,
    theme: widget.theme,
    animationProgress: animationProgress,
    coordFlipped: widget.coordFlipped,
    panXDomain: panXDomain,
    panYDomain: panYDomain,
  );
}
