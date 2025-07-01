import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// Export formats supported by the chart
enum ExportFormat { png, svg }

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
    this.format = ExportFormat.png,
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
      transparentBackground: transparentBackground ?? this.transparentBackground,
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
  String toString() => 'ChartExportException: $message${originalError != null ? ' ($originalError)' : ''}';
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
        case ExportFormat.png:
          return await _exportToPng(chartWidget, config, customPath);
        case ExportFormat.svg:
          return await _exportToSvg(chartWidget, config, customPath);
      }
    } catch (e) {
      throw ChartExportException(
        'Failed to export chart: ${e.toString()}',
        e,
      );
    }
  }

  /// Export chart as PNG
  static Future<ExportResult> _exportToPng(
    Widget chartWidget,
    ExportConfig config,
    String? customPath,
  ) async {
    // Create a render object for the chart
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    final RenderView renderView = RenderView(
      configuration: const ViewConfiguration(
        devicePixelRatio: 1.0,
      ),
      view: WidgetsBinding.instance.platformDispatcher.views.first,
    );

    // Build the widget tree
    final RenderObjectToWidgetAdapter<RenderBox> adapter =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: RepaintBoundary(
        child: Container(
          width: config.width,
          height: config.height,
          color: config.transparentBackground 
              ? Colors.transparent 
              : (config.backgroundColor ?? Colors.white),
          child: chartWidget,
        ),
      ),
    );

    final RenderObjectToWidgetElement<RenderBox> element =
        adapter.attachToRenderTree(buildOwner);

    // Layout and paint
    renderView.child = boundary;
    renderView.scheduleInitialLayout();
    renderView.scheduleInitialPaint(
      TransformLayer()..transform = Matrix4.identity(),
    );

    // Pump the rendering pipeline
    buildOwner.buildScope(element, () {});
    buildOwner.finalizeTree();

    // Create image from render
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw const ChartExportException('Failed to generate PNG data');
    }

    // Save to file
    final String filePath = customPath ?? await _getExportPath(config, 'png');
    final File file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return ExportResult(
      filePath: filePath,
      fileSizeBytes: byteData.lengthInBytes,
      format: ExportFormat.png,
      dimensions: Size(config.width, config.height),
    );
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
  static Future<String> _getExportPath(ExportConfig config, String extension) async {
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
    buffer.writeln('<svg width="$width" height="$height" '
        'xmlns="http://www.w3.org/2000/svg" '
        'xmlns:xlink="http://www.w3.org/1999/xlink">');

    // Background
    if (backgroundColor != null) {
      final color = _colorToHex(backgroundColor!);
      buffer.writeln('  <rect width="$width" height="$height" fill="$color"/>');
    }

    // For now, we'll create a placeholder SVG
    // In a full implementation, we'd traverse the widget tree and convert
    // CustomPainter operations to SVG elements
    buffer.writeln('  <!-- Chart content would be generated here -->');
    buffer.writeln('  <text x="50%" y="50%" text-anchor="middle" '
        'dominant-baseline="middle" font-family="Arial, sans-serif" '
        'font-size="16" fill="#666">');
    buffer.writeln('    SVG Export - Chart Content');
    buffer.writeln('  </text>');

    // SVG footer
    buffer.writeln('</svg>');

    return buffer.toString();
  }

  String _colorToHex(Color color) {
    // Convert RGB components to hex string
    final int red = (color.r * 255).round();
    final int green = (color.g * 255).round();
    final int blue = (color.b * 255).round();
    return '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
  }
}

/// Extension methods for easy chart export
extension ChartExportExtension on Widget {
  /// Export this chart widget as PNG
  Future<ExportResult> exportAsPng({
    double width = 800,
    double height = 600,
    double quality = 1.0,
    Color? backgroundColor,
    String? filename,
    String? customPath,
    bool transparentBackground = false,
  }) async {
    final config = ExportConfig(
      width: width,
      height: height,
      format: ExportFormat.png,
      quality: quality,
      backgroundColor: backgroundColor,
      filename: filename,
      transparentBackground: transparentBackground,
    );

    return ChartExporter.exportChart(
      chartWidget: this,
      config: config,
      customPath: customPath,
    );
  }

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
