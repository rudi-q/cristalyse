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
  final String? y2Column; // Secondary Y column
  final String? colorColumn;
  final String? sizeColumn;
  final List<Geometry> geometries;
  final Scale? xScale;
  final Scale? yScale;
  final Scale? y2Scale; // Secondary Y scale
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
    this.y2Column,
    this.colorColumn,
    this.sizeColumn,
    required this.geometries,
    this.xScale,
    this.yScale,
    this.y2Scale,
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

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedCristalyseChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data != oldWidget.data ||
        widget.geometries != oldWidget.geometries) {
      _animationController.reset();
      _animationController.forward();
    }

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
        final animationValue = _animation.value;
        if (!animationValue.isFinite || animationValue.isNaN) {
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
                y2Column: widget.y2Column,
                colorColumn: widget.colorColumn,
                sizeColumn: widget.sizeColumn,
                geometries: widget.geometries,
                xScale: widget.xScale,
                yScale: widget.yScale,
                y2Scale: widget.y2Scale,
                colorScale: widget.colorScale,
                sizeScale: widget.sizeScale,
                theme: widget.theme,
                animationProgress: 1.0,
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
              y2Column: widget.y2Column,
              colorColumn: widget.colorColumn,
              sizeColumn: widget.sizeColumn,
              geometries: widget.geometries,
              xScale: widget.xScale,
              yScale: widget.yScale,
              y2Scale: widget.y2Scale,
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
  final String? y2Column;
  final String? colorColumn;
  final String? sizeColumn;
  final List<Geometry> geometries;
  final Scale? xScale;
  final Scale? yScale;
  final Scale? y2Scale;
  final ColorScale? colorScale;
  final SizeScale? sizeScale;
  final ChartTheme theme;
  final double animationProgress;
  final bool coordFlipped;

  _AnimatedChartPainter({
    required this.data,
    this.xColumn,
    this.yColumn,
    this.y2Column,
    this.colorColumn,
    this.sizeColumn,
    required this.geometries,
    this.xScale,
    this.yScale,
    this.y2Scale,
    this.colorScale,
    this.sizeScale,
    required this.theme,
    required this.animationProgress,
    this.coordFlipped = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || geometries.isEmpty) {
      final debugPaint =
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), debugPaint);
      return;
    }

    if (!animationProgress.isFinite || animationProgress.isNaN) {
      return;
    }

    // Adjust padding for dual Y-axis
    final hasSecondaryY = _hasSecondaryYAxis();
    final rightPadding = hasSecondaryY ? 80.0 : theme.padding.right;

    final plotArea = Rect.fromLTWH(
      theme.padding.left,
      theme.padding.top,
      size.width - theme.padding.left - rightPadding,
      size.height - theme.padding.vertical,
    );

    if (plotArea.width <= 0 || plotArea.height <= 0) {
      return;
    }

    final xScale = _setupXScale(
      plotArea.width,
      geometries.any((g) => g is BarGeometry),
    );
    final yScale = _setupYScale(
      plotArea.height,
      geometries.any((g) => g is BarGeometry),
      YAxis.primary,
    );
    final y2Scale =
        hasSecondaryY
            ? _setupYScale(
              plotArea.height,
              geometries.any((g) => g is BarGeometry),
              YAxis.secondary,
            )
            : null;
    final colorScale = _setupColorScale();
    final sizeScale = _setupSizeScale();

    _drawBackground(canvas, plotArea);
    _drawGrid(canvas, plotArea, xScale, yScale, y2Scale);

    for (final geometry in geometries) {
      final useY2 = geometry.yAxis == YAxis.secondary;
      final activeYScale = useY2 ? y2Scale ?? yScale : yScale;

      _drawGeometry(
        canvas,
        plotArea,
        geometry,
        xScale,
        activeYScale,
        colorScale,
        sizeScale,
        useY2,
      );
    }

    _drawAxes(canvas, size, plotArea, xScale, yScale, y2Scale);
  }

  bool _hasSecondaryYAxis() {
    return y2Column != null &&
        geometries.any((g) => g.yAxis == YAxis.secondary);
  }

  Scale _setupXScale(double width, bool hasBarGeometry) {
    if (coordFlipped) {
      final preconfigured = yScale;
      final scale =
          (preconfigured is LinearScale ? preconfigured : LinearScale());
      final dataCol = yColumn;

      if (dataCol == null || data.isEmpty) {
        scale.domain =
            scale.min != null && scale.max != null
                ? [scale.min!, scale.max!]
                : [0, 1];
        scale.range = [0, width];
        return scale;
      }

      final values =
          data
              .map((d) => _getNumericValue(d[dataCol]))
              .where((v) => v != null && v.isFinite)
              .cast<double>()
              .toList();

      if (values.isNotEmpty) {
        double domainMin = scale.min ?? values.reduce(math.min);
        double domainMax = scale.max ?? values.reduce(math.max);

        if (domainMin == domainMax) {
          if (domainMin == 0) {
            domainMin = -0.5;
            domainMax = 0.5;
          } else if (domainMin > 0) {
            domainMax = domainMin + domainMin.abs() * 0.2;
            domainMin = 0;
          } else {
            domainMin = domainMin - domainMin.abs() * 0.2;
            domainMax = 0;
          }
        } else {
          if (domainMin > 0) domainMin = 0;
          if (domainMax < 0) domainMax = 0;
        }
        scale.domain = [domainMin, domainMax];
        if (scale.domain[0] == scale.domain[1]) {
          scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
        }
      } else {
        scale.domain =
            scale.min != null && scale.max != null
                ? [scale.min!, scale.max!]
                : [0, 1];
      }
      scale.range = [0, width];
      return scale;
    } else {
      final preconfigured = xScale;
      final dataCol = xColumn;
      if (preconfigured is OrdinalScale ||
          (hasBarGeometry && _isColumnCategorical(dataCol))) {
        final scale =
            (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
        if (dataCol == null || data.isEmpty) {
          scale.domain = [];
          scale.range = [0, width];
          return scale;
        }
        if (scale.domain.isEmpty) {
          final distinctValues =
              data
                  .map((d) => d[dataCol])
                  .where((v) => v != null)
                  .toSet()
                  .toList();
          scale.domain = distinctValues;
        }
        scale.range = [0, width];
        return scale;
      } else {
        final scale =
            (preconfigured is LinearScale ? preconfigured : LinearScale());
        if (dataCol == null || data.isEmpty) {
          scale.domain =
              scale.min != null && scale.max != null
                  ? [scale.min!, scale.max!]
                  : [0, 1];
          scale.range = [0, width];
          return scale;
        }
        final values =
            data
                .map((d) => _getNumericValue(d[dataCol]))
                .where((v) => v != null && v.isFinite)
                .cast<double>()
                .toList();

        if (values.isNotEmpty) {
          double domainMin = scale.min ?? values.reduce(math.min);
          double domainMax = scale.max ?? values.reduce(math.max);

          if (domainMin == domainMax) {
            if (domainMin == 0) {
              domainMin = -0.5;
              domainMax = 0.5;
            } else if (domainMin > 0) {
              domainMax = domainMin + domainMin.abs() * 0.2;
              domainMin = 0;
            } else {
              domainMin = domainMin - domainMin.abs() * 0.2;
              domainMax = 0;
            }
          } else {
            if (domainMin > 0) domainMin = 0;
            if (domainMax < 0) domainMax = 0;
          }
          scale.domain = [domainMin, domainMax];
          if (scale.domain[0] == scale.domain[1]) {
            scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
          }
        } else {
          scale.domain =
              scale.min != null && scale.max != null
                  ? [scale.min!, scale.max!]
                  : [0, 1];
        }
        scale.range = [0, width];
        return scale;
      }
    }
  }

  Scale _setupYScale(double height, bool hasBarGeometry, YAxis axis) {
    if (coordFlipped) {
      final preconfigured = xScale; // Use X-scale config for flipped Y-axis
      final scale =
          (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
      final dataCol =
          xColumn; // In horizontal bars, Y shows X-column categories

      if (dataCol == null || data.isEmpty) {
        scale.domain = [];
        scale.range = [0, height]; // Top to bottom for categories
        return scale;
      }
      if (scale.domain.isEmpty) {
        final distinctValues =
            data
                .map((d) => d[dataCol])
                .where((v) => v != null)
                .toSet()
                .toList();
        scale.domain = distinctValues;
      }
      scale.range = [0, height]; // Top to bottom for horizontal bar categories
      return scale;
    } else {
      // VERTICAL BARS/CHARTS: Y-axis maps to yColumn data, respect the axis parameter
      final preconfigured = axis == YAxis.primary ? yScale : y2Scale;
      final dataCol = axis == YAxis.primary ? yColumn : y2Column;

      final scale =
          (preconfigured is LinearScale ? preconfigured : LinearScale());
      if (dataCol == null || data.isEmpty) {
        scale.domain =
            scale.min != null && scale.max != null
                ? [scale.min!, scale.max!]
                : [0, 1];
        scale.range = [height, 0];
        return scale;
      }

      // Filter data for geometries using this Y-axis
      final relevantGeometries =
          geometries.where((g) => g.yAxis == axis).toList();
      if (relevantGeometries.isEmpty) {
        scale.domain = [0, 1];
        scale.range = [height, 0];
        return scale;
      }

      final hasStackedBars = relevantGeometries.any(
        (g) => g is BarGeometry && g.style == BarStyle.stacked,
      );

      List<double> values;

      if (hasStackedBars && colorColumn != null) {
        final groups = <dynamic, double>{};
        for (final point in data) {
          final x = point[xColumn];
          final y = _getNumericValue(point[dataCol]);
          if (y == null || !y.isFinite || y <= 0) continue;

          groups[x] = (groups[x] ?? 0) + y;
        }
        values = groups.values.where((v) => v.isFinite).cast<double>().toList();
      } else {
        values =
            data
                .map((d) => _getNumericValue(d[dataCol]))
                .where((v) => v != null && v.isFinite)
                .cast<double>()
                .toList();
      }

      if (values.isNotEmpty) {
        double domainMin = scale.min ?? 0;
        double domainMax = scale.max ?? values.reduce(math.max);

        if (hasStackedBars) {
          domainMax = domainMax * 1.1;
        }

        if (domainMin == domainMax) {
          if (domainMax == 0) {
            domainMin = -0.5;
            domainMax = 0.5;
          } else if (domainMax > 0) {
            domainMax = domainMax + domainMax * 0.2;
            domainMin = 0;
          } else {
            domainMin = domainMin - domainMin.abs() * 0.2;
            domainMax = 0;
          }
        } else {
          if (domainMin > 0) domainMin = 0;
          if (domainMax < 0) domainMax = 0;
        }

        scale.domain = [domainMin, domainMax];
        if (scale.domain[0] == scale.domain[1]) {
          scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
        }
      } else {
        scale.domain =
            scale.min != null && scale.max != null
                ? [scale.min!, scale.max!]
                : [0, 1];
      }
      scale.range = [height, 0]; // Inverted for screen Y coordinates
      return scale;
    }
  }

  bool _isColumnCategorical(String? column) {
    if (column == null || data.isEmpty) return false;
    for (final row in data) {
      final value = row[column];
      if (value != null) {
        return value is String || value is bool;
      }
    }
    return false;
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
            .cast<double>()
            .toList();
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
    Scale? y2Scale,
  ) {
    final paint =
        Paint()
          ..color = theme.gridColor.withAlpha(
            (math.max(0.0, math.min(1.0, animationProgress * 0.5)) * 255)
                .round(),
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

      if (!x.isFinite || x < plotArea.left - 10 || x > plotArea.right + 10) {
        continue;
      }

      canvas.drawLine(
        Offset(x, plotArea.top),
        Offset(x, plotArea.bottom),
        paint,
      );
    }

    // Horizontal grid lines (based on primary Y-axis)
    final yTicks = yScale.getTicks(5);
    for (final tick in yTicks) {
      double y;
      if (yScale is OrdinalScale) {
        y = plotArea.top + yScale.bandCenter(tick);
      } else {
        if (tick is! num || !tick.isFinite) continue;
        y = plotArea.top + yScale.scale(tick);
      }

      if (!y.isFinite || y < plotArea.top - 10 || y > plotArea.bottom + 10) {
        continue;
      }

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
    bool isSecondaryY,
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
        isSecondaryY,
      );
    } else if (geometry is LineGeometry) {
      _drawLinesAnimated(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        isSecondaryY,
      );
    } else if (geometry is BarGeometry) {
      _drawBarsAnimated(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        isSecondaryY,
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
    bool isSecondaryY,
  ) {
    final yCol = isSecondaryY ? y2Column : yColumn;

    if (colorColumn != null && geometry.style == BarStyle.grouped) {
      _drawGroupedBars(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        yCol,
      );
    } else if (colorColumn != null && geometry.style == BarStyle.stacked) {
      _drawStackedBars(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        yCol,
      );
    } else {
      _drawSimpleBars(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        yCol,
      );
    }
  }

  void _drawSimpleBars(
    Canvas canvas,
    Rect plotArea,
    BarGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    String? yCol,
  ) {
    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final x = point[xColumn];
      final y = _getNumericValue(point[yCol]);

      if (y == null || !y.isFinite) continue;

      final barDelay = data.isNotEmpty ? i / data.length * 0.2 : 0.0;
      final barProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - barDelay) / math.max(0.001, 1.0 - barDelay),
        ),
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
    String? yCol,
  ) {
    final groups = <dynamic, Map<dynamic, double>>{};
    for (final point in data) {
      final x = point[xColumn];
      final y = _getNumericValue(point[yCol]);
      final color = point[colorColumn];

      if (y == null || !y.isFinite) continue;

      groups.putIfAbsent(x, () => {})[color] = y;
    }

    final allColors = data.map((d) => d[colorColumn]).toSet().toList();
    final colorCount = allColors.length;

    int groupIndex = 0;
    for (final groupEntry in groups.entries) {
      final x = groupEntry.key;
      final colorValues = groupEntry.value;

      final groupDelay =
          groups.isNotEmpty ? groupIndex / groups.length * 0.2 : 0.0;
      final groupProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - groupDelay) / math.max(0.001, 1.0 - groupDelay),
        ),
      );

      if (groupProgress <= 0) {
        groupIndex++;
        continue;
      }

      double basePosition;
      double totalGroupWidth;

      if (xScale is OrdinalScale) {
        basePosition = plotArea.left + xScale.scale(x);
        totalGroupWidth = xScale.bandWidth * geometry.width;
      } else {
        basePosition = plotArea.left + xScale.scale(x) - 20;
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
          null,
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
    String? yCol,
  ) {
    final groups = <dynamic, List<Map<String, dynamic>>>{};
    for (final point in data) {
      final x = point[xColumn];
      groups.putIfAbsent(x, () => []).add(point);
    }

    int groupIndex = 0;
    for (final groupEntry in groups.entries) {
      final x = groupEntry.key;
      final groupData = groupEntry.value;

      final groupDelay =
          groups.isNotEmpty ? groupIndex / groups.length * 0.3 : 0.0;
      final groupProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - groupDelay) / math.max(0.001, 1.0 - groupDelay),
        ),
      );

      if (groupProgress <= 0) {
        groupIndex++;
        continue;
      }

      groupData.sort((a, b) {
        final aColor = a[colorColumn]?.toString() ?? '';
        final bColor = b[colorColumn]?.toString() ?? '';
        return aColor.compareTo(bColor);
      });

      double cumulativeValue = 0;
      for (int i = 0; i < groupData.length; i++) {
        final point = groupData[i];
        final y = _getNumericValue(point[yCol]);
        if (y == null || !y.isFinite || y <= 0) continue;

        final segmentDelay = i / groupData.length * 0.2;
        final segmentProgress = math.max(
          0.0,
          math.min(
            1.0,
            (groupProgress - segmentDelay) /
                math.max(0.001, 1.0 - segmentDelay),
          ),
        );

        if (segmentProgress <= 0) continue;

        _drawSingleBar(
          canvas,
          plotArea,
          geometry,
          x,
          y * segmentProgress,
          xScale,
          yScale,
          colorScale,
          1.0,
          point,
          yStackOffset: cumulativeValue,
        );

        cumulativeValue += y * segmentProgress;
      }

      groupIndex++;
    }
  }

  void _drawSingleBar(
    Canvas canvas,
    Rect plotArea,
    BarGeometry geometry,
    dynamic xValForPosition,
    double yValForBar,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    double animationProgress,
    Map<String, dynamic> dataPoint, {
    double? customX,
    double? customWidth,
    double yStackOffset = 0,
  }) {
    final color =
        colorColumn != null
            ? colorScale.scale(dataPoint[colorColumn])
            : (theme.colorPalette.isNotEmpty
                ? theme.colorPalette.first
                : theme.primaryColor);

    final paint =
        Paint()
          ..color = color.withAlpha((geometry.alpha * 255).round())
          ..style = PaintingStyle.fill;

    Rect barRect;

    if (coordFlipped) {
      if (yScale is! OrdinalScale || xScale is! LinearScale) {
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
      if (xScale is! OrdinalScale || yScale is! LinearScale) {
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
        yStart - (barHeight * animationProgress),
        barWidth.isFinite ? barWidth : 0,
        barHeight.isFinite ? barHeight * animationProgress : 0,
      );
    }

    if (!barRect.isFinite || barRect.isEmpty) {
      return;
    }

    if (geometry.borderRadius != null &&
        geometry.borderRadius != BorderRadius.zero) {
      canvas.drawRRect(geometry.borderRadius!.toRRect(barRect), paint);
    } else {
      canvas.drawRect(barRect, paint);
    }

    if (geometry.borderWidth > 0) {
      final borderPaint =
          Paint()
            ..color = theme.borderColor.withAlpha(
              (geometry.alpha * 255).round(),
            )
            ..strokeWidth = geometry.borderWidth
            ..style = PaintingStyle.stroke;

      if (geometry.borderRadius != null &&
          geometry.borderRadius != BorderRadius.zero) {
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
    bool isSecondaryY,
  ) {
    final yCol = isSecondaryY ? y2Column : yColumn;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final x = _getNumericValue(point[xColumn]);
      final y = _getNumericValue(point[yCol]);

      if (x == null || y == null) continue;

      final pointDelay = data.isNotEmpty ? i / data.length * 0.2 : 0.0;
      final pointProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - pointDelay) / math.max(0.001, 1.0 - pointDelay),
        ),
      );

      if (pointProgress <= 0) continue;

      final color =
          colorColumn != null
              ? colorScale.scale(point[colorColumn])
              : (theme.colorPalette.isNotEmpty
                  ? theme.colorPalette.first
                  : theme.primaryColor);

      final size =
          sizeColumn != null
              ? sizeScale.scale(point[sizeColumn])
              : theme.pointSizeDefault;

      final paint =
          Paint()
            ..color = color.withAlpha(
              (geometry.alpha * pointProgress * 255).round(),
            )
            ..style = PaintingStyle.fill;

      final pointX = plotArea.left + xScale.scale(x);
      final pointY = plotArea.top + yScale.scale(y);

      if (geometry.shape == PointShape.circle) {
        canvas.drawCircle(Offset(pointX, pointY), size * pointProgress, paint);
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
        path.lineTo(
          pointX - size * pointProgress,
          pointY + size * pointProgress,
        );
        path.lineTo(
          pointX + size * pointProgress,
          pointY + size * pointProgress,
        );
        path.close();
        canvas.drawPath(path, paint);
      }

      if (geometry.borderWidth > 0) {
        final borderPaint =
            Paint()
              ..color = theme.borderColor.withAlpha(
                (geometry.alpha * pointProgress * 255).round(),
              )
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
          path.lineTo(
            pointX - size * pointProgress,
            pointY + size * pointProgress,
          );
          path.lineTo(
            pointX + size * pointProgress,
            pointY + size * pointProgress,
          );
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
    bool isSecondaryY,
  ) {
    final yCol = isSecondaryY ? y2Column : yColumn;

    if (yCol == null) {
      return;
    }

    final color =
        geometry.color ??
        (colorColumn != null
            ? colorScale.scale(data.first[colorColumn])
            : (theme.colorPalette.isNotEmpty
                ? theme.colorPalette.first
                : theme.primaryColor));

    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final xRawValue = point[xColumn];
      final yVal = _getNumericValue(point[yCol]);

      if (xRawValue == null || yVal == null) {
        continue;
      }

      // Handle both ordinal and continuous X-scales
      double screenX;
      if (xScale is OrdinalScale) {
        // For ordinal scales, use the raw string value with bandCenter
        screenX = plotArea.left + xScale.bandCenter(xRawValue);
      } else {
        // For continuous scales, convert to number first
        final xVal = _getNumericValue(xRawValue);
        if (xVal == null) continue;
        screenX = plotArea.left + xScale.scale(xVal);
      }

      final screenY = plotArea.top + yScale.scale(yVal);

      if (!screenX.isFinite || !screenY.isFinite) {
        continue;
      }

      points.add(Offset(screenX, screenY));
    }

    if (points.length < 2) {
      return;
    }

    final lineProgress = math.max(0.0, math.min(1.0, animationProgress));
    if (lineProgress <= 0.001) {
      return;
    }

    final paint =
        Paint()
          ..color = color.withAlpha((geometry.alpha * 255).round())
          ..strokeWidth = geometry.strokeWidth
          ..style = PaintingStyle.stroke;

    final path = Path();
    final int numSegments = points.length - 1;

    final double totalProgressiveSegments = numSegments * lineProgress;
    final int fullyDrawnSegments = totalProgressiveSegments.floor();
    final double partialSegmentProgress =
        totalProgressiveSegments - fullyDrawnSegments;

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < fullyDrawnSegments; i++) {
      path.lineTo(points[i + 1].dx, points[i + 1].dy);
    }

    if (partialSegmentProgress > 0.001 && fullyDrawnSegments < numSegments) {
      final Offset lastFullPoint = points[fullyDrawnSegments];
      final Offset nextPoint = points[fullyDrawnSegments + 1];

      final double dx =
          lastFullPoint.dx +
          (nextPoint.dx - lastFullPoint.dx) * partialSegmentProgress;
      final double dy =
          lastFullPoint.dy +
          (nextPoint.dy - lastFullPoint.dy) * partialSegmentProgress;
      path.lineTo(dx, dy);
    }

    if (fullyDrawnSegments > 0 ||
        (partialSegmentProgress > 0.001 && fullyDrawnSegments < numSegments)) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawAxes(
    Canvas canvas,
    Size size,
    Rect plotArea,
    Scale xScale,
    Scale yScale,
    Scale? y2Scale,
  ) {
    final paint =
        Paint()
          ..color = theme.axisColor
          ..strokeWidth = theme.axisWidth
          ..style = PaintingStyle.stroke;

    final axisLabelStyle =
        theme.axisLabelStyle ??
        const TextStyle(color: Colors.black, fontSize: 12);

    // Draw horizontal axis (bottom)
    canvas.drawLine(
      Offset(plotArea.left, plotArea.bottom),
      Offset(plotArea.right, plotArea.bottom),
      paint,
    );

    // Draw primary Y-axis (left)
    canvas.drawLine(
      Offset(plotArea.left, plotArea.top),
      Offset(plotArea.left, plotArea.bottom),
      paint,
    );

    // Draw secondary Y-axis (right) if exists
    if (y2Scale != null) {
      canvas.drawLine(
        Offset(plotArea.right, plotArea.top),
        Offset(plotArea.right, plotArea.bottom),
        paint,
      );
    }

    // X-axis labels
    final xTicks = xScale.getTicks(5);
    for (final tick in xTicks) {
      final pos = plotArea.left + xScale.scale(tick);
      canvas.drawLine(
        Offset(pos, plotArea.bottom),
        Offset(pos, plotArea.bottom + theme.axisWidth * 2),
        paint,
      );

      final label = _formatAxisLabel(tick);
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
          plotArea.bottom + theme.axisWidth * 2 + 8,
        ),
      );
    }

    // Primary Y-axis labels (left)
    final yTicks = yScale.getTicks(5);
    for (final tick in yTicks) {
      final pos = plotArea.top + yScale.scale(tick);
      canvas.drawLine(
        Offset(plotArea.left - theme.axisWidth * 2, pos),
        Offset(plotArea.left, pos),
        paint,
      );

      final label = _formatAxisLabel(tick);
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: axisLabelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(minWidth: 0, maxWidth: plotArea.left - 16);
      textPainter.paint(
        canvas,
        Offset(
          plotArea.left - textPainter.width - theme.axisWidth * 2 - 8,
          pos - textPainter.height / 2,
        ),
      );
    }

    // Secondary Y-axis labels (right)
    if (y2Scale != null) {
      final y2Ticks = y2Scale.getTicks(5);
      for (final tick in y2Ticks) {
        final pos = plotArea.top + y2Scale.scale(tick);
        canvas.drawLine(
          Offset(plotArea.right, pos),
          Offset(plotArea.right + theme.axisWidth * 2, pos),
          paint,
        );

        final label = _formatAxisLabel(tick);
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: axisLabelStyle.copyWith(
              color:
                  theme.colorPalette.length > 1
                      ? theme.colorPalette[1]
                      : theme.axisColor,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            plotArea.right + theme.axisWidth * 2 + 8,
            pos - textPainter.height / 2,
          ),
        );
      }
    }
  }

  String _formatAxisLabel(dynamic value) {
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.round().toString();
      } else {
        return value.toStringAsFixed(1);
      }
    } else {
      return value.toString();
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.theme != theme ||
        oldDelegate.geometries != geometries ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.coordFlipped != coordFlipped ||
        oldDelegate.y2Column != y2Column;
  }
}
