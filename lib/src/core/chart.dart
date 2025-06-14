import 'package:flutter/material.dart';

import '../themes/chart_theme.dart';
import '../widgets/animated_chart_widget.dart';
import 'geometry.dart';
import 'scale.dart';

/// Main chart class implementing grammar of graphics API
class CristalyseChart {
  List<Map<String, dynamic>> _data = [];
  String? _xColumn;
  String? _yColumn;

  /// Secondary Y-axis column
  String? _y2Column;
  String? _colorColumn;
  String? _sizeColumn;

  final List<Geometry> _geometries = [];
  Scale? _xScale;
  Scale? _yScale;

  /// Secondary Y-axis scale
  Scale? _y2Scale;
  ColorScale? _colorScale;
  SizeScale? _sizeScale;
  ChartTheme _theme = ChartTheme.defaultTheme();

  // Animation properties
  Duration _animationDuration = const Duration(milliseconds: 300);
  Curve _animationCurve = Curves.easeInOut;

  bool _coordFlipped = false;

  /// Set the data source for the chart
  ///
  /// Example:
  /// ```dart
  /// CristalyseChart().data([
  ///   {'x': 1, 'y': 2, 'y2': 85, 'category': 'A'},
  ///   {'x': 2, 'y': 3, 'y2': 92, 'category': 'B'},
  /// ])
  /// ```
  CristalyseChart data(List<Map<String, dynamic>> data) {
    _data = data;
    return this;
  }

  /// Define aesthetic mappings between data columns and visual properties
  ///
  /// Example:
  /// ```dart
  /// chart.mapping(x: 'date', y: 'revenue', color: 'category')
  /// ```
  CristalyseChart mapping({String? x, String? y, String? color, String? size}) {
    _xColumn = x;
    _yColumn = y;
    _colorColumn = color;
    _sizeColumn = size;
    return this;
  }

  /// Map data to secondary Y-axis (right side)
  ///
  /// Example:
  /// ```dart
  /// chart.mappingY2('conversion_rate')
  /// ```
  CristalyseChart mappingY2(String column) {
    _y2Column = column;
    return this;
  }

  /// Add scatter plot points
  ///
  /// Example:
  /// ```dart
  /// chart.geomPoint(size: 5.0, alpha: 0.7, yAxis: YAxis.secondary)
  /// ```
  CristalyseChart geomPoint({
    double? size,
    Color? color,
    double? alpha,
    PointShape? shape,
    double? borderWidth,
    YAxis? yAxis,
  }) {
    _geometries.add(
      PointGeometry(
        size: size,
        color: color,
        alpha: alpha ?? 1.0,
        shape: shape ?? PointShape.circle,
        borderWidth: borderWidth ?? 0.0,
        yAxis: yAxis ?? YAxis.primary,
      ),
    );
    return this;
  }

  /// Add line chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomLine(strokeWidth: 2.0, alpha: 0.8, yAxis: YAxis.secondary)
  /// ```
  CristalyseChart geomLine({
    double? strokeWidth,
    Color? color,
    double? alpha,
    LineStyle? style,
    YAxis? yAxis,
  }) {
    _geometries.add(
      LineGeometry(
        strokeWidth: strokeWidth ?? 2.0,
        color: color,
        alpha: alpha ?? 1.0,
        style: style ?? LineStyle.solid,
        yAxis: yAxis ?? YAxis.primary,
      ),
    );
    return this;
  }

  /// Add bar chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomBar(width: 0.8, orientation: BarOrientation.vertical, yAxis: YAxis.secondary)
  /// ```
  CristalyseChart geomBar({
    double? width,
    Color? color,
    double? alpha,
    BarOrientation? orientation,
    BarStyle? style,
    BorderRadius? borderRadius,
    double? borderWidth,
    YAxis? yAxis,
  }) {
    final barGeom = BarGeometry(
      width: width ?? 0.8,
      color: color,
      alpha: alpha ?? 1.0,
      orientation: orientation ?? BarOrientation.vertical,
      style: style ?? BarStyle.grouped,
      borderRadius: borderRadius,
      borderWidth: borderWidth ?? 0.0,
      yAxis: yAxis ?? YAxis.primary,
    );
    _geometries.add(barGeom);
    return this;
  }

  /// Configure continuous X scale
  CristalyseChart scaleXContinuous({double? min, double? max}) {
    _xScale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure continuous Y scale (primary/left axis)
  CristalyseChart scaleYContinuous({double? min, double? max}) {
    _yScale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure continuous secondary Y scale (right axis)
  ///
  /// Example:
  /// ```dart
  /// chart.scaleY2Continuous(min: 0, max: 100) // For percentage data
  /// ```
  CristalyseChart scaleY2Continuous({double? min, double? max}) {
    _y2Scale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure categorical X scale (useful for bar charts)
  CristalyseChart scaleXOrdinal() {
    _xScale = OrdinalScale();
    return this;
  }

  /// Configure categorical Y scale
  CristalyseChart scaleYOrdinal() {
    _yScale = OrdinalScale();
    return this;
  }

  /// Apply visual theme
  CristalyseChart theme(ChartTheme theme) {
    _theme = theme;
    return this;
  }

  /// Configure animations
  ///
  /// Example:
  /// ```dart
  /// chart.animate(
  ///   duration: Duration(milliseconds: 500),
  ///   curve: Curves.bounceOut,
  /// )
  /// ```
  CristalyseChart animate({Duration? duration, Curve? curve}) {
    _animationDuration = duration ?? _animationDuration;
    _animationCurve = curve ?? _animationCurve;
    return this;
  }

  /// Flips the coordinate system.
  ///
  /// This is typically used to create horizontal bar charts from vertical ones,
  /// or to swap the roles of X and Y axes for other chart types.
  CristalyseChart coordFlip() {
    _coordFlipped = true;
    return this;
  }

  /// Build the chart widget
  Widget build() {
    return AnimatedCristalyseChartWidget(
      data: _data,
      xColumn: _xColumn,
      yColumn: _yColumn,
      y2Column: _y2Column,
      colorColumn: _colorColumn,
      sizeColumn: _sizeColumn,
      geometries: _geometries,
      xScale: _xScale,
      yScale: _yScale,
      y2Scale: _y2Scale,
      colorScale: _colorScale,
      sizeScale: _sizeScale,
      theme: _theme,
      animationDuration: _animationDuration,
      animationCurve: _animationCurve,
      coordFlipped: _coordFlipped,
    );
  }
}
