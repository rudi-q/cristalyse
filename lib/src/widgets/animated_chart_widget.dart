// lib/src/widgets/animated_chart_widget.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/scale.dart';
import '../themes/chart_theme.dart';

/// Animated wrapper for the chart widget
class AnimatedCristalyseChartWidget extends StatefulWidget {
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
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedCristalyseChartWidget({
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
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedCristalyseChartWidget> createState() =>
      _AnimatedCristalyseChartWidgetState();
}

class _AnimatedCristalyseChartWidgetState
    extends State<AnimatedCristalyseChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    // Start animation immediately
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedCristalyseChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation when data changes
    if (widget.data != oldWidget.data ||
        widget.geometries != oldWidget.geometries) {
      _animationController.reset();
      _animationController.forward();
    }

    // Update animation duration if changed
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Validate animation value before using it
        final animationValue = _animation.value;
        if (!animationValue.isFinite || animationValue.isNaN) {
          // Fallback to static chart if animation is invalid
          return Container(
            decoration: BoxDecoration(
              color: widget.theme.backgroundColor,
              border: Border.all(color: widget.theme.borderColor),
            ),
            child: CustomPaint(
              painter: _AnimatedChartPainter(
                data: widget.data,
                xColumn: widget.xColumn,
                yColumn: widget.yColumn,
                colorColumn: widget.colorColumn,
                sizeColumn: widget.sizeColumn,
                geometries: widget.geometries,
                xScale: widget.xScale,
                yScale: widget.yScale,
                colorScale: widget.colorScale,
                sizeScale: widget.sizeScale,
                theme: widget.theme,
                animationProgress: 1.0, // Use completed state
              ),
              child: Container(),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: widget.theme.backgroundColor,
            border: Border.all(color: widget.theme.borderColor),
          ),
          child: CustomPaint(
            painter: _AnimatedChartPainter(
              data: widget.data,
              xColumn: widget.xColumn,
              yColumn: widget.yColumn,
              colorColumn: widget.colorColumn,
              sizeColumn: widget.sizeColumn,
              geometries: widget.geometries,
              xScale: widget.xScale,
              yScale: widget.yScale,
              colorScale: widget.colorScale,
              sizeScale: widget.sizeScale,
              theme: widget.theme,
              animationProgress: math.max(0.0, math.min(1.0, animationValue)),
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

/// Custom painter with animation support
class _AnimatedChartPainter extends CustomPainter {
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
  final double animationProgress;

  _AnimatedChartPainter({
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
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || geometries.isEmpty) return;

    // Validate animation progress early to prevent rendering issues
    if (!animationProgress.isFinite || animationProgress.isNaN) return;

    // Calculate plot area (leaving space for axes)
    final plotArea = Rect.fromLTWH(
      theme.padding.left,
      theme.padding.top,
      size.width - theme.padding.horizontal,
      size.height - theme.padding.vertical,
    );

    // Validate plot area
    if (plotArea.width <= 0 || plotArea.height <= 0) return;

    // Setup scales
    final xScale = _setupXScale(plotArea.width);
    final yScale = _setupYScale(plotArea.height);
    final colorScale = _setupColorScale();
    final sizeScale = _setupSizeScale();

    // Draw background
    _drawBackground(canvas, plotArea);

    // Draw grid (fade in)
    _drawGrid(canvas, plotArea, xScale, yScale);

    // Draw geometries with animation
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
    final values =
        data
            .map((d) => _getNumericValue(d[xColumn]))
            .where((v) => v != null && v.isFinite)
            .cast<double>();
    if (values.isNotEmpty) {
      final minVal = scale.min ?? values.reduce(math.min);
      final maxVal = scale.max ?? values.reduce(math.max);

      // Ensure valid domain
      if (minVal.isFinite && maxVal.isFinite && minVal != maxVal) {
        scale.domain = [minVal, maxVal];
      } else {
        scale.domain = [0, 1]; // Fallback domain
      }
    } else {
      scale.domain = [0, 1]; // Fallback for empty data
    }
    scale.range = [0, math.max(1.0, width)]; // Ensure positive range
    return scale;
  }

  LinearScale _setupYScale(double height) {
    final scale = (yScale as LinearScale?) ?? LinearScale();
    final values =
        data
            .map((d) => _getNumericValue(d[yColumn]))
            .where((v) => v != null && v.isFinite)
            .cast<double>();
    if (values.isNotEmpty) {
      final minVal = scale.min ?? values.reduce(math.min);
      final maxVal = scale.max ?? values.reduce(math.max);

      // Ensure valid domain
      if (minVal.isFinite && maxVal.isFinite && minVal != maxVal) {
        scale.domain = [minVal, maxVal];
      } else {
        scale.domain = [0, 1]; // Fallback domain
      }
    } else {
      scale.domain = [0, 1]; // Fallback for empty data
    }
    scale.range = [
      math.max(1.0, height),
      0,
    ]; // Inverted for screen coordinates, ensure positive
    return scale;
  }

  ColorScale _setupColorScale() {
    if (colorColumn == null) return ColorScale();

    final values = data.map((d) => d[colorColumn]).toSet().toList();
    return ColorScale(values: values, colors: theme.colorPalette);
  }

  SizeScale _setupSizeScale() {
    if (sizeColumn == null) return SizeScale();

    final values =
        data
            .map((d) => _getNumericValue(d[sizeColumn]))
            .where((v) => v != null)
            .cast<double>();
    if (values.isNotEmpty) {
      return SizeScale(
        domain: [values.reduce(math.min), values.reduce(math.max)],
        range: [theme.pointSizeMin, theme.pointSizeMax],
      );
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
    final paint =
        Paint()
          ..color = theme.gridColor.withValues(
            alpha: math.max(0.0, math.min(1.0, animationProgress * 0.5)),
          )
          ..strokeWidth = math.max(0.1, theme.gridWidth);

    // Vertical grid lines
    final xTicks = xScale.getTicks(5);
    for (final tick in xTicks) {
      if (!tick.isFinite) continue;
      final x = plotArea.left + xScale.scale(tick);
      if (!x.isFinite || x < plotArea.left - 10 || x > plotArea.right + 10)
        continue;

      canvas.drawLine(
        Offset(x, plotArea.top),
        Offset(x, plotArea.bottom),
        paint,
      );
    }

    // Horizontal grid lines
    final yTicks = yScale.getTicks(5);
    for (final tick in yTicks) {
      if (!tick.isFinite) continue;
      final y = plotArea.top + yScale.scale(tick);
      if (!y.isFinite || y < plotArea.top - 10 || y > plotArea.bottom + 10)
        continue;

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
      _drawPointsAnimated(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        sizeScale,
      );
    } else if (geometry is LineGeometry) {
      _drawLinesAnimated(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
      );
    }
  }

  void _drawPointsAnimated(
    Canvas canvas,
    Rect plotArea,
    PointGeometry geometry,
    LinearScale xScale,
    LinearScale yScale,
    ColorScale colorScale,
    SizeScale sizeScale,
  ) {
    // Animate points appearing with scale and fade
    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final x = _getNumericValue(point[xColumn]);
      final y = _getNumericValue(point[yColumn]);

      if (x == null || y == null || !x.isFinite || !y.isFinite) continue;

      final screenX = plotArea.left + xScale.scale(x);
      final screenY = plotArea.top + yScale.scale(y);

      // Validate screen coordinates
      if (!screenX.isFinite || !screenY.isFinite) continue;
      if (screenX < 0 ||
          screenX > plotArea.right ||
          screenY < 0 ||
          screenY > plotArea.bottom + 100)
        continue;

      // Staggered animation - each point appears slightly after the previous
      final pointDelay =
          data.isNotEmpty
              ? i / data.length * 0.3
              : 0.0; // 30% of animation for staggering
      final pointProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - pointDelay) / math.max(0.001, 1.0 - pointDelay),
        ),
      );

      if (pointProgress <= 0) continue;

      // Determine point properties
      final pointColor =
          geometry.color ??
          (colorColumn != null
              ? colorScale.scale(point[colorColumn])
              : theme.primaryColor);
      final baseSize =
          geometry.size ??
          (sizeColumn != null
              ? sizeScale.scale(_getNumericValue(point[sizeColumn]) ?? 0)
              : theme.pointSizeDefault);

      // Animate size (scale up from 0) with validation
      final animatedSize = math.max(0.0, baseSize * pointProgress);
      if (!animatedSize.isFinite || animatedSize > 100)
        continue; // Sanity check

      // Animate opacity with validation
      final animatedAlpha = math.max(
        0.0,
        math.min(1.0, geometry.alpha * pointProgress),
      );

      final paint =
          Paint()
            ..color = pointColor.withValues(alpha: animatedAlpha)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(screenX, screenY), animatedSize, paint);
    }
  }

  void _drawLinesAnimated(
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
        _drawSingleLineAnimated(
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
      _drawSingleLineAnimated(
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

  void _drawSingleLineAnimated(
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

    final allPoints = <Offset>[];
    for (final point in sortedData) {
      final x = _getNumericValue(point[xColumn]);
      final y = _getNumericValue(point[yColumn]);

      if (x == null || y == null || !x.isFinite || !y.isFinite) continue;

      final screenX = plotArea.left + xScale.scale(x);
      final screenY = plotArea.top + yScale.scale(y);

      // Validate screen coordinates
      if (!screenX.isFinite || !screenY.isFinite) continue;
      if (screenX < -1000 ||
          screenX > plotArea.right + 1000 ||
          screenY < -1000 ||
          screenY > plotArea.bottom + 1000) {
        continue;
      }

      allPoints.add(Offset(screenX, screenY));
    }

    if (allPoints.length < 2) return;

    // Animate line drawing from left to right
    final animatedPointCount = math.max(
      1,
      (allPoints.length * animationProgress).round(),
    );
    final points = allPoints.take(animatedPointCount).toList();

    if (points.length < 2) return;

    // Validate stroke width
    final validatedStrokeWidth = math.max(
      0.1,
      math.min(50.0, geometry.strokeWidth),
    );
    final validatedAlpha = math.max(
      0.0,
      math.min(1.0, geometry.alpha * animationProgress),
    );

    final paint =
        Paint()
          ..color = color.withValues(alpha: validatedAlpha)
          ..strokeWidth = validatedStrokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Add partial segment for smooth animation
    if (animatedPointCount < allPoints.length && points.length >= 2) {
      final progress =
          (allPoints.length * animationProgress) - animatedPointCount;
      final lastPoint = points.last;
      final nextPoint = allPoints[animatedPointCount];
      final partialX = lastPoint.dx + (nextPoint.dx - lastPoint.dx) * progress;
      final partialY = lastPoint.dy + (nextPoint.dy - lastPoint.dy) * progress;

      // Validate partial coordinates
      if (partialX.isFinite && partialY.isFinite) {
        path.lineTo(partialX, partialY);
      }
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
    // Validate animation progress to prevent invalid opacity values
    final validatedProgress = math.max(0.0, math.min(1.0, animationProgress));

    // Safely handle potential null colors
    final axisColor = theme.axisColor;

    final paint =
        Paint()
          ..color = axisColor.withValues(alpha: validatedProgress)
          ..strokeWidth = math.max(0.1, theme.axisWidth);

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

    // Animate labels appearing - but only if we have valid progress
    if (validatedProgress > 0.5) {
      final labelOpacity = math.max(
        0.0,
        math.min(1.0, (validatedProgress - 0.5) * 2.0),
      );

      // X axis labels
      final xTicks = xScale.getTicks(5);
      for (final tick in xTicks) {
        if (!tick.isFinite) continue;
        final x = plotArea.left + xScale.scale(tick);
        if (!x.isFinite || x < plotArea.left - 100 || x > plotArea.right + 100)
          continue;

        // Safely get the axis text color and apply opacity
        final baseTextColor = theme.axisTextStyle.color ?? Colors.black87;
        final labelStyle = theme.axisTextStyle.copyWith(
          color: baseTextColor.withValues(alpha: labelOpacity),
        );

        _drawText(
          canvas,
          _formatNumber(tick),
          Offset(x, plotArea.bottom + 20),
          labelStyle,
        );
      }

      // Y axis labels
      final yTicks = yScale.getTicks(5);
      for (final tick in yTicks) {
        if (!tick.isFinite) continue;
        final y = plotArea.top + yScale.scale(tick);
        if (!y.isFinite || y < plotArea.top - 100 || y > plotArea.bottom + 100)
          continue;

        // Safely get the axis text color and apply opacity
        final baseTextColor = theme.axisTextStyle.color ?? Colors.black87;
        final labelStyle = theme.axisTextStyle.copyWith(
          color: baseTextColor.withValues(alpha: labelOpacity),
        );

        _drawText(
          canvas,
          _formatNumber(tick),
          Offset(plotArea.left - 40, y - 6),
          labelStyle,
        );
      }
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _AnimatedChartPainter ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.data != data;
  }
}
