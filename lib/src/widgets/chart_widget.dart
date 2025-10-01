import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/scale.dart';
import '../themes/chart_theme.dart';

/// Chart widget that handles rendering
class CristalyseChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String? xColumn;
  final String? yColumn;
  final String? colorColumn;
  final String? sizeColumn;
  final List<Geometry> geometries;
  final Scale? xScale;
  final Scale? yScale;
  final ColorScale? colorScale;
  final SizeScale? sizeScale;
  final ChartTheme theme;

  const CristalyseChartWidget({
    super.key,
    required this.data,
    this.xColumn,
    this.yColumn,
    this.colorColumn,
    this.sizeColumn,
    required this.geometries,
    this.xScale,
    this.yScale,
    this.colorScale,
    this.sizeScale,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border.all(color: theme.borderColor),
      ),
      child: CustomPaint(
        painter: _ChartPainter(
          data: data,
          xColumn: xColumn,
          yColumn: yColumn,
          colorColumn: colorColumn,
          sizeColumn: sizeColumn,
          geometries: geometries,
          xScale: xScale,
          yScale: yScale,
          colorScale: colorScale,
          sizeScale: sizeScale,
          theme: theme,
        ),
        child: Container(),
      ),
    );
  }
}

/// Custom painter for chart rendering
class _ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String? xColumn;
  final String? yColumn;
  final String? colorColumn;
  final String? sizeColumn;
  final List<Geometry> geometries;
  final Scale? xScale;
  final Scale? yScale;
  final ColorScale? colorScale;
  final SizeScale? sizeScale;
  final ChartTheme theme;

  _ChartPainter({
    required this.data,
    this.xColumn,
    this.yColumn,
    this.colorColumn,
    this.sizeColumn,
    required this.geometries,
    this.xScale,
    this.yScale,
    this.colorScale,
    this.sizeScale,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || geometries.isEmpty) return;

    // Calculate plot area (leaving space for axes)
    final plotArea = Rect.fromLTWH(
      theme.padding.left,
      theme.padding.top,
      size.width - theme.padding.horizontal,
      size.height - theme.padding.vertical,
    );

    // Setup scales
    final xScale = _setupXScale(plotArea.width);
    final yScale = _setupYScale(plotArea.height);
    final colorScale = _setupColorScale();
    final sizeScale = _setupSizeScale();

    // Draw background
    _drawBackground(canvas, plotArea);

    // Draw grid
    _drawGrid(canvas, plotArea, xScale, yScale);

    // Draw geometries
    for (final geometry in geometries) {
      _drawGeometry(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        sizeScale,
      );
    }

    // Draw axes
    _drawAxes(canvas, size, plotArea, xScale, yScale);
  }

  LinearScale _setupXScale(double width) {
    final scale = (xScale as LinearScale?) ?? LinearScale();
    final values = data
        .map((d) => _getNumericValue(d[xColumn]))
        .where((v) => v != null)
        .cast<double>();
    if (values.isNotEmpty) {
      scale.setBounds(values.toList(), null, geometries);
    }
    scale.range = [0, width];
    return scale;
  }

  LinearScale _setupYScale(double height) {
    final scale = (yScale as LinearScale?) ?? LinearScale();
    final values = data
        .map((d) => _getNumericValue(d[yColumn]))
        .where((v) => v != null)
        .cast<double>();
    if (values.isNotEmpty) {
      scale.setBounds(values.toList(), null, geometries);
    }
    scale.range = [height, 0]; // Inverted for screen coordinates
    return scale;
  }

  ColorScale _setupColorScale() {
    if (colorColumn == null) return ColorScale();

    final values = data.map((d) => d[colorColumn]).toSet().toList();
    return ColorScale(values: values, colors: theme.colorPalette);
  }

  SizeScale _setupSizeScale() {
    if (sizeColumn == null) return SizeScale();

    final values = data
        .map((d) => _getNumericValue(d[sizeColumn]))
        .where((v) => v != null)
        .cast<double>();
    if (values.isNotEmpty) {
      // Visual range always comes from theme
      final sizeScale = SizeScale(
        range: [theme.pointSizeMin, theme.pointSizeMax],
      );

      // Get domain limits from bubble geometry if available
      final bubbleGeometries = geometries.whereType<BubbleGeometry>().toList();
      final limits =
          bubbleGeometries.isNotEmpty ? bubbleGeometries.first.limits : null;

      sizeScale.setBounds(values.toList(), limits, geometries);
      return sizeScale;
    }
    return SizeScale();
  }

  double? _getNumericValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _drawBackground(Canvas canvas, Rect plotArea) {
    final paint = Paint()..color = theme.plotBackgroundColor;
    canvas.drawRect(plotArea, paint);
  }

  void _drawGrid(
    Canvas canvas,
    Rect plotArea,
    LinearScale xScale,
    LinearScale yScale,
  ) {
    final paint = Paint()
      ..color = theme.gridColor
      ..strokeWidth = theme.gridWidth;

    // Vertical grid lines
    final xTicks = xScale.getTicks();
    for (final tick in xTicks) {
      final x = plotArea.left + xScale.scale(tick);
      canvas.drawLine(
        Offset(x, plotArea.top),
        Offset(x, plotArea.bottom),
        paint,
      );
    }

    // Horizontal grid lines
    final yTicks = yScale.getTicks();
    for (final tick in yTicks) {
      final y = plotArea.top + yScale.scale(tick);
      canvas.drawLine(
        Offset(plotArea.left, y),
        Offset(plotArea.right, y),
        paint,
      );
    }
  }

  void _drawGeometry(
    Canvas canvas,
    Rect plotArea,
    Geometry geometry,
    LinearScale xScale,
    LinearScale yScale,
    ColorScale colorScale,
    SizeScale sizeScale,
  ) {
    if (geometry is PointGeometry) {
      _drawPoints(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        sizeScale,
      );
    } else if (geometry is LineGeometry) {
      _drawLines(canvas, plotArea, geometry, xScale, yScale, colorScale);
    }
  }

  void _drawPoints(
    Canvas canvas,
    Rect plotArea,
    PointGeometry geometry,
    LinearScale xScale,
    LinearScale yScale,
    ColorScale colorScale,
    SizeScale sizeScale,
  ) {
    for (final point in data) {
      final x = _getNumericValue(point[xColumn]);
      final y = _getNumericValue(point[yColumn]);

      if (x == null || y == null) continue;

      final screenX = plotArea.left + xScale.scale(x);
      final screenY = plotArea.top + yScale.scale(y);

      // Determine point properties
      final pointColor = geometry.color ??
          (colorColumn != null
              ? colorScale.scale(point[colorColumn])
              : theme.primaryColor);
      final pointSize = geometry.size ??
          (sizeColumn != null
              ? sizeScale.scale(_getNumericValue(point[sizeColumn]) ?? 0)
              : theme.pointSizeDefault);

      final paint = Paint()
        ..color = pointColor.withValues(alpha: geometry.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(screenX, screenY), pointSize, paint);
    }
  }

  void _drawLines(
    Canvas canvas,
    Rect plotArea,
    LineGeometry geometry,
    LinearScale xScale,
    LinearScale yScale,
    ColorScale colorScale,
  ) {
    if (colorColumn != null) {
      // Group by color and draw separate lines
      final groupedData = <dynamic, List<Map<String, dynamic>>>{};
      for (final point in data) {
        final colorValue = point[colorColumn];
        groupedData.putIfAbsent(colorValue, () => []).add(point);
      }

      for (final entry in groupedData.entries) {
        final colorValue = entry.key;
        final groupData = entry.value;
        final lineColor = geometry.color ?? colorScale.scale(colorValue);
        _drawSingleLine(
          canvas,
          plotArea,
          groupData,
          xScale,
          yScale,
          lineColor,
          geometry,
        );
      }
    } else {
      // Draw single line for all data
      final lineColor = geometry.color ?? theme.primaryColor;
      _drawSingleLine(
        canvas,
        plotArea,
        data,
        xScale,
        yScale,
        lineColor,
        geometry,
      );
    }
  }

  void _drawSingleLine(
    Canvas canvas,
    Rect plotArea,
    List<Map<String, dynamic>> lineData,
    LinearScale xScale,
    LinearScale yScale,
    Color color,
    LineGeometry geometry,
  ) {
    // Sort data by x value for proper line connection
    final sortedData = List<Map<String, dynamic>>.from(lineData);
    sortedData.sort((a, b) {
      final aX = _getNumericValue(a[xColumn]) ?? 0;
      final bX = _getNumericValue(b[xColumn]) ?? 0;
      return aX.compareTo(bX);
    });

    final points = <Offset>[];
    for (final point in sortedData) {
      final x = _getNumericValue(point[xColumn]);
      final y = _getNumericValue(point[yColumn]);

      if (x == null || y == null) continue;

      final screenX = plotArea.left + xScale.scale(x);
      final screenY = plotArea.top + yScale.scale(y);
      points.add(Offset(screenX, screenY));
    }

    if (points.length < 2) return;

    final paint = Paint()
      ..color = color.withValues(alpha: geometry.alpha)
      ..strokeWidth = geometry.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawAxes(
    Canvas canvas,
    Size size,
    Rect plotArea,
    LinearScale xScale,
    LinearScale yScale,
  ) {
    final paint = Paint()
      ..color = theme.axisColor
      ..strokeWidth = theme.axisWidth;

    // X axis
    canvas.drawLine(
      Offset(plotArea.left, plotArea.bottom),
      Offset(plotArea.right, plotArea.bottom),
      paint,
    );

    // Y axis
    canvas.drawLine(
      Offset(plotArea.left, plotArea.top),
      Offset(plotArea.left, plotArea.bottom),
      paint,
    );

    // X axis labels
    final xTicks = xScale.getTicks();
    for (final tick in xTicks) {
      final x = plotArea.left + xScale.scale(tick);
      _drawText(
        canvas,
        _formatNumber(tick),
        Offset(x, plotArea.bottom + 20),
        theme.axisTextStyle,
      );
    }

    // Y axis labels
    final yTicks = yScale.getTicks();
    for (final tick in yTicks) {
      final y = plotArea.top + yScale.scale(tick);
      _drawText(
        canvas,
        _formatNumber(tick),
        Offset(plotArea.left - 40, y - 6),
        theme.axisTextStyle,
      );
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
