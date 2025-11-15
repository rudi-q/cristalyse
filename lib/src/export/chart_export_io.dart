import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/animated_chart_widget.dart';
import 'chart_export.dart';

/// Platform-specific export implementation for mobile/desktop
Future<ExportResult> exportChartPlatform({
  required Widget chartWidget,
  required ExportConfig config,
  String? customPath,
}) async {
  switch (config.format) {
    case ExportFormat.svg:
      return await _exportToSvg(chartWidget, config, customPath);
  }
}

/// Export chart as SVG for mobile/desktop platforms
Future<ExportResult> _exportToSvg(
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

/// Get the default export path using path_provider
Future<String> _getExportPath(ExportConfig config, String extension) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  if (directory.path.isEmpty) {
    throw const ChartExportException('Could not access documents directory');
  }

  final String filename = config.filename ??
      'cristalyse_chart_${DateTime.now().millisecondsSinceEpoch}';

  return '${directory.path}/$filename.$extension';
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

  _ChartData? _extractChartData(Widget chartWidget) {
    // Extract data from AnimatedCristalyseChartWidget
    if (chartWidget is AnimatedCristalyseChartWidget) {
      return _ChartData(
        data: chartWidget.data,
        xColumn: chartWidget.xColumn,
        yColumn: chartWidget.yColumn,
        y2Column: chartWidget.y2Column,
        colorColumn: chartWidget.colorColumn,
        sizeColumn: chartWidget.sizeColumn,
        geometries: chartWidget.geometries,
        theme: chartWidget.theme,
      );
    }
    return null;
  }

  _Scale _setupXScale(_ChartData chartData, double plotWidth) {
    if (chartData.xColumn == null) {
      return _LinearScale(domain: [0, 1], range: [0, plotWidth]);
    }

    final xValues = chartData.data
        .map((d) => d[chartData.xColumn])
        .where((v) => v != null)
        .toList();

    if (xValues.isEmpty) {
      return _LinearScale(domain: [0, 1], range: [0, plotWidth]);
    }

    // Check if data is numeric or categorical
    final firstValue = xValues.first;
    if (firstValue is num) {
      final numValues = xValues.map((v) => (v as num).toDouble()).toList();
      final min = numValues.reduce((a, b) => a < b ? a : b);
      final max = numValues.reduce((a, b) => a > b ? a : b);
      return _LinearScale(domain: [min, max], range: [0, plotWidth]);
    } else {
      final categories = xValues.map((v) => v.toString()).toSet().toList();
      return _OrdinalScale(categories: categories, range: [0, plotWidth]);
    }
  }

  _Scale _setupYScale(_ChartData chartData, double plotHeight) {
    if (chartData.yColumn == null) {
      return _LinearScale(domain: [0, 1], range: [plotHeight, 0]);
    }

    final yValues = chartData.data
        .map((d) => d[chartData.yColumn])
        .where((v) => v != null)
        .toList();

    if (yValues.isEmpty) {
      return _LinearScale(domain: [0, 1], range: [plotHeight, 0]);
    }

    final numValues = yValues.map((v) => (v as num).toDouble()).toList();
    final min = numValues.reduce((a, b) => a < b ? a : b);
    final max = numValues.reduce((a, b) => a > b ? a : b);

    // Add some padding
    final range = max - min;
    final padding = range * 0.1;
    return _LinearScale(
      domain: [min - padding, max + padding],
      range: [plotHeight, 0],
    );
  }

  _Scale? _setupY2Scale(_ChartData chartData, double plotHeight) {
    if (chartData.y2Column == null) {
      return null;
    }

    final y2Values = chartData.data
        .map((d) => d[chartData.y2Column])
        .where((v) => v != null)
        .toList();

    if (y2Values.isEmpty) {
      return null;
    }

    final numValues = y2Values.map((v) => (v as num).toDouble()).toList();
    final min = numValues.reduce((a, b) => a < b ? a : b);
    final max = numValues.reduce((a, b) => a > b ? a : b);

    final range = max - min;
    final padding = range * 0.1;
    return _LinearScale(
      domain: [min - padding, max + padding],
      range: [plotHeight, 0],
    );
  }

  Map<String, String> _setupColorScale(_ChartData chartData) {
    final colorMap = <String, String>{};
    if (chartData.colorColumn == null) {
      return colorMap;
    }

    final colorValues = chartData.data
        .map((d) => d[chartData.colorColumn])
        .where((v) => v != null)
        .toSet()
        .toList();
    final defaultColors = [
      '#1f77b4',
      '#ff7f0e',
      '#2ca02c',
      '#d62728',
      '#9467bd',
      '#8c564b',
    ];

    for (int i = 0; i < colorValues.length; i++) {
      colorMap[colorValues[i].toString()] =
          defaultColors[i % defaultColors.length];
    }

    return colorMap;
  }

  Map<String, double> _setupSizeScale(_ChartData chartData) {
    final sizeMap = <String, double>{};
    if (chartData.sizeColumn == null) {
      return sizeMap;
    }

    final sizeValues = chartData.data
        .map((d) => d[chartData.sizeColumn])
        .where((v) => v != null)
        .toList();
    if (sizeValues.isEmpty) {
      return sizeMap;
    }

    final numValues = sizeValues.map((v) => (v as num).toDouble()).toList();
    final min = numValues.reduce((a, b) => a < b ? a : b);
    final max = numValues.reduce((a, b) => a > b ? a : b);

    for (final value in sizeValues) {
      final numValue = (value as num).toDouble();
      final normalized = (numValue - min) / (max - min);
      sizeMap[value.toString()] = 2 + normalized * 8; // Scale from 2 to 10
    }

    return sizeMap;
  }

  void _renderBackground(StringBuffer buffer, _Rect plotArea, dynamic theme) {
    // Render plot area background if needed
    buffer.writeln(
      '  <rect x="${plotArea.left}" y="${plotArea.top}" width="${plotArea.width}" height="${plotArea.height}" fill="none"/>',
    );
  }

  void _renderGrid(
    StringBuffer buffer,
    _Rect plotArea,
    _Scale xScale,
    _Scale yScale,
    dynamic theme,
  ) {
    final gridColor = '#e0e0e0';

    // Vertical grid lines
    if (xScale is _LinearScale) {
      final ticks = _getTicks(xScale.domain[0], xScale.domain[1], 5);
      for (final tick in ticks) {
        final x = plotArea.left + xScale.scale(tick);
        buffer.writeln(
          '  <line x1="$x" y1="${plotArea.top}" x2="$x" y2="${plotArea.top + plotArea.height}" stroke="$gridColor" stroke-width="1"/>',
        );
      }
    }

    // Horizontal grid lines
    if (yScale is _LinearScale) {
      final ticks = _getTicks(yScale.domain[0], yScale.domain[1], 5);
      for (final tick in ticks) {
        final y = plotArea.top + yScale.scale(tick);
        buffer.writeln(
          '  <line x1="${plotArea.left}" y1="$y" x2="${plotArea.left + plotArea.width}" y2="$y" stroke="$gridColor" stroke-width="1"/>',
        );
      }
    }
  }

  void _renderGeometries(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _Scale yScale,
    _Scale? y2Scale,
    Map<String, String> colorScale,
    Map<String, double> sizeScale,
  ) {
    for (final geometry in chartData.geometries) {
      if (geometry.toString().contains('Point')) {
        _renderPoints(
          buffer,
          plotArea,
          chartData,
          xScale,
          yScale,
          colorScale,
          sizeScale,
        );
      } else if (geometry.toString().contains('Line')) {
        _renderLines(buffer, plotArea, chartData, xScale, yScale, colorScale);
      } else if (geometry.toString().contains('Bar')) {
        _renderBars(buffer, plotArea, chartData, xScale, yScale, colorScale);
      }
    }
  }

  void _renderPoints(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _Scale yScale,
    Map<String, String> colorScale,
    Map<String, double> sizeScale,
  ) {
    for (final point in chartData.data) {
      final x = plotArea.left + xScale.scale(point[chartData.xColumn]);
      final y = plotArea.top + yScale.scale(point[chartData.yColumn]);
      final color =
          colorScale[point[chartData.colorColumn]?.toString()] ?? '#1f77b4';
      final size = sizeScale[point[chartData.sizeColumn]?.toString()] ?? 3.0;

      buffer.writeln('  <circle cx="$x" cy="$y" r="$size" fill="$color"/>');
    }
  }

  void _renderLines(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _Scale yScale,
    Map<String, String> colorScale,
  ) {
    if (chartData.data.length < 2) return;

    final points = chartData.data.map((point) {
      final x = plotArea.left + xScale.scale(point[chartData.xColumn]);
      final y = plotArea.top + yScale.scale(point[chartData.yColumn]);
      return '$x,$y';
    }).join(' ');

    final color =
        colorScale.values.isNotEmpty ? colorScale.values.first : '#1f77b4';
    buffer.writeln(
      '  <polyline points="$points" stroke="$color" stroke-width="2" fill="none"/>',
    );
  }

  void _renderBars(
    StringBuffer buffer,
    _Rect plotArea,
    _ChartData chartData,
    _Scale xScale,
    _Scale yScale,
    Map<String, String> colorScale,
  ) {
    final barWidth = plotArea.width / chartData.data.length * 0.8;

    for (int i = 0; i < chartData.data.length; i++) {
      final point = chartData.data[i];
      final x =
          plotArea.left + xScale.scale(point[chartData.xColumn]) - barWidth / 2;
      final yValue = yScale.scale(point[chartData.yColumn]);
      final y = plotArea.top + yValue;
      final height = plotArea.height - yValue;
      final color =
          colorScale[point[chartData.colorColumn]?.toString()] ?? '#1f77b4';

      buffer.writeln(
        '  <rect x="$x" y="$y" width="$barWidth" height="$height" fill="$color"/>',
      );
    }
  }

  void _renderAxes(
    StringBuffer buffer,
    _Rect plotArea,
    _Scale xScale,
    _Scale yScale,
    _Scale? y2Scale,
    dynamic theme,
  ) {
    final axisColor = '#333333';

    // X axis
    buffer.writeln(
      '  <line x1="${plotArea.left}" y1="${plotArea.top + plotArea.height}" x2="${plotArea.left + plotArea.width}" y2="${plotArea.top + plotArea.height}" stroke="$axisColor" stroke-width="1"/>',
    );

    // Y axis
    buffer.writeln(
      '  <line x1="${plotArea.left}" y1="${plotArea.top}" x2="${plotArea.left}" y2="${plotArea.top + plotArea.height}" stroke="$axisColor" stroke-width="1"/>',
    );

    // X axis labels
    if (xScale is _LinearScale) {
      final ticks = _getTicks(xScale.domain[0], xScale.domain[1], 5);
      for (final tick in ticks) {
        final x = plotArea.left + xScale.scale(tick);
        final y = plotArea.top + plotArea.height + 20;
        buffer.writeln(
          '  <text x="$x" y="$y" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="$axisColor">',
        );
        buffer.writeln('    ${_formatNumber(tick)}');
        buffer.writeln('  </text>');
      }
    } else if (xScale is _OrdinalScale) {
      for (int i = 0; i < xScale.categories.length; i++) {
        final category = xScale.categories[i];
        final x = plotArea.left + xScale.scale(category);
        final y = plotArea.top + plotArea.height + 20;
        buffer.writeln(
          '  <text x="$x" y="$y" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="$axisColor">',
        );
        buffer.writeln('    $category');
        buffer.writeln('  </text>');
      }
    }

    // Y axis labels
    if (yScale is _LinearScale) {
      final ticks = _getTicks(yScale.domain[0], yScale.domain[1], 5);
      for (final tick in ticks) {
        final x = plotArea.left - 10;
        final y = plotArea.top + yScale.scale(tick) + 4;
        buffer.writeln(
          '  <text x="$x" y="$y" text-anchor="end" font-family="Arial, sans-serif" font-size="12" fill="$axisColor">',
        );
        buffer.writeln('    ${_formatNumber(tick)}');
        buffer.writeln('  </text>');
      }
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
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }
}

// Helper classes
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
