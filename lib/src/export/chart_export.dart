import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../core/geometry.dart';
import '../widgets/animated_chart_widget.dart';

/// Export formats supported by the chart
enum ExportFormat { svg }

/// Configuration for chart export
class ExportConfig {
  /// Width of the exported image in pixels
  final double width;

  /// Height of the exported image in pixels
  final double height;

  /// Export format (PNG or SVG)
  final ExportFormat format;

  /// Background color of the exported image
  final Color? backgroundColor;

  /// Custom filename (without extension)
  final String? filename;

  /// Quality for PNG export (0.0 to 1.0)
  final double quality;

  /// Whether to include a transparent background (PNG only)
  final bool transparentBackground;

  const ExportConfig({
    this.width = 800,
    this.height = 600,
    this.format = ExportFormat.svg,
    this.backgroundColor,
    this.filename,
    this.quality = 1.0,
    this.transparentBackground = false,
  });

  ExportConfig copyWith({
    double? width,
    double? height,
    ExportFormat? format,
    Color? backgroundColor,
    String? filename,
    double? quality,
    bool? transparentBackground,
  }) {
    return ExportConfig(
      width: width ?? this.width,
      height: height ?? this.height,
      format: format ?? this.format,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      filename: filename ?? this.filename,
      quality: quality ?? this.quality,
      transparentBackground:
          transparentBackground ?? this.transparentBackground,
    );
  }
}

/// Result of a chart export operation
class ExportResult {
  /// Path to the exported file
  final String filePath;

  /// Size of the exported file in bytes
  final int fileSizeBytes;

  /// Export format used
  final ExportFormat format;

  /// Dimensions of the exported image
  final Size dimensions;

  const ExportResult({
    required this.filePath,
    required this.fileSizeBytes,
    required this.format,
    required this.dimensions,
  });

  @override
  String toString() {
    return 'ExportResult(path: $filePath, size: ${fileSizeBytes}B, format: $format, dimensions: ${dimensions.width}x${dimensions.height})';
  }
}

/// Exception thrown when export fails
class ChartExportException implements Exception {
  final String message;
  final dynamic originalError;

  const ChartExportException(this.message, [this.originalError]);

  @override
  String toString() =>
      'ChartExportException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Main class for exporting charts to various formats
class ChartExporter {
  /// Export a chart widget to the specified format
  static Future<ExportResult> exportChart({
    required Widget chartWidget,
    required ExportConfig config,
    String? customPath,
  }) async {
    try {
      switch (config.format) {
        case ExportFormat.svg:
          return await _exportToSvg(chartWidget, config, customPath);
      }
    } catch (e) {
      throw ChartExportException('Failed to export chart: ${e.toString()}', e);
    }
  }

  /// Export chart as SVG
  static Future<ExportResult> _exportToSvg(
    Widget chartWidget,
    ExportConfig config,
    String? customPath,
  ) async {
    // For SVG export, we'll create a custom painter that outputs SVG commands
    final SvgExportPainter painter = SvgExportPainter(
      width: config.width,
      height: config.height,
      backgroundColor: config.backgroundColor,
    );

    // Generate SVG content
    final String svgContent = painter.generateSvg(chartWidget);

    // Save to file
    final String filePath = customPath ?? await _getExportPath(config, 'svg');
    final File file = File(filePath);
    await file.writeAsString(svgContent);

    final int fileSize = svgContent.length;

    return ExportResult(
      filePath: filePath,
      fileSizeBytes: fileSize,
      format: ExportFormat.svg,
      dimensions: Size(config.width, config.height),
    );
  }

  /// Get the default export path
  static Future<String> _getExportPath(
    ExportConfig config,
    String extension,
  ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    if (directory.path.isEmpty) {
      throw const ChartExportException('Could not access documents directory');
    }

    final String filename = config.filename ??
        'cristalyse_chart_${DateTime.now().millisecondsSinceEpoch}';

    return '${directory.path}/$filename.$extension';
  }

