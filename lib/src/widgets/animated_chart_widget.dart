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
  final bool coordFlipped;

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
    this.coordFlipped = false,
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
                coordFlipped: widget.coordFlipped,
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
              coordFlipped: widget.coordFlipped,
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
  final bool coordFlipped;

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
    this.coordFlipped = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || geometries.isEmpty) {
      final debugPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), debugPaint);
      return;
    }

    if (!animationProgress.isFinite || animationProgress.isNaN) {
      return;
    }

    final plotArea = Rect.fromLTWH(
      theme.padding.left,
      theme.padding.top,
      size.width - theme.padding.horizontal,
      size.height - theme.padding.vertical,
    );

    if (plotArea.width <= 0 || plotArea.height <= 0) {
      final debugPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), debugPaint);
      return;
    }

    final xScale = _setupXScale(plotArea.width, geometries.any((g) => g is BarGeometry));
    final yScale = _setupYScale(plotArea.height, geometries.any((g) => g is BarGeometry));
    final colorScale = _setupColorScale();
    final sizeScale = _setupSizeScale();

    _drawBackground(canvas, plotArea);
    _drawGrid(canvas, plotArea, xScale, yScale);

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

    _drawAxes(canvas, size, plotArea, xScale, yScale);
  }

  @override
  bool shouldRepaint(covariant _AnimatedChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.theme != theme ||
        oldDelegate.geometries != geometries ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.coordFlipped != coordFlipped;
  }

  Scale _setupXScale(double width, bool hasBarGeometry) {
    if (coordFlipped) { // Horizontal bar: X-axis is linear, maps to yColumn (value axis)
      final preconfigured = yScale; // Horizontal X-axis uses Y's preconfigured scale if applicable
      final scale = (preconfigured is LinearScale ? preconfigured : LinearScale());
      final dataCol = yColumn;

      if (dataCol == null || data.isEmpty) {
        scale.domain = scale.min != null && scale.max != null ? [scale.min!, scale.max!] : [0, 1];
        scale.range = [0, width];
        return scale;
      }

      final values = data
          .map((d) => _getNumericValue(d[dataCol]))
          .where((v) => v != null && v.isFinite)
          .cast<double>();

      if (values.isNotEmpty) {
        double domainMin = scale.min ?? values.reduce(math.min);
        double domainMax = scale.max ?? values.reduce(math.max);

        // Ensure 0 is included for bar charts, or handle single value cases
        if (domainMin == domainMax) {
          if (domainMin == 0) { domainMin = -0.5; domainMax = 0.5; } // Single value is 0
          else if (domainMin > 0) { domainMax = domainMin + domainMin.abs() * 0.2; domainMin = 0; } // Single positive value
          else { domainMin = domainMin - domainMin.abs() * 0.2; domainMax = 0; } // Single negative value
        } else {
          if (domainMin > 0) domainMin = 0; // If all values positive, extend to 0
          if (domainMax < 0) domainMax = 0; // If all values negative, extend to 0
        }
        scale.domain = [domainMin, domainMax];
        if (scale.domain[0] == scale.domain[1]) { // Still equal after adjustments (e.g. min=0, max=0)
            scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
        }
      } else {
        scale.domain = scale.min != null && scale.max != null ? [scale.min!, scale.max!] : [0, 1]; // Default if no valid values
      }
      scale.range = [0, width];
      return scale;
    } else { // Vertical bar or other: X-axis maps to xColumn
      final preconfigured = xScale;
      final dataCol = xColumn;
      if (preconfigured is OrdinalScale || (hasBarGeometry && _isColumnCategorical(dataCol))) {
        final scale = (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
        if (dataCol == null || data.isEmpty) {
          scale.domain = [];
          scale.range = [0, width];
          return scale;
        }
        if (scale.domain.isEmpty) { // Only set if not pre-configured
          final distinctValues = data.map((d) => d[dataCol]).where((v) => v != null).toSet().toList();
          scale.domain = distinctValues;
        }
        scale.range = [0, width];
        return scale;
      } else {
        final scale = (preconfigured is LinearScale ? preconfigured : LinearScale());
        if (dataCol == null || data.isEmpty) {
          scale.domain = scale.min != null && scale.max != null ? [scale.min!, scale.max!] : [0, 1];
          scale.range = [0, width];
          return scale;
        }
        final values = data
            .map((d) => _getNumericValue(d[dataCol]))
            .where((v) => v != null && v.isFinite)
            .cast<double>();

        if (values.isNotEmpty) {
          double domainMin = scale.min ?? values.reduce(math.min);
          double domainMax = scale.max ?? values.reduce(math.max);

          // Ensure 0 is included for bar charts, or handle single value cases
          if (domainMin == domainMax) {
            if (domainMin == 0) { domainMin = -0.5; domainMax = 0.5; } // Single value is 0
            else if (domainMin > 0) { domainMax = domainMin + domainMin.abs() * 0.2; domainMin = 0; } // Single positive value
            else { domainMin = domainMin - domainMin.abs() * 0.2; domainMax = 0; } // Single negative value
          } else {
            if (domainMin > 0) domainMin = 0; // If all values positive, extend to 0
            if (domainMax < 0) domainMax = 0; // If all values negative, extend to 0
          }
          scale.domain = [domainMin, domainMax];
           if (scale.domain[0] == scale.domain[1]) { // Still equal after adjustments
            scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
          }
        } else {
          scale.domain = scale.min != null && scale.max != null ? [scale.min!, scale.max!] : [0, 1];
        }
        scale.range = [0, width];
        return scale;
      }
    }
  }

  Scale _setupYScale(double height, bool hasBarGeometry) {
    if (coordFlipped) { // Horizontal bar: Y-axis is ordinal, maps to xColumn (category axis)
      final preconfigured = xScale; // Horizontal Y-axis uses X's preconfigured scale
      final scale = (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
      final dataCol = xColumn;

      if (dataCol == null || data.isEmpty) {
        scale.domain = [];
        scale.range = [0, height]; // Or [height, 0] depending on desired category order
        return scale;
      }
      if (scale.domain.isEmpty) { // Only set if not pre-configured
        final distinctValues = data.map((d) => d[dataCol]).where((v) => v != null).toSet().toList();
        scale.domain = distinctValues;
      }
      scale.range = [0, height]; // For ordinal Y, typically top to bottom for categories
      return scale;
    } else { // Vertical bar or other: Y-axis maps to yColumn
      final preconfigured = yScale;
      final dataCol = yColumn;
      // For vertical bars, Y is typically linear (value axis)
      // Allow ordinal Y if explicitly configured or if yColumn is categorical (less common for bars)
      if (preconfigured is OrdinalScale || (hasBarGeometry && _isColumnCategorical(dataCol) && preconfigured is! LinearScale )) {
        final scale = (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
        if (dataCol == null || data.isEmpty) {
          scale.domain = [];
          scale.range = [height, 0]; 
          return scale;
        }
        if (scale.domain.isEmpty) { // Only set if not pre-configured
          final distinctValues = data.map((d) => d[dataCol]).where((v) => v != null).toSet().toList();
          scale.domain = distinctValues;
        }
        scale.range = [height, 0]; // Standard for cartesian Y ordinal: bottom to top
        return scale;
      } else { // Linear Y-axis (value axis for vertical bars)
        final scale = (preconfigured is LinearScale ? preconfigured : LinearScale());
        if (dataCol == null || data.isEmpty) {
          scale.domain = scale.min != null && scale.max != null ? [scale.min!, scale.max!] : [0, 1];
          scale.range = [height, 0];
          return scale;
        }
        final values = data
            .map((d) => _getNumericValue(d[dataCol]))
            .where((v) => v != null && v.isFinite)
            .cast<double>();

        if (values.isNotEmpty) {
          double domainMin = scale.min ?? values.reduce(math.min);
          double domainMax = scale.max ?? values.reduce(math.max);

          // Ensure 0 is included for bar charts, or handle single value cases
          if (domainMin == domainMax) {
            if (domainMin == 0) { domainMin = -0.5; domainMax = 0.5; }
            else if (domainMin > 0) { domainMax = domainMin + domainMin.abs() * 0.2; domainMin = 0; }
            else { domainMin = domainMin - domainMin.abs() * 0.2; domainMax = 0; }
          } else {
            if (domainMin > 0) domainMin = 0;
            if (domainMax < 0) domainMax = 0;
          }
          scale.domain = [domainMin, domainMax];
           if (scale.domain[0] == scale.domain[1]) { // Still equal after adjustments
            scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
          }
        } else {
          scale.domain = scale.min != null && scale.max != null ? [scale.min!, scale.max!] : [0, 1];
        }
        scale.range = [height, 0]; // Inverted for screen Y
        return scale;
      }
    }
  }

  // Helper method to determine if a column's data is categorical
  bool _isColumnCategorical(String? column) {
    if (column == null || data.isEmpty) return false;
    // Check the type of the first non-null value in the column
    for (final row in data) {
      final value = row[column];
      if (value != null) {
        return value is String || value is bool; // Add other types if considered categorical
      }
    }
    return false; // Default to non-categorical if all values are null or column is empty
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
      Scale xScale,
      Scale yScale,
      ) {
    final paint = Paint()
      ..color = theme.gridColor.withAlpha(
        (math.max(0.0, math.min(1.0, animationProgress * 0.5)) * 255).round(),
      )
      ..strokeWidth = math.max(0.1, theme.gridWidth);

    // Vertical grid lines
    final xTicks = xScale.getTicks(5);
    for (final tick in xTicks) {
      double x;
      if (xScale is OrdinalScale) {
        x = plotArea.left + xScale.bandCenter(tick);
      } else {
        if (tick is! num || !tick.isFinite) continue;
        x = plotArea.left + xScale.scale(tick);
      }

      if (!x.isFinite || x < plotArea.left - 10 || x > plotArea.right + 10) continue;

      canvas.drawLine(
        Offset(x, plotArea.top),
        Offset(x, plotArea.bottom),
        paint,
      );
    }

    // Horizontal grid lines
    final yTicks = yScale.getTicks(5);
    for (final tick in yTicks) {
      double y;
      if (yScale is OrdinalScale) {
        y = plotArea.top + yScale.bandCenter(tick);
      } else {
        if (tick is! num || !tick.isFinite) continue;
        y = plotArea.top + yScale.scale(tick);
      }

      if (!y.isFinite || y < plotArea.top - 10 || y > plotArea.bottom + 10) continue;

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
      Scale xScale,
      Scale yScale,
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
    } else if (geometry is BarGeometry) {
      _drawBarsAnimated(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
      );
    }
  }

  void _drawBarsAnimated(
      Canvas canvas,
      Rect plotArea,
      BarGeometry geometry,
      Scale xScale,
      Scale yScale,
      ColorScale colorScale,
      ) {
    if (colorColumn != null && geometry.style == BarStyle.grouped) {
      _drawGroupedBars(canvas, plotArea, geometry, xScale, yScale, colorScale);
    } else if (colorColumn != null && geometry.style == BarStyle.stacked) {
      _drawStackedBars(canvas, plotArea, geometry, xScale, yScale, colorScale);
    } else {
      _drawSimpleBars(canvas, plotArea, geometry, xScale, yScale, colorScale);
    }
  }

  void _drawSimpleBars(
      Canvas canvas,
      Rect plotArea,
      BarGeometry geometry,
      Scale xScale,
      Scale yScale,
      ColorScale colorScale,
      ) {
    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final x = point[xColumn];
      final y = _getNumericValue(point[yColumn]);

      if (y == null || !y.isFinite) continue;

      // Staggered animation for bars
      final barDelay = data.isNotEmpty ? i / data.length * 0.2 : 0.0;
      final barProgress = math.max(
        0.0,
        math.min(1.0, (animationProgress - barDelay) / math.max(0.001, 1.0 - barDelay)),
      );

      if (barProgress <= 0) continue;

      _drawSingleBar(
        canvas,
        plotArea,
        geometry,
        x,
        y,
        xScale,
        yScale,
        colorScale,
        barProgress,
        point,
      );
    }
  }

  void _drawGroupedBars(
      Canvas canvas,
      Rect plotArea,
      BarGeometry geometry,
      Scale xScale,
      Scale yScale,
      ColorScale colorScale,
      ) {
    // Group data by x value and color
    final groups = <dynamic, Map<dynamic, double>>{};
    for (final point in data) {
      final x = point[xColumn];
      final y = _getNumericValue(point[yColumn]);
      final color = point[colorColumn];

      if (y == null || !y.isFinite) continue;

      groups.putIfAbsent(x, () => {})[color] = y;
    }

    // Get all unique colors for consistent grouping
    final allColors = data.map((d) => d[colorColumn]).toSet().toList();
    final colorCount = allColors.length;

    int groupIndex = 0;
    for (final groupEntry in groups.entries) {
      final x = groupEntry.key;
      final colorValues = groupEntry.value;

      // Staggered animation for grouped bars
      final groupDelay = groups.isNotEmpty ? groupIndex / groups.length * 0.2 : 0.0;
      final groupProgress = math.max(
        0.0,
        math.min(1.0, (animationProgress - groupDelay) / math.max(0.001, 1.0 - groupDelay)),
      );

      if (groupProgress <= 0) {
        groupIndex++;
        continue;
      }

      // Calculate base position and width for this group
      double basePosition;
      double totalGroupWidth;

      if (xScale is OrdinalScale) {
        basePosition = plotArea.left + xScale.scale(x);
        totalGroupWidth = xScale.bandWidth * geometry.width;
      } else {
        basePosition = plotArea.left + xScale.scale(x) - 20; // Default width for continuous
        totalGroupWidth = 40 * geometry.width;
      }

      final barWidth = totalGroupWidth / colorCount;

      int colorIndex = 0;
      for (final color in allColors) {
        final value = colorValues[color];
        if (value == null) {
          colorIndex++;
          continue;
        }

        final barX = basePosition + colorIndex * barWidth;

        _drawSingleBar(
          canvas,
          plotArea,
          geometry,
          null, // Use calculated position
          value,
          xScale,
          yScale,
          colorScale,
          groupProgress,
          {colorColumn!: color},
          customX: barX,
          customWidth: barWidth,
        );

        colorIndex++;
      }

      groupIndex++;
    }
  }

  void _drawStackedBars(
      Canvas canvas,
      Rect plotArea,
      BarGeometry geometry,
      Scale xScale,
      Scale yScale,
      ColorScale colorScale,
      ) {
    // Group data by x value for stacking
    final groups = <dynamic, List<Map<String, dynamic>>>{};
    for (final point in data) {
      final x = point[xColumn];
      groups.putIfAbsent(x, () => []).add(point);
    }

    int groupIndex = 0;
    for (final groupEntry in groups.entries) {
      final x = groupEntry.key;
      final groupData = groupEntry.value;

      // Staggered animation for stacked bars
      final groupDelay = groups.isNotEmpty ? groupIndex / groups.length * 0.2 : 0.0;
      final groupProgress = math.max(
        0.0,
        math.min(1.0, (animationProgress - groupDelay) / math.max(0.001, 1.0 - groupDelay)),
      );

      if (groupProgress <= 0) {
        groupIndex++;
        continue;
      }

      // Calculate cumulative values for stacking
      double cumulativeValue = 0;
      for (final point in groupData) {
        final y = _getNumericValue(point[yColumn]);
        if (y == null || !y.isFinite) continue;

        _drawSingleBar(
          canvas,
          plotArea,
          geometry,
          x,
          y,
          xScale,
          yScale,
          colorScale,
          groupProgress,
          point,
          yStackOffset: cumulativeValue,
        );

        cumulativeValue += y;
      }

      groupIndex++;
    }
  }

  void _drawSingleBar(
    Canvas canvas,
    Rect plotArea,
    BarGeometry geometry,
    dynamic xValForPosition, // For ordinal scales
    double yValForBar, // The value of the bar
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    double animationProgress,
    Map<String, dynamic> dataPoint, {
    double? customX, // For grouped bars
    double? customWidth, // For grouped bars
    double yStackOffset = 0, // For stacked bars
  }) {
    final color = colorColumn != null
        ? colorScale.scale(dataPoint[colorColumn])
        : theme.primaryColor;

    final paint = Paint()
      ..color = color.withAlpha((geometry.alpha * 255).round())
      ..style = PaintingStyle.fill;

    Rect barRect;

    if (coordFlipped) {
      // HORIZONTAL BARS
      if (yScale is! OrdinalScale || xScale is! LinearScale) {
        // Silently fail if scales are not the expected type for this orientation
        return;
      }

      final yPos = plotArea.top + yScale.scale(xValForPosition);
      final barHeight = yScale.bandWidth * geometry.width;
      final yCenter = yPos + (yScale.bandWidth * (1 - geometry.width)) / 2;

      final xStart = plotArea.left + xScale.scale(yStackOffset);
      final xEnd = plotArea.left + xScale.scale(yValForBar + yStackOffset);
      final barWidth = (xEnd - xStart) * animationProgress;

      barRect = Rect.fromLTWH(
        xStart,
        yCenter,
        barWidth.isFinite ? barWidth : 0,
        barHeight.isFinite ? barHeight : 0,
      );
    } else {
      // VERTICAL BARS
      if (xScale is! OrdinalScale || yScale is! LinearScale) {
        // Silently fail if scales are not the expected type for this orientation
        return;
      }

      double xPos;
      double barWidth;

      if (customX != null && customWidth != null) {
        xPos = customX;
        barWidth = customWidth;
      } else {
        xPos = plotArea.left + xScale.scale(xValForPosition);
        barWidth = xScale.bandWidth * geometry.width;
        xPos += (xScale.bandWidth * (1 - geometry.width)) / 2;
      }

      final yStart = plotArea.top + yScale.scale(yStackOffset);
      final yEnd = plotArea.top + yScale.scale(yValForBar + yStackOffset);
      final barHeight = (yStart - yEnd);

      barRect = Rect.fromLTWH(
        xPos.isFinite ? xPos : 0,
        yStart - (barHeight * animationProgress), // Animate height from baseline
        barWidth.isFinite ? barWidth : 0,
        barHeight.isFinite ? barHeight * animationProgress : 0,
      );
    }

    if (!barRect.isFinite || barRect.isEmpty) {
      return; // Don't draw non-finite or empty rects
    }

    // Draw the bar with optional border radius
    if (geometry.borderRadius != null && geometry.borderRadius != BorderRadius.zero) {
      canvas.drawRRect(geometry.borderRadius!.toRRect(barRect), paint);
    } else {
      canvas.drawRect(barRect, paint);
    }

    // Draw border if specified
    if (geometry.borderWidth > 0) {
      final borderPaint = Paint()
        ..color = theme.borderColor.withAlpha((geometry.alpha * 255).round())
        ..strokeWidth = geometry.borderWidth
        ..style = PaintingStyle.stroke;

      if (geometry.borderRadius != null && geometry.borderRadius != BorderRadius.zero) {
        canvas.drawRRect(geometry.borderRadius!.toRRect(barRect), borderPaint);
      } else {
        canvas.drawRect(barRect, borderPaint);
      }
    }
  }

  void _drawPointsAnimated(
      Canvas canvas,
      Rect plotArea,
      PointGeometry geometry,
      Scale xScale,
      Scale yScale,
      ColorScale colorScale,
      SizeScale sizeScale,
      ) {
    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final x = _getNumericValue(point[xColumn]);
      final y = _getNumericValue(point[yColumn]);

      if (x == null || y == null) continue;

      // Staggered animation for points
      final pointDelay = data.isNotEmpty ? i / data.length * 0.2 : 0.0;
      final pointProgress = math.max(
        0.0,
        math.min(1.0, (animationProgress - pointDelay) / math.max(0.001, 1.0 - pointDelay)),
      );

      if (pointProgress <= 0) continue;

      final color = colorColumn != null
          ? colorScale.scale(point[colorColumn])
          : theme.primaryColor;

      final size = sizeColumn != null
          ? sizeScale.scale(point[sizeColumn])
          : theme.pointSizeDefault;

      final paint = Paint()
        ..color = color.withAlpha((geometry.alpha * pointProgress * 255).round())
        ..style = PaintingStyle.fill;

      final pointX = plotArea.left + xScale.scale(x);
      final pointY = plotArea.top + yScale.scale(y);

      if (geometry.shape == PointShape.circle) {
        canvas.drawCircle(
          Offset(pointX, pointY),
          size * pointProgress,
          paint,
        );
      } else if (geometry.shape == PointShape.square) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(pointX, pointY),
            width: size * pointProgress,
            height: size * pointProgress,
          ),
          paint,
        );
      } else if (geometry.shape == PointShape.triangle) {
        final path = Path();
        path.moveTo(pointX, pointY - size * pointProgress);
        path.lineTo(pointX - size * pointProgress, pointY + size * pointProgress);
        path.lineTo(pointX + size * pointProgress, pointY + size * pointProgress);
        path.close();
        canvas.drawPath(path, paint);
      }

      // Draw border if specified
      if (geometry.borderWidth > 0) {
        final borderPaint = Paint()
          ..color = theme.borderColor.withAlpha((geometry.alpha * pointProgress * 255).round())
          ..strokeWidth = geometry.borderWidth
          ..style = PaintingStyle.stroke;

        if (geometry.shape == PointShape.circle) {
          canvas.drawCircle(
            Offset(pointX, pointY),
            size * pointProgress,
            borderPaint,
          );
        } else if (geometry.shape == PointShape.square) {
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(pointX, pointY),
              width: size * pointProgress,
              height: size * pointProgress,
            ),
            borderPaint,
          );
        } else if (geometry.shape == PointShape.triangle) {
          final path = Path();
          path.moveTo(pointX, pointY - size * pointProgress);
          path.lineTo(pointX - size * pointProgress, pointY + size * pointProgress);
          path.lineTo(pointX + size * pointProgress, pointY + size * pointProgress);
          path.close();
          canvas.drawPath(path, borderPaint);
        }
      }
    }
  }

  void _drawLinesAnimated(
      Canvas canvas,
      Rect plotArea,
      LineGeometry geometry,
      Scale xScale,
      Scale yScale,
      ColorScale colorScale,
      ) {
    final color = colorColumn != null
        ? colorScale.scale(data.first[colorColumn])
        : theme.primaryColor;

    final points = data
        .map((point) {
          // Ensure x and y values are numeric before scaling
          final num? xVal = _getNumericValue(point[xColumn]);
          final num? yVal = _getNumericValue(point[yColumn]);
          if (xVal == null || yVal == null) return null; // Skip invalid points
          return Offset(
            plotArea.left + xScale.scale(xVal),
            plotArea.top + yScale.scale(yVal),
          );
        })
        .whereType<Offset>() // Filter out nulls from invalid points
        .toList();

    if (points.length < 2) return;

    // Animation progress for this specific line
    // lineDelay is currently always 0.0 if data is present, meaning line animation starts with global animationProgress.
    final lineDelay = 0.0; // Simplified, as data.isNotEmpty check is implicitly handled by points.length check
    final lineProgress = math.max(
      0.0,
      math.min(1.0, (animationProgress - lineDelay) / math.max(0.001, 1.0 - lineDelay)),
    );

    if (lineProgress <= 0.001) return; // Epsilon check for early exit if no progress

    final paint = Paint()
      ..color = color.withAlpha((geometry.alpha * 255).round())
      ..strokeWidth = geometry.strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final int numSegments = points.length - 1;

    // Calculate how many full segments to draw and the progress into the next partial segment
    final double totalProgressiveSegments = numSegments * lineProgress;
    final int fullyDrawnSegments = totalProgressiveSegments.floor();
    final double partialSegmentProgress = totalProgressiveSegments - fullyDrawnSegments;

    path.moveTo(points[0].dx, points[0].dy);

    // Draw fully drawn segments
    for (int i = 0; i < fullyDrawnSegments; i++) {
      path.lineTo(points[i + 1].dx, points[i + 1].dy);
    }

    // Draw the partial segment if applicable
    // Use a small epsilon for float comparison to avoid issues with precision
    if (partialSegmentProgress > 0.001 && fullyDrawnSegments < numSegments) {
      final Offset lastFullPoint = points[fullyDrawnSegments];
      final Offset nextPoint = points[fullyDrawnSegments + 1];
      
      final double dx = lastFullPoint.dx + (nextPoint.dx - lastFullPoint.dx) * partialSegmentProgress;
      final double dy = lastFullPoint.dy + (nextPoint.dy - lastFullPoint.dy) * partialSegmentProgress;
      path.lineTo(dx, dy);
    }
    
    // Only draw if the path actually has something (more than just a moveTo)
    if (fullyDrawnSegments > 0 || (partialSegmentProgress > 0.001 && fullyDrawnSegments < numSegments)) {
        canvas.drawPath(path, paint);
    }
  }

  void _drawAxes(
      Canvas canvas,
      Size size,
      Rect plotArea,
      Scale xScale,
      Scale yScale,
      ) {
    final paint = Paint()
      ..color = theme.axisColor
      ..strokeWidth = theme.axisWidth
      ..style = PaintingStyle.stroke;

    final axisLabelStyle = theme.axisLabelStyle ??
        const TextStyle(color: Colors.black, fontSize: 12);

    final horizontalScale = xScale;
    final verticalScale = yScale;

    // Draw horizontal axis ticks and labels (bottom)
    final hTicks = horizontalScale.getTicks(5);
    for (final tick in hTicks) {
      final pos = plotArea.left + horizontalScale.scale(tick);
      canvas.drawLine(
        Offset(pos, plotArea.bottom),
        Offset(pos, plotArea.bottom + theme.axisWidth * 2),
        paint,
      );

      final String label;
      if (tick is num) {
        if (tick.truncateToDouble() == tick) {
          label = tick.toInt().toString();
        } else {
          label = tick.toStringAsFixed(1);
        }
      } else {
        label = tick.toString();
      }

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: axisLabelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          pos - textPainter.width / 2,
          plotArea.bottom + theme.axisWidth * 2 + 8, // Increased padding
        ),
      );
    }

    // Draw vertical axis ticks and labels (left)
    final vTicks = verticalScale.getTicks(5);
    for (final tick in vTicks) {
      final pos = plotArea.top + verticalScale.scale(tick);
      canvas.drawLine(
        Offset(plotArea.left - theme.axisWidth * 2, pos),
        Offset(plotArea.left, pos),
        paint,
      );

      final String label;
      if (tick is num) {
        if (tick.truncateToDouble() == tick) {
          label = tick.toInt().toString();
        } else {
          label = tick.toStringAsFixed(1);
        }
      } else {
        label = tick.toString();
      }

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: axisLabelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(minWidth: 0, maxWidth: plotArea.left - 16); // Provide more space to prevent wrapping
      textPainter.paint(
        canvas,
        Offset(
          plotArea.left - textPainter.width - theme.axisWidth * 2 - 8, // Increased padding
          pos - textPainter.height / 2,
        ),
      );
    }
  }
}