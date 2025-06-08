import 'package:flutter/material.dart';
import '../widgets/animated_chart_widget.dart';
import 'geometry.dart';
import 'scale.dart';
import '../themes/chart_theme.dart';
import '../widgets/chart_widget.dart';

/// Main chart class implementing grammar of graphics API
class CristalyseChart {
  List<Map<String, dynamic>> _data = [];
  String? _xColumn;
  String? _yColumn;
  String? _colorColumn;
  String? _sizeColumn;

  final List<Geometry> _geometries = [];
  Scale? _xScale;
  Scale? _yScale;
  ColorScale? _colorScale;
  SizeScale? _sizeScale;
  ChartTheme _theme = ChartTheme.defaultTheme();

  // Animation properties
  Duration _animationDuration = const Duration(milliseconds: 300);
  Curve _animationCurve = Curves.easeInOut;

  /// Set the data source for the chart
  ///
  /// Example:
  /// ```dart
  /// CristalyseChart().data([
  ///   {'x': 1, 'y': 2, 'category': 'A'},
  ///   {'x': 2, 'y': 3, 'category': 'B'},
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
  /// chart.mapping(x: 'date', y: 'value', color: 'category')
  /// ```
  CristalyseChart mapping({
    String? x,
    String? y,
    String? color,
    String? size,
  }) {
    _xColumn = x;
    _yColumn = y;
    _colorColumn = color;
    _sizeColumn = size;
    return this;
  }

  /// Add scatter plot points
  ///
  /// Example:
  /// ```dart
  /// chart.geom_point(size: 5.0, alpha: 0.7)
  /// ```
  CristalyseChart geom_point({
    double? size,
    Color? color,
    double? alpha,
  }) {
    _geometries.add(PointGeometry(
      size: size,
      color: color,
      alpha: alpha ?? 1.0,
    ));
    return this;
  }

  /// Add line chart
  ///
  /// Example:
  /// ```dart
  /// chart.geom_line(strokeWidth: 2.0, alpha: 0.8)
  /// ```
  CristalyseChart geom_line({
    double? strokeWidth,
    Color? color,
    double? alpha,
    LineStyle? style,
  }) {
    _geometries.add(LineGeometry(
      strokeWidth: strokeWidth ?? 2.0,
      color: color,
      alpha: alpha ?? 1.0,
      style: style ?? LineStyle.solid,
    ));
    return this;
  }

  /// Configure continuous X scale
  CristalyseChart scale_x_continuous({double? min, double? max}) {
    _xScale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure continuous Y scale
  CristalyseChart scale_y_continuous({double? min, double? max}) {
    _yScale = LinearScale(min: min, max: max);
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
  CristalyseChart animate({
    Duration? duration,
    Curve? curve,
  }) {
    _animationDuration = duration ?? _animationDuration;
    _animationCurve = curve ?? _animationCurve;
    return this;
  }

  /// Build the chart widget
  Widget build() {
    return AnimatedCristalyseChartWidget(
      data: _data,
      xColumn: _xColumn,
      yColumn: _yColumn,
      colorColumn: _colorColumn,
      sizeColumn: _sizeColumn,
      geometries: _geometries,
      xScale: _xScale,
      yScale: _yScale,
      colorScale: _colorScale,
      sizeScale: _sizeScale,
      theme: _theme,
      animationDuration: _animationDuration,
      animationCurve: _animationCurve,
    );
  }
}