  /// Global build owner for rendering
  static final BuildOwner buildOwner = BuildOwner();
}

/// Custom painter for SVG export
class SvgExportPainter {
  final double width;
  final double height;
  final Color? backgroundColor;

  SvgExportPainter({
    required this.width,
    required this.height,
    this.backgroundColor,
  });

  String generateSvg(Widget chartWidget) {
    final StringBuffer buffer = StringBuffer();

    // SVG header
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<svg width="$width" height="$height" '
      'xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink">',
    );

    // Background
    if (backgroundColor != null) {
      final color = _colorToHex(backgroundColor!);
      buffer.writeln('  <rect width="$width" height="$height" fill="$color"/>');
    }

    // Extract chart data and render to SVG
    _renderChartToSvg(chartWidget, buffer);

    // SVG footer
    buffer.writeln('</svg>');

    return buffer.toString();
  }

  void _renderChartToSvg(Widget chartWidget, StringBuffer buffer) {
    // Extract chart data from the widget tree
    final chartData = _extractChartData(chartWidget);
    if (chartData == null) {
      // Fallback for unsupported chart types
      buffer.writeln(
        '  <text x="50%" y="50%" text-anchor="middle" '
        'dominant-baseline="middle" font-family="Arial, sans-serif" '
        'font-size="16" fill="#666">',
      );
      buffer.writeln('    Chart SVG Export');
      buffer.writeln('  </text>');
      return;
    }

    // Calculate plot area
    final padding = chartData.theme.padding;
    final plotArea = _Rect(
      left: padding.left,
      top: padding.top,
      width: width - padding.horizontal,
      height: height - padding.vertical,
    );

    // Setup scales for both Y-axes
    final xScale = _setupXScale(chartData, plotArea.width);
    final yScale = _setupYScale(chartData, plotArea.height);
    final y2Scale = _setupY2Scale(chartData, plotArea.height);
    final colorScale = _setupColorScale(chartData);
    final sizeScale = _setupSizeScale(chartData);

    // Render chart elements
    _renderBackground(buffer, plotArea, chartData.theme);
    _renderGrid(buffer, plotArea, xScale, yScale, chartData.theme);
    _renderGeometries(
      buffer,
      plotArea,
      chartData,
      xScale,
      yScale,
      y2Scale,
      colorScale,
      sizeScale,
    );
    _renderAxes(buffer, plotArea, xScale, yScale, y2Scale, chartData.theme);
  }

  _ChartData? _extractChartData(Widget widget) {
    // Extract data from AnimatedCristalyseChartWidget
    if (widget is AnimatedCristalyseChartWidget) {
      return _ChartData(
        data: widget.data,
        xColumn: widget.xColumn,
        yColumn: widget.yColumn,
        y2Column: widget.y2Column,
        colorColumn: widget.colorColumn,
        sizeColumn: widget.sizeColumn,
        geometries: widget.geometries,
        theme: widget.theme,
      );
    }
    return null;
  }

  _Scale _setupXScale(_ChartData chartData, double width) {
    // First try to extract as numeric values
    final numericValues = chartData.data
        .map((d) => _getNumericValue(d[chartData.xColumn]))
        .where((v) => v != null)
        .cast<double>();

    // If we have numeric values, use linear scale
    if (numericValues.isNotEmpty &&
        numericValues.length == chartData.data.length) {
      final min = numericValues.reduce((a, b) => a < b ? a : b);
      final max = numericValues.reduce((a, b) => a > b ? a : b);
      return _LinearScale(domain: [min, max], range: [0, width]);
    }

    // Otherwise, treat as ordinal/categorical data
    final categories = chartData.data
        .map((d) => d[chartData.xColumn]?.toString() ?? '')
        .where((v) => v.isNotEmpty)
        .toList();

    if (categories.isEmpty) {
      return _LinearScale(domain: [0, 1], range: [0, width]);
    }

    return _OrdinalScale(categories: categories, range: [0, width]);
  }

