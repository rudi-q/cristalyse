import 'package:flutter/material.dart';

// Conditional imports for platform-specific implementations
import 'chart_export_stub.dart'
if (dart.library.io) 'chart_export_io.dart'
if (dart.library.html) 'chart_export_web.dart';

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
      // Delegate to platform-specific implementation
      return await exportChartPlatform(
        chartWidget: chartWidget,
        config: config,
        customPath: customPath,
      );
    } catch (e) {
      throw ChartExportException('Failed to export chart: ${e.toString()}', e);
    }
  }

  /// Global build owner for rendering
  static final BuildOwner buildOwner = BuildOwner();
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