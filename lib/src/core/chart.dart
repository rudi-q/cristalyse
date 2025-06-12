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

  bool _coordFlipped = false; // Added this line

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
  CristalyseChart mapping({String? x, String? y, String? color, String? size}) {
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
  /// chart.geomPoint(size: 5.0, alpha: 0.7)
  /// ```
  CristalyseChart geomPoint({
    double? size,
    Color? color,
    double? alpha,
    PointShape? shape,
    double? borderWidth,
  }) {
    _geometries.add(
      PointGeometry(
        size: size,
        color: color,
        alpha: alpha ?? 1.0,
        shape: shape ?? PointShape.circle,
        borderWidth: borderWidth ?? 0.0,
      ),
    );
    return this;
  }

  /// Add line chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomLine(strokeWidth: 2.0, alpha: 0.8)
  /// ```
  CristalyseChart geomLine({
    double? strokeWidth,
    Color? color,
    double? alpha,
    LineStyle? style,
  }) {
    _geometries.add(
      LineGeometry(
        strokeWidth: strokeWidth ?? 2.0,
        color: color,
        alpha: alpha ?? 1.0,
        style: style ?? LineStyle.solid,
      ),
    );
    return this;
  }

  /// Add bar chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomBar(width: 0.8, orientation: BarOrientation.vertical)
  /// ```
  CristalyseChart geomBar({
    double? width,
    Color? color,
    double? alpha,
    BarOrientation? orientation,
    BarStyle? style,
    BorderRadius? borderRadius,
    double? borderWidth,
  }) {
    final barGeom = BarGeometry(
      width: width ?? 0.8,
      color: color,
      alpha: alpha ?? 1.0,
      orientation: orientation ?? BarOrientation.vertical,
      style: style ?? BarStyle.grouped,
      borderRadius: borderRadius,
      borderWidth: borderWidth ?? 0.0,
    );
    _geometries.add(barGeom);
    return this;
  }

  /// Configure continuous X scale
  CristalyseChart scaleXContinuous({double? min, double? max}) {
    _xScale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure continuous Y scale
  CristalyseChart scaleYContinuous({double? min, double? max}) {
    _yScale = LinearScale(min: min, max: max);
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
      coordFlipped: _coordFlipped,
    );
  }
}