  _LinearScale _setupYScale(_ChartData chartData, double height) {
    final values = chartData.data
        .map((d) => _getNumericValue(d[chartData.yColumn]))
        .where((v) => v != null)
        .cast<double>();

    if (values.isEmpty) return _LinearScale(domain: [0, 1], range: [height, 0]);

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return _LinearScale(
      domain: [min, max],
      range: [height, 0], // Inverted for screen coordinates
    );
  }

  _LinearScale _setupY2Scale(_ChartData chartData, double height) {
    if (chartData.y2Column == null) {
      return _LinearScale(domain: [0, 1], range: [height, 0]);
    }

    final values = chartData.data
        .map((d) => _getNumericValue(d[chartData.y2Column]))
        .where((v) => v != null)
        .cast<double>();

    if (values.isEmpty) return _LinearScale(domain: [0, 1], range: [height, 0]);

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return _LinearScale(
      domain: [min, max],
      range: [height, 0], // Inverted for screen coordinates
    );
  }

  _ColorScale _setupColorScale(_ChartData chartData) {
    if (chartData.colorColumn == null) {
      return _ColorScale(values: [], colors: chartData.theme.colorPalette);
    }

    final values =
        chartData.data.map((d) => d[chartData.colorColumn]).toSet().toList();
    return _ColorScale(values: values, colors: chartData.theme.colorPalette);
  }

  _SizeScale _setupSizeScale(_ChartData chartData) {
    if (chartData.sizeColumn == null) {
      return _SizeScale(domain: [1, 1], range: [4, 12]);
    }

    final values = chartData.data
        .map((d) => _getNumericValue(d[chartData.sizeColumn]))
        .where((v) => v != null)
        .cast<double>();

    if (values.isEmpty) return _SizeScale(domain: [1, 1], range: [4, 12]);

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return _SizeScale(domain: [min, max], range: [4, 12]);
  }

  double? _getNumericValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _renderBackground(StringBuffer buffer, _Rect plotArea, dynamic theme) {
    final color = _colorToHex(
      theme.plotBackgroundColor ?? theme.backgroundColor,
    );
    buffer.writeln(
      '  <rect x="${plotArea.left}" y="${plotArea.top}" '
      'width="${plotArea.width}" height="${plotArea.height}" '
      'fill="$color"/>',
    );
  }

  void _renderGrid(
    StringBuffer buffer,
    _Rect plotArea,
    _Scale xScale,
    _LinearScale yScale,
    dynamic theme,
  ) {
    final gridColor = _colorToHex(theme.gridColor);

    // Vertical grid lines (only for linear scales)
    if (xScale is _LinearScale) {
      final xTicks = _getTicks(xScale.domain[0], xScale.domain[1], 5);
      for (final tick in xTicks) {
        final x = plotArea.left + xScale.scale(tick);
        buffer.writeln(
          '  <line x1="$x" y1="${plotArea.top}" '
          'x2="$x" y2="${plotArea.top + plotArea.height}" '
          'stroke="$gridColor" stroke-width="0.5"/>',
        );
      }
    }

    // Horizontal grid lines
    final yTicks = _getTicks(yScale.domain[0], yScale.domain[1], 5);
    for (final tick in yTicks) {
      final y = plotArea.top + yScale.scale(tick);
      buffer.writeln(
        '  <line x1="${plotArea.left}" y1="$y" '
        'x2="${plotArea.left + plotArea.width}" y2="$y" '
        'stroke="$gridColor" stroke-width="0.5"/>',
      );
    }
  }

