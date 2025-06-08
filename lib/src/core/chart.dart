import 'package:flutter/material.dart';
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

  /// Build the chart widget
  Widget build() {
    return CristalyseChartWidget(
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
    );
  }
}
