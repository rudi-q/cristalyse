import 'package:flutter/material.dart';

import 'chart_export.dart';

/// Stub implementation for unsupported platforms
Future<ExportResult> exportChartPlatform({
  required Widget chartWidget,
  required ExportConfig config,
  String? customPath,
}) async {
  throw const ChartExportException(
    'Chart export is not supported on this platform. '
    'Export is available on iOS, Android, Web, Windows, macOS, and Linux.',
  );
}