  void _renderGeometries(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _LinearScale yScale,
    _LinearScale y2Scale,
    _ColorScale colorScale,
    _SizeScale sizeScale,
  ) {
    for (final geometry in chartData.geometries) {
      // Determine which Y scale to use based on geometry's yAxis property
      final currentYScale = _getYScaleForGeometry(geometry, yScale, y2Scale);
      final yColumnForGeometry = _getYColumnForGeometry(geometry, chartData);

      if (geometry.toString().contains('PointGeometry')) {
        _renderPoints(
          buffer,
          plotArea,
          chartData,
          xScale,
          currentYScale,
          yColumnForGeometry,
          colorScale,
          sizeScale,
          geometry,
        );
      } else if (geometry.toString().contains('LineGeometry')) {
        _renderLines(
          buffer,
          plotArea,
          chartData,
          xScale,
          currentYScale,
          yColumnForGeometry,
          colorScale,
          geometry,
        );
      } else if (geometry.toString().contains('BarGeometry')) {
        _renderBars(
          buffer,
          plotArea,
          chartData,
          xScale,
          currentYScale,
          yColumnForGeometry,
          colorScale,
          geometry,
        );
      } else if (geometry.toString().contains('AreaGeometry')) {
        _renderAreas(
          buffer,
          plotArea,
          chartData,
          xScale,
          currentYScale,
          yColumnForGeometry,
          colorScale,
          geometry,
        );
      }
    }
  }

  /// Get the appropriate Y scale based on geometry's yAxis property
  _LinearScale _getYScaleForGeometry(
      dynamic geometry, _LinearScale yScale, _LinearScale y2Scale) {
    // Access the yAxis property directly from the geometry object
    if (geometry.yAxis == YAxis.secondary) {
      return y2Scale;
    }
    return yScale;
  }

  /// Get the appropriate Y column based on geometry's yAxis property
  String? _getYColumnForGeometry(dynamic geometry, _ChartData chartData) {
    // Access the yAxis property directly from the geometry object
    if (geometry.yAxis == YAxis.secondary) {
      return chartData.y2Column;
    }
    return chartData.yColumn;
  }

  void _renderPoints(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _LinearScale yScale,
    String? yColumn,
    _ColorScale colorScale,
    _SizeScale sizeScale,
    dynamic geometry,
  ) {
    for (final point in chartData.data) {
      final xValue = point[chartData.xColumn];
      final y = _getNumericValue(point[yColumn]);

      if (xValue == null || y == null) continue;

      final screenX = plotArea.left + xScale.scale(xValue);
      final screenY = plotArea.top + yScale.scale(y);

      // Use geometry's color or color from palette for points
      final Color geometryColor = geometry.color ??
          (chartData.theme.colorPalette.isNotEmpty
              ? chartData.theme.colorPalette[1]
              : chartData.theme.primaryColor);
      final size = sizeScale.getSize(point[chartData.sizeColumn]);

      buffer.writeln(
        '  <circle cx="$screenX" cy="$screenY" r="$size" '
        'fill="${_colorToHex(geometryColor)}" fill-opacity="0.8"/>',
      );
    }
  }

  void _renderLines(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _LinearScale yScale,
    String? yColumn,
    _ColorScale colorScale,
    dynamic geometry,
  ) {
    final points = <String>[];
    for (final point in chartData.data) {
      final xValue = point[chartData.xColumn];
      final y = _getNumericValue(point[yColumn]);

      if (xValue == null || y == null) continue;

      final screenX = plotArea.left + xScale.scale(xValue);
      final screenY = plotArea.top + yScale.scale(y);

      points.add('$screenX,$screenY');
    }

    if (points.isNotEmpty) {
      // Use geometry's color or color from palette
      final Color geometryColor = geometry.color ??
          (chartData.theme.colorPalette.isNotEmpty
              ? chartData.theme.colorPalette[1]
              : chartData.theme.primaryColor);
      final color = _colorToHex(geometryColor);
      buffer.writeln(
        '  <polyline points="${points.join(' ')}" '
        'fill="none" stroke="$color" stroke-width="3"/>',
      );
    }
  }

  void _renderBars(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _LinearScale yScale,
    String? yColumn,
    _ColorScale colorScale,
    dynamic geometry,
  ) {
    final barWidth = plotArea.width / chartData.data.length * 0.8;

    for (int i = 0; i < chartData.data.length; i++) {
      final point = chartData.data[i];
      final y = _getNumericValue(point[yColumn]);

      if (y == null) continue;

      final x = plotArea.left +
          (i + 0.5) * (plotArea.width / chartData.data.length) -
          barWidth / 2;
      final barHeight = (plotArea.height - yScale.scale(y)).abs();
      final barY = plotArea.top + yScale.scale(y);

      final color = colorScale.getColor(point[chartData.colorColumn]);

      buffer.writeln(
        '  <rect x="$x" y="$barY" '
        'width="$barWidth" height="$barHeight" '
        'fill="${_colorToHex(color)}" fill-opacity="0.8"/>',
      );
    }
  }

  void _renderAreas(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _LinearScale yScale,
    String? yColumn,
    _ColorScale colorScale,
    dynamic geometry,
  ) {
    final points = <String>[];
    final baseline = plotArea.top + plotArea.height;

    // Start from baseline
    if (chartData.data.isNotEmpty) {
      final firstXValue = chartData.data.first[chartData.xColumn];
      if (firstXValue != null) {
        final startX = plotArea.left + xScale.scale(firstXValue);
        points.add('$startX,$baseline');
      }
    }

    // Add data points
    for (final point in chartData.data) {
      final xValue = point[chartData.xColumn];
      final y = _getNumericValue(point[yColumn]);

      if (xValue == null || y == null) continue;

      final screenX = plotArea.left + xScale.scale(xValue);
      final screenY = plotArea.top + yScale.scale(y);

      points.add('$screenX,$screenY');
    }

    // End at baseline
    if (chartData.data.isNotEmpty) {
      final lastXValue = chartData.data.last[chartData.xColumn];
      if (lastXValue != null) {
        final endX = plotArea.left + xScale.scale(lastXValue);
        points.add('$endX,$baseline');
      }
    }

    if (points.length > 2) {
      final color = _colorToHex(chartData.theme.primaryColor);
      buffer.writeln(
        '  <polygon points="${points.join(' ')}" '
        'fill="$color" fill-opacity="0.3" '
        'stroke="$color" stroke-width="2"/>',
      );
    }
  }

  void _renderAxes(
    StringBuffer buffer,
    _Rect plotArea,
    _Scale xScale,
    _LinearScale yScale,
    _LinearScale y2Scale,
    dynamic theme,
  ) {
    final axisColor = _colorToHex(theme.axisColor);

    // X axis
    buffer.writeln(
      '  <line x1="${plotArea.left}" y1="${plotArea.top + plotArea.height}" '
      'x2="${plotArea.left + plotArea.width}" y2="${plotArea.top + plotArea.height}" '
      'stroke="$axisColor" stroke-width="1"/>',
    );

    // Y axis
    buffer.writeln(
      '  <line x1="${plotArea.left}" y1="${plotArea.top}" '
      'x2="${plotArea.left}" y2="${plotArea.top + plotArea.height}" '
      'stroke="$axisColor" stroke-width="1"/>',
    );

    // X axis labels
    if (xScale is _LinearScale) {
      final xTicks = _getTicks(xScale.domain[0], xScale.domain[1], 5);
      for (final tick in xTicks) {
        final x = plotArea.left + xScale.scale(tick);
        final y = plotArea.top + plotArea.height + 20;
        buffer.writeln(
          '  <text x="$x" y="$y" text-anchor="middle" '
          'font-family="Arial, sans-serif" font-size="12" fill="${_colorToHex(theme.axisColor)}">',
        );
        buffer.writeln('    ${_formatNumber(tick)}');
        buffer.writeln('  </text>');
      }
    } else if (xScale is _OrdinalScale) {
      // Render ordinal/categorical labels
      for (int i = 0; i < xScale.categories.length; i++) {
        final category = xScale.categories[i];
        final x = plotArea.left + xScale.scale(category);
        final y = plotArea.top + plotArea.height + 20;
        buffer.writeln(
          '  <text x="$x" y="$y" text-anchor="middle" '
          'font-family="Arial, sans-serif" font-size="12" fill="${_colorToHex(theme.axisColor)}">',
        );
        buffer.writeln('    $category');
        buffer.writeln('  </text>');
      }
    }

    // Y axis labels
    final yTicks = _getTicks(yScale.domain[0], yScale.domain[1], 5);
    for (final tick in yTicks) {
      final x = plotArea.left - 40;
      final y = plotArea.top + yScale.scale(tick) + 4;
      buffer.writeln(
        '  <text x="$x" y="$y" text-anchor="end" '
        'font-family="Arial, sans-serif" font-size="12" fill="${_colorToHex(theme.axisColor)}">',
      );
      buffer.writeln('    ${_formatNumber(tick)}');
      buffer.writeln('  </text>');
    }
  }

  List<double> _getTicks(double min, double max, int count) {
    final range = max - min;
    final step = range / (count - 1);
    return List.generate(count, (i) => min + i * step);
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  String _colorToHex(Color color) {
    // Extract RGB components using deprecated but widely compatible properties
    // ignore: deprecated_member_use
    final int red = color.red;
    // ignore: deprecated_member_use
    final int green = color.green;
    // ignore: deprecated_member_use
    final int blue = color.blue;
    return '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
  }
}

/// Helper classes for SVG rendering
class _ChartData {
  final List<Map<String, dynamic>> data;
  final String? xColumn;
  final String? yColumn;
  final String? y2Column;
  final String? colorColumn;
  final String? sizeColumn;
  final List geometries;
  final dynamic theme;

  _ChartData({
    required this.data,
    this.xColumn,
    this.yColumn,
    this.y2Column,
    this.colorColumn,
    this.sizeColumn,
    required this.geometries,
    required this.theme,
  });
}

class _Rect {
  final double left;
  final double top;
  final double width;
  final double height;

  _Rect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

/// Abstract base class for scales
abstract class _Scale {
  double scale(dynamic value);
}

class _LinearScale extends _Scale {
  final List<double> domain;
  final List<double> range;

  _LinearScale({required this.domain, required this.range});

  @override
  double scale(dynamic value) {
    final numValue =
        value is num ? value.toDouble() : double.tryParse(value.toString());
    if (numValue == null) return range[0];

    final domainRange = domain[1] - domain[0];
    final rangeSpan = range[1] - range[0];
    return range[0] + (numValue - domain[0]) / domainRange * rangeSpan;
  }
}

class _OrdinalScale extends _Scale {
  final List<String> categories;
  final List<double> range;

  _OrdinalScale({required this.categories, required this.range});

  @override
  double scale(dynamic value) {
    final stringValue = value?.toString() ?? '';
    final index = categories.indexOf(stringValue);
    if (index == -1) return range[0];

    // Map to band centers for ordinal data
    final bandWidth = (range[1] - range[0]) / categories.length;
    return range[0] + (index + 0.5) * bandWidth;
  }
}

class _ColorScale {
  final List values;
  final List<Color> colors;

  _ColorScale({required this.values, required this.colors});

  Color getColor(dynamic value) {
    if (value == null || colors.isEmpty) {
      return colors.isNotEmpty ? colors[0] : const Color(0xFF2196F3);
    }
    final index = values.indexOf(value);
    return colors[index % colors.length];
  }
}

class _SizeScale {
  final List<double> domain;
  final List<double> range;

  _SizeScale({required this.domain, required this.range});

  double getSize(dynamic value) {
    final numValue = value is num ? value.toDouble() : null;
    if (numValue == null) return range[0];

    final domainRange = domain[1] - domain[0];
    if (domainRange == 0) return range[0];

    final rangeSpan = range[1] - range[0];
    return range[0] + (numValue - domain[0]) / domainRange * rangeSpan;
  }
}

/// Extension methods for easy chart export
extension ChartExportExtension on Widget {
  /// Export this chart widget as SVG
  Future<ExportResult> exportAsSvg({
    double width = 800,
    double height = 600,
    Color? backgroundColor,
    String? filename,
    String? customPath,
  }) async {
    final config = ExportConfig(
      width: width,
      height: height,
      format: ExportFormat.svg,
      backgroundColor: backgroundColor,
      filename: filename,
    );

    return ChartExporter.exportChart(
      chartWidget: this,
      config: config,
      customPath: customPath,
    );
  }
}
