import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/scale.dart';
import '../core/util/colors.dart';
import '../core/util/helper.dart';
import '../themes/chart_theme.dart';

/// Custom painter with animation support
class AnimatedChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String? xColumn;
  final String? yColumn;
  final String? y2Column;
  final String? colorColumn;
  final String? sizeColumn;
  final String? pieValueColumn;
  final String? pieCategoryColumn;
  final String? heatMapXColumn;
  final String? heatMapYColumn;
  final String? heatMapValueColumn;
  final String? progressValueColumn;
  final String? progressLabelColumn;
  final String? progressCategoryColumn;
  final List<Geometry> geometries;
  final Scale? xScale;
  final Scale? yScale;
  final Scale? y2Scale;
  final ColorScale? colorScale;
  final SizeScale? sizeScale;
  final ChartTheme theme;
  final double animationProgress;
  final bool coordFlipped;
  final List<double>? panXDomain;
  final List<double>? panYDomain;

  /// Creates an [AnimatedChartPainter] with comprehensive chart rendering capabilities.
  ///
  /// This constructor initializes a painter that can handle multiple chart types
  /// including line charts, bar charts, scatter plots, area charts, pie charts,
  /// and heat maps with full animation support.
  ///
  /// Parameters:
  /// - [data]: The dataset to visualize as a list of key-value maps.
  /// - [xColumn]: Column name for X-axis values. Can be null for certain chart types.
  /// - [yColumn]: Column name for primary Y-axis values.
  /// - [y2Column]: Column name for secondary Y-axis values (dual-axis charts).
  /// - [colorColumn]: Column name for color mapping in categorical visualizations.
  /// - [sizeColumn]: Column name for size mapping in scatter plots.
  /// - [pieValueColumn]: Column name for pie chart values.
  /// - [pieCategoryColumn]: Column name for pie chart categories.
  /// - [heatMapXColumn]: Column name for heat map X-axis categories.
  /// - [heatMapYColumn]: Column name for heat map Y-axis categories.
  /// - [heatMapValueColumn]: Column name for heat map cell values.
  /// - [geometries]: List of visual geometries that define how data is rendered.
  /// - [xScale]: Scale transformation for X-axis positioning.
  /// - [yScale]: Scale transformation for primary Y-axis positioning.
  /// - [y2Scale]: Scale transformation for secondary Y-axis positioning.
  /// - [colorScale]: Scale transformation for color mapping.
  /// - [sizeScale]: Scale transformation for size mapping.
  /// - [theme]: Visual theme containing colors, fonts, and styling options.
  /// - [animationProgress]: Current animation progress from 0.0 to 1.0.
  /// - [coordFlipped]: Whether to flip X and Y coordinates (horizontal charts).
  /// - [panXDomain]: Custom X-axis domain for panning functionality.
  /// - [panYDomain]: Custom Y-axis domain for panning functionality.
  AnimatedChartPainter({
    required this.data,
    this.xColumn,
    this.yColumn,
    this.y2Column,
    this.colorColumn,
    this.sizeColumn,
    this.pieValueColumn,
    this.pieCategoryColumn,
    this.heatMapXColumn,
    this.heatMapYColumn,
    this.heatMapValueColumn,
    this.progressValueColumn,
    this.progressLabelColumn,
    this.progressCategoryColumn,
    required this.geometries,
    this.xScale,
    this.yScale,
    this.y2Scale,
    this.colorScale,
    this.sizeScale,
    required this.theme,
    required this.animationProgress,
    this.coordFlipped = false,
    this.panXDomain,
    this.panYDomain,
  });

  /// Renders the complete chart visualization on the provided canvas.
  ///
  /// This method orchestrates the entire chart drawing process including:
  /// - Setting up scales and transformations for data-to-pixel mapping
  /// - Drawing background, grid, and axes
  /// - Rendering all specified geometries (points, lines, bars, areas, pies, heatmaps)
  /// - Applying animations based on the current animation progress
  /// - Handling coordinate flipping and dual Y-axis configurations
  /// - Clipping content to plot boundaries
  ///
  /// The method automatically adapts to different chart types and configurations:
  /// - Skips grid and axes for pie charts and heat maps
  /// - Applies special axis handling for heat map categorical data
  /// - Adjusts padding for dual Y-axis layouts
  /// - Uses pan domains when available for interactive charts
  ///
  /// Parameters:
  /// - [canvas]: The Flutter canvas to draw on
  /// - [size]: Available drawing area dimensions
  /// Helper method to apply alpha to all colors in a gradient
  Gradient _applyAlphaToGradient(Gradient gradient, double alpha) {
    final clampedAlpha = alpha.clamp(0.0, 1.0);
    final newColors = gradient.colors
        .map((color) => color.withAlpha(
            (((color.a * 255.0).round() & 0xff) * clampedAlpha).round()))
        .toList();

    if (gradient is LinearGradient) {
      return LinearGradient(
        begin: gradient.begin,
        end: gradient.end,
        colors: newColors,
        stops: gradient.stops,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
      );
    } else if (gradient is RadialGradient) {
      return RadialGradient(
        center: gradient.center,
        radius: gradient.radius,
        colors: newColors,
        stops: gradient.stops,
        tileMode: gradient.tileMode,
        focal: gradient.focal,
        focalRadius: gradient.focalRadius,
        transform: gradient.transform,
      );
    } else if (gradient is SweepGradient) {
      return SweepGradient(
        center: gradient.center,
        startAngle: gradient.startAngle,
        endAngle: gradient.endAngle,
        colors: newColors,
        stops: gradient.stops,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
      );
    }

    // Fallback: return original gradient if unknown type
    return gradient;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || geometries.isEmpty) return;

    // Adjust padding for dual Y-axis
    final hasSecondaryY =
        hasSecondaryYAxis(y2Column: y2Column, geometries: geometries);
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
    final y2Scale = hasSecondaryY
        ? _setupYScale(
            plotArea.height,
            geometries.any((g) => g is BarGeometry),
            YAxis.secondary,
          )
        : null;
    final colorScale = _setupColorScale();
    final sizeScale = _setupSizeScale();

    final hasPieChart = geometries.any((g) => g is PieGeometry);
    final hasHeatMapChart = geometries.any((g) => g is HeatMapGeometry);

    _drawBackground(canvas, plotArea);

    // Skip grid and axes for pie charts and heatmaps
    if (!hasPieChart && !hasHeatMapChart) {
      _drawGrid(canvas, plotArea, xScale, yScale, y2Scale);
    }

    // Clip rendering to plot area to prevent drawing over axis labels
    canvas.save();
    canvas.clipRect(plotArea);

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

    // Restore canvas state to draw axes outside clipped area
    canvas.restore();

    // Skip axes for pie charts, draw special axes for heatmaps
    if (!hasPieChart && !hasHeatMapChart) {
      _drawAxes(canvas, size, plotArea, xScale, yScale, y2Scale);
    } else if (hasHeatMapChart) {
      _drawHeatMapAxes(canvas, size, plotArea);
    }
  }

  Scale _setupXScale(double width, bool hasBarGeometry) {
    if (coordFlipped) {
      final preconfigured = yScale;
      final scale =
          (preconfigured is LinearScale ? preconfigured : LinearScale());
      final dataCol = yColumn;

      if (dataCol == null || data.isEmpty) {
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
        scale.range = [0, width];
        return scale;
      }

      final values = data
          .map((d) => getNumericValue(d[dataCol]))
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
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
      }
      scale.range = [0, width];
      return scale;
    } else {
      final preconfigured = xScale;
      final dataCol = xColumn;
      if (preconfigured is OrdinalScale ||
          (hasBarGeometry && isColumnCategorical(dataCol, data))) {
        final scale =
            (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
        if (dataCol == null || data.isEmpty) {
          scale.domain = [];
          scale.range = [0, width];
          return scale;
        }
        if (scale.domain.isEmpty) {
          final distinctValues = data
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
          scale.domain = scale.min != null && scale.max != null
              ? [scale.min!, scale.max!]
              : [0, 1];
          scale.range = [0, width];
          return scale;
        }
        final values = data
            .map((d) => getNumericValue(d[dataCol]))
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

          // Use pan domain if available (for visual panning)
          if (!coordFlipped && panXDomain != null) {
            scale.domain = [panXDomain![0], panXDomain![1]];
          } else {
            scale.domain = [domainMin, domainMax];
          }

          if (scale.domain[0] == scale.domain[1]) {
            scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
          }
        } else {
          scale.domain = scale.min != null && scale.max != null
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
      final preconfigured = xScale;
      final scale =
          (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
      final dataCol = xColumn;

      if (dataCol == null || data.isEmpty) {
        scale.domain = [];
        scale.range = [0, height];
        return scale;
      }
      if (scale.domain.isEmpty) {
        final distinctValues = data
            .map((d) => d[dataCol])
            .where((v) => v != null)
            .toSet()
            .toList();
        scale.domain = distinctValues;
      }
      scale.range = [0, height];
      return scale;
    } else {
      final preconfigured = axis == YAxis.primary ? yScale : y2Scale;
      final dataCol = axis == YAxis.primary ? yColumn : y2Column;

      final scale =
          (preconfigured is LinearScale ? preconfigured : LinearScale());
      if (dataCol == null || data.isEmpty) {
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
        scale.range = [height, 0];
        return scale;
      }

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
          final y = getNumericValue(point[dataCol]);
          if (y == null || !y.isFinite || y <= 0) continue;

          groups[x] = (groups[x] ?? 0) + y;
        }
        values = groups.values.where((v) => v.isFinite).cast<double>().toList();
      } else {
        values = data
            .map((d) => getNumericValue(d[dataCol]))
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

        // Use pan domain if available (for visual panning)
        if (!coordFlipped && axis == YAxis.primary && panYDomain != null) {
          scale.domain = [panYDomain![0], panYDomain![1]];
        } else {
          scale.domain = [domainMin, domainMax];
        }

        if (scale.domain[0] == scale.domain[1]) {
          scale.domain = [scale.domain[0] - 0.5, scale.domain[1] + 0.5];
        }
      } else {
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
      }
      scale.range = [height, 0];
      return scale;
    }
  }

  ColorScale _setupColorScale() {
    // For pie charts, use category column; otherwise use color column
    final hasPieChart = geometries.any((g) => g is PieGeometry);
    final columnToUse = hasPieChart && pieCategoryColumn != null
        ? pieCategoryColumn
        : colorColumn;

    if (columnToUse == null) return ColorScale();
    final values = data.map((d) => d[columnToUse]).toSet().toList();

    // Extract gradients for the values if available
    Map<dynamic, Gradient>? gradients;
    if (theme.categoryGradients != null &&
        theme.categoryGradients!.isNotEmpty) {
      gradients = {};
      for (final value in values) {
        if (theme.categoryGradients!.containsKey(value.toString())) {
          gradients[value] = theme.categoryGradients![value.toString()]!;
        }
      }
    }

    return ColorScale(
      values: values,
      colors: theme.colorPalette,
      gradients: gradients,
    );
  }

  SizeScale _setupSizeScale() {
    if (sizeColumn == null) return SizeScale();
    final values = data
        .map((d) => getNumericValue(d[sizeColumn]))
        .where((v) => v != null)
        .cast<double>()
        .toList();
    if (values.isNotEmpty) {
      // Check if we have a bubble geometry to use its size range
      final bubbleGeometries = geometries.whereType<BubbleGeometry>().toList();
      final bubbleGeometry =
          bubbleGeometries.isNotEmpty ? bubbleGeometries.first : null;
      final minSize = bubbleGeometry?.minSize ?? theme.pointSizeMin;
      final maxSize = bubbleGeometry?.maxSize ?? theme.pointSizeMax;

      return SizeScale(
        domain: [values.reduce(math.min), values.reduce(math.max)],
        range: [minSize, maxSize],
      );
    }
    return SizeScale();
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
        final ordinalScale = xScale;
        x = plotArea.left + ordinalScale.bandCenter(tick);
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
        final ordinalScale = yScale;
        y = plotArea.top + ordinalScale.bandCenter(tick);
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
    } else if (geometry is AreaGeometry) {
      _drawAreasAnimated(
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
    } else if (geometry is PieGeometry) {
      _drawPieAnimated(
        canvas,
        plotArea,
        geometry,
        colorScale,
      );
    } else if (geometry is HeatMapGeometry) {
      _drawHeatMapAnimated(
        canvas,
        plotArea,
        geometry,
        colorScale,
      );
    } else if (geometry is BubbleGeometry) {
      _drawBubblesAnimated(
        canvas,
        plotArea,
        geometry,
        xScale,
        yScale,
        colorScale,
        sizeScale,
        isSecondaryY,
      );
    } else if (geometry is ProgressGeometry) {
      _drawProgressAnimated(
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
      final y = getNumericValue(point[yCol]);

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
      final y = getNumericValue(point[yCol]);
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
        // Use bandCenter to center the bars, then adjust for group width
        final centerPos = plotArea.left + xScale.bandCenter(x);
        totalGroupWidth = xScale.bandWidth * geometry.width;
        basePosition = centerPos - (totalGroupWidth / 2);
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
          x,
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
        final y = getNumericValue(point[yCol]);
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
    // Priority: geometry.color > colorScale > theme fallback
    final dynamic colorOrGradient;
    if (geometry.color != null) {
      colorOrGradient = geometry.color!;
    } else if (colorColumn != null) {
      colorOrGradient = colorScale.scale(dataPoint[colorColumn]);
    } else {
      colorOrGradient = theme.colorPalette.isNotEmpty
          ? theme.colorPalette.first
          : theme.primaryColor;
    }

    final paint = Paint()..style = PaintingStyle.fill;

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

    // Apply gradient or solid color based on what we received
    if (colorOrGradient is Gradient) {
      final alphaGradient =
          _applyAlphaToGradient(colorOrGradient, geometry.alpha);
      paint.shader = alphaGradient.createShader(barRect);
    } else {
      final color = colorOrGradient as Color;
      paint.color = color.withAlpha((geometry.alpha * 255).round());
    }

    if (geometry.borderRadius != null &&
        geometry.borderRadius != BorderRadius.zero) {
      canvas.drawRRect(geometry.borderRadius!.toRRect(barRect), paint);
    } else {
      canvas.drawRect(barRect, paint);
    }

    if (geometry.borderWidth > 0) {
      final borderPaint = Paint()
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
      final xRawValue = point[xColumn];
      final y = getNumericValue(point[yCol]);

      if (xRawValue == null || y == null) continue;

      // Handle both ordinal and continuous X-scales
      double pointX;
      if (xScale is OrdinalScale) {
        // For ordinal scales, use the raw string value with bandCenter
        final ordinalScale = xScale;
        pointX = plotArea.left + ordinalScale.bandCenter(xRawValue);
      } else {
        // For continuous scales, convert to number first
        final x = getNumericValue(xRawValue);
        if (x == null) continue;
        pointX = plotArea.left + xScale.scale(x);
      }

      final pointDelay = data.isNotEmpty ? i / data.length * 0.2 : 0.0;
      final pointProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - pointDelay) / math.max(0.001, 1.0 - pointDelay),
        ),
      );

      if (pointProgress <= 0) continue;

      // Priority: geometry.color > colorScale > theme fallback
      final dynamic colorOrGradient;
      if (geometry.color != null) {
        colorOrGradient = geometry.color!;
      } else if (colorColumn != null) {
        colorOrGradient = colorScale.scale(point[colorColumn]);
      } else {
        colorOrGradient = theme.colorPalette.isNotEmpty
            ? theme.colorPalette.first
            : theme.primaryColor;
      }

      final size = sizeColumn != null
          ? sizeScale.scale(point[sizeColumn])
          : theme.pointSizeDefault;

      final pointY = plotArea.top + yScale.scale(y);

      final paint = Paint()..style = PaintingStyle.fill;

      // Apply gradient or solid color based on what we received
      if (colorOrGradient is Gradient) {
        // For points, create a square shader area around the point
        final shaderRect = Rect.fromCenter(
          center: Offset(pointX, pointY),
          width: size * 2,
          height: size * 2,
        );
        final combinedAlpha = geometry.alpha * pointProgress;
        final alphaGradient =
            _applyAlphaToGradient(colorOrGradient, combinedAlpha);
        paint.shader = alphaGradient.createShader(shaderRect);
      } else {
        final color = colorOrGradient as Color;
        paint.color = color.withAlpha(
          (geometry.alpha * pointProgress * 255).round(),
        );
      }

      if (!pointX.isFinite || !pointY.isFinite) {
        continue;
      }

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
        final borderPaint = Paint()
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

  void _drawBubblesAnimated(
    Canvas canvas,
    Rect plotArea,
    BubbleGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    SizeScale sizeScale,
    bool isSecondaryY,
  ) {
    final yCol = isSecondaryY ? y2Column : yColumn;

    if (sizeColumn == null) {
      // If no size column is specified, treat as regular points
      return;
    }

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final x = getNumericValue(point[xColumn]);
      final y = getNumericValue(point[yCol]);
      final sizeValue = getNumericValue(point[sizeColumn]);

      if (x == null || y == null || sizeValue == null) continue;

      // Calculate bubble animation delay
      final bubbleDelay = data.isNotEmpty ? i / data.length * 0.2 : 0.0;
      final bubbleProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - bubbleDelay) /
              math.max(0.001, 1.0 - bubbleDelay),
        ),
      );

      if (bubbleProgress <= 0) continue;

      // Get bubble color
      final color = geometry.color ??
          (colorColumn != null
              ? colorScale.scale(point[colorColumn])
              : (theme.colorPalette.isNotEmpty
                  ? theme.colorPalette.first
                  : theme.primaryColor));

      // Calculate bubble size using size scale
      final bubbleSize = sizeScale.scale(sizeValue);

      // Calculate screen coordinates
      final pointX = plotArea.left + xScale.scale(x);
      final pointY = plotArea.top + yScale.scale(y);

      if (!pointX.isFinite || !pointY.isFinite) {
        continue;
      }

      // Create bubble paint with animation
      final paint = Paint()
        ..color = color.withAlpha(
          (geometry.alpha * bubbleProgress * 255).round(),
        )
        ..style = PaintingStyle.fill;

      final animatedSize = bubbleSize * bubbleProgress;

      // Draw bubble based on shape
      if (geometry.shape == PointShape.circle) {
        canvas.drawCircle(
          Offset(pointX, pointY),
          animatedSize,
          paint,
        );
      } else if (geometry.shape == PointShape.square) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(pointX, pointY),
            width: animatedSize * 2,
            height: animatedSize * 2,
          ),
          paint,
        );
      } else if (geometry.shape == PointShape.triangle) {
        final path = Path();
        path.moveTo(pointX, pointY - animatedSize);
        path.lineTo(
          pointX - animatedSize,
          pointY + animatedSize,
        );
        path.lineTo(
          pointX + animatedSize,
          pointY + animatedSize,
        );
        path.close();
        canvas.drawPath(path, paint);
      }

      // Draw border if specified
      if (geometry.borderWidth > 0) {
        final borderColor = geometry.borderColor ?? theme.borderColor;
        final borderPaint = Paint()
          ..color = borderColor.withAlpha(
            (geometry.alpha * bubbleProgress * 255).round(),
          )
          ..strokeWidth = geometry.borderWidth
          ..style = PaintingStyle.stroke;

        if (geometry.shape == PointShape.circle) {
          canvas.drawCircle(
            Offset(pointX, pointY),
            animatedSize,
            borderPaint,
          );
        } else if (geometry.shape == PointShape.square) {
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(pointX, pointY),
              width: animatedSize * 2,
              height: animatedSize * 2,
            ),
            borderPaint,
          );
        } else if (geometry.shape == PointShape.triangle) {
          final path = Path();
          path.moveTo(pointX, pointY - animatedSize);
          path.lineTo(
            pointX - animatedSize,
            pointY + animatedSize,
          );
          path.lineTo(
            pointX + animatedSize,
            pointY + animatedSize,
          );
          path.close();
          canvas.drawPath(path, borderPaint);
        }
      }

      // Draw label if enabled
      if (geometry.showLabels && bubbleProgress > 0.7) {
        final labelText = geometry.labelFormatter != null
            ? geometry.labelFormatter!(sizeValue)
            : sizeValue.toStringAsFixed(1);

        final textStyle = geometry.labelStyle ??
            TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            );

        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: textStyle.copyWith(
              color: textStyle.color?.withAlpha(
                (255 * bubbleProgress).round(),
              ),
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Position label offset from bubble center
        final labelOffset = Offset(
          pointX - textPainter.width / 2,
          pointY - animatedSize - geometry.labelOffset - textPainter.height / 2,
        );

        // Draw text background for better readability
        final backgroundRect = Rect.fromLTWH(
          labelOffset.dx - 2,
          labelOffset.dy - 1,
          textPainter.width + 4,
          textPainter.height + 2,
        );

        final backgroundPaint = Paint()
          ..color = Colors.white.withValues(
            alpha: 0.8 * bubbleProgress,
          )
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(backgroundRect, const Radius.circular(2)),
          backgroundPaint,
        );

        textPainter.paint(canvas, labelOffset);
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
          yCol,
        );
      }
    } else {
      // Draw single line for all data
      final lineColor = geometry.color ??
          (theme.colorPalette.isNotEmpty
              ? theme.colorPalette.first
              : theme.primaryColor);
      _drawSingleLineAnimated(
        canvas,
        plotArea,
        data,
        xScale,
        yScale,
        lineColor,
        geometry,
        yCol,
      );
    }
  }

  void _drawSingleLineAnimated(
    Canvas canvas,
    Rect plotArea,
    List<Map<String, dynamic>> lineData,
    Scale xScale,
    Scale yScale,
    Color color,
    LineGeometry geometry,
    String yCol,
  ) {
    // Sort data by x value for proper line connection
    final sortedData = List<Map<String, dynamic>>.from(lineData);
    sortedData.sort((a, b) {
      final aXValue = a[xColumn];
      final bXValue = b[xColumn];

      if (aXValue == null && bXValue == null) return 0;
      if (aXValue == null) return -1;
      if (bXValue == null) return 1;

      // Get the actual plotted X position for proper ordering
      double aXPosition, bXPosition;

      if (xScale is OrdinalScale) {
        // For ordinal scales, use domain index as fallback to scale position
        aXPosition = xScale.bandCenter(aXValue);
        bXPosition = xScale.bandCenter(bXValue);
      } else {
        // For continuous scales, convert to numeric and scale
        final aXNum = getNumericValue(aXValue) ?? 0;
        final bXNum = getNumericValue(bXValue) ?? 0;
        aXPosition = xScale.scale(aXNum);
        bXPosition = xScale.scale(bXNum);
      }

      return aXPosition.compareTo(bXPosition);
    });

    final points = <Offset>[];

    for (int i = 0; i < sortedData.length; i++) {
      final point = sortedData[i];
      final xRawValue = point[xColumn];
      final yVal = getNumericValue(point[yCol]);

      if (xRawValue == null || yVal == null) {
        continue;
      }

      // Handle both ordinal and continuous X-scales
      double screenX;
      if (xScale is OrdinalScale) {
        // For ordinal scales, use the raw string value with bandCenter
        final ordinalScale = xScale;
        screenX = plotArea.left + ordinalScale.bandCenter(xRawValue);
      } else {
        // For continuous scales, convert to number first
        final xVal = getNumericValue(xRawValue);
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

    final paint = Paint()
      ..color = color.withAlpha((geometry.alpha * 255).round())
      ..strokeWidth = geometry.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

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

      final double dx = lastFullPoint.dx +
          (nextPoint.dx - lastFullPoint.dx) * partialSegmentProgress;
      final double dy = lastFullPoint.dy +
          (nextPoint.dy - lastFullPoint.dy) * partialSegmentProgress;
      path.lineTo(dx, dy);
    }

    if (fullyDrawnSegments > 0 ||
        (partialSegmentProgress > 0.001 && fullyDrawnSegments < numSegments)) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawAreasAnimated(
    Canvas canvas,
    Rect plotArea,
    AreaGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    bool isSecondaryY,
  ) {
    final yCol = isSecondaryY ? y2Column : yColumn;

    if (yCol == null) {
      return;
    }

    if (colorColumn != null) {
      // Group by color and draw separate areas
      final groupedData = <dynamic, List<Map<String, dynamic>>>{};
      for (final point in data) {
        final colorValue = point[colorColumn];
        groupedData.putIfAbsent(colorValue, () => []).add(point);
      }

      for (final entry in groupedData.entries) {
        final colorValue = entry.key;
        final groupData = entry.value;
        final areaColor = geometry.color ?? colorScale.scale(colorValue);
        _drawSingleArea(
          canvas,
          plotArea,
          groupData,
          xScale,
          yScale,
          areaColor,
          geometry,
          yCol,
        );
      }
    } else {
      // Draw single area for all data
      final areaColor = geometry.color ?? theme.primaryColor;
      _drawSingleArea(
        canvas,
        plotArea,
        data,
        xScale,
        yScale,
        areaColor,
        geometry,
        yCol,
      );
    }
  }

  void _drawSingleArea(
    Canvas canvas,
    Rect plotArea,
    List<Map<String, dynamic>> areaData,
    Scale xScale,
    Scale yScale,
    Color color,
    AreaGeometry geometry,
    String yCol,
  ) {
    // Sort data by x value for proper area connection
    final sortedData = List<Map<String, dynamic>>.from(areaData);
    sortedData.sort((a, b) {
      final aX = getNumericValue(a[xColumn]) ?? 0;
      final bX = getNumericValue(b[xColumn]) ?? 0;
      return aX.compareTo(bX);
    });

    final points = <Offset>[];
    for (int i = 0; i < sortedData.length; i++) {
      final point = sortedData[i];
      final xRawValue = point[xColumn];
      final yVal = getNumericValue(point[yCol]);

      if (xRawValue == null || yVal == null) continue;

      // Handle both ordinal and continuous X-scales
      double screenX;
      if (xScale is OrdinalScale) {
        // For ordinal scales, use the raw string value with bandCenter
        final ordinalScale = xScale;
        screenX = plotArea.left + ordinalScale.bandCenter(xRawValue);
      } else {
        // For continuous scales, convert to number first
        final xVal = getNumericValue(xRawValue);
        if (xVal == null) continue;
        screenX = plotArea.left + xScale.scale(xVal);
      }

      final screenY = plotArea.top + yScale.scale(yVal);

      if (!screenX.isFinite || !screenY.isFinite) {
        continue;
      }

      points.add(Offset(screenX, screenY));
    }

    if (points.length < 2) return;

    final areaProgress = math.max(0.0, math.min(1.0, animationProgress));
    if (areaProgress <= 0.001) {
      return;
    }

    // Create path for area fill
    final areaPath = Path();
    final int numSegments = points.length - 1;
    final double totalProgressiveSegments = numSegments * areaProgress;
    final int fullyDrawnSegments = totalProgressiveSegments.floor();
    final double partialSegmentProgress =
        totalProgressiveSegments - fullyDrawnSegments;

    if (fullyDrawnSegments > 0 || partialSegmentProgress > 0.001) {
      // Start from bottom of first point
      final baselineY = plotArea.top + yScale.scale(0);
      areaPath.moveTo(points[0].dx, baselineY);
      areaPath.lineTo(points[0].dx, points[0].dy);

      // Draw line to all fully drawn points
      for (int i = 0; i < fullyDrawnSegments; i++) {
        areaPath.lineTo(points[i + 1].dx, points[i + 1].dy);
      }

      // Handle partial segment
      if (partialSegmentProgress > 0.001 && fullyDrawnSegments < numSegments) {
        final Offset lastFullPoint = points[fullyDrawnSegments];
        final Offset nextPoint = points[fullyDrawnSegments + 1];

        final double dx = lastFullPoint.dx +
            (nextPoint.dx - lastFullPoint.dx) * partialSegmentProgress;
        final double dy = lastFullPoint.dy +
            (nextPoint.dy - lastFullPoint.dy) * partialSegmentProgress;
        areaPath.lineTo(dx, dy);

        // Close area back to baseline
        areaPath.lineTo(dx, baselineY);
      } else if (fullyDrawnSegments > 0) {
        // Close area back to baseline from last full point
        final lastPoint = points[fullyDrawnSegments];
        areaPath.lineTo(lastPoint.dx, baselineY);
      }

      areaPath.close();

      // Draw filled area if enabled
      if (geometry.fillArea) {
        final fillPaint = Paint()
          ..color = color.withAlpha((geometry.alpha * 255).round())
          ..style = PaintingStyle.fill;
        canvas.drawPath(areaPath, fillPaint);
      }

      // Draw stroke on top of fill
      if (geometry.strokeWidth > 0) {
        final strokePath = Path();
        strokePath.moveTo(points[0].dx, points[0].dy);

        for (int i = 0; i < fullyDrawnSegments; i++) {
          strokePath.lineTo(points[i + 1].dx, points[i + 1].dy);
        }

        if (partialSegmentProgress > 0.001 &&
            fullyDrawnSegments < numSegments) {
          final Offset lastFullPoint = points[fullyDrawnSegments];
          final Offset nextPoint = points[fullyDrawnSegments + 1];

          final double dx = lastFullPoint.dx +
              (nextPoint.dx - lastFullPoint.dx) * partialSegmentProgress;
          final double dy = lastFullPoint.dy +
              (nextPoint.dy - lastFullPoint.dy) * partialSegmentProgress;
          strokePath.lineTo(dx, dy);
        }

        final strokePaint = Paint()
          ..color = color.withAlpha(255) // Full opacity for stroke
          ..strokeWidth = geometry.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        canvas.drawPath(strokePath, strokePaint);
      }
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
    final paint = Paint()
      ..color = theme.axisColor
      ..strokeWidth = theme.axisWidth
      ..style = PaintingStyle.stroke;

    final axisLabelStyle = theme.axisLabelStyle ??
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
      // Use bandCenter for OrdinalScale to center ticks on bars
      final pos = plotArea.left +
          (xScale is OrdinalScale
              // ignore: unnecessary_cast
              ? (xScale as OrdinalScale).bandCenter(tick)
              : xScale.scale(tick));
      canvas.drawLine(
        Offset(pos, plotArea.bottom),
        Offset(pos, plotArea.bottom + theme.axisWidth * 2),
        paint,
      );

      final label = xScale.formatLabel(tick);
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
      // Use bandCenter for OrdinalScale to center ticks on bars (for horizontal bar charts)
      final pos = plotArea.top +
          (yScale is OrdinalScale
              // ignore: unnecessary_cast
              ? (yScale as OrdinalScale).bandCenter(tick)
              : yScale.scale(tick));
      canvas.drawLine(
        Offset(plotArea.left - theme.axisWidth * 2, pos),
        Offset(plotArea.left, pos),
        paint,
      );

      final label = yScale.formatLabel(tick);
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

        final label = y2Scale.formatLabel(tick);
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: axisLabelStyle.copyWith(
              color: theme.colorPalette.length > 1
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

  void _drawPieAnimated(
    Canvas canvas,
    Rect plotArea,
    PieGeometry geometry,
    ColorScale colorScale,
  ) {
    // Use pie-specific columns or fall back to regular columns
    final valueColumn = pieValueColumn ?? yColumn;
    final categoryColumn = pieCategoryColumn ?? colorColumn ?? xColumn;

    if (valueColumn == null || categoryColumn == null || data.isEmpty) {
      return;
    }

    // Calculate center point of the plot area
    final center = Offset(
      plotArea.left + plotArea.width / 2,
      plotArea.top + plotArea.height / 2,
    );

    // Calculate radius based on plot area (leave margin for labels)
    final maxRadius = math.min(plotArea.width, plotArea.height) / 2 - 50;
    final outerRadius = math.min(geometry.outerRadius, maxRadius);
    final innerRadius = math.min(geometry.innerRadius,
        outerRadius * 0.8); // Ensure inner radius isn't too close to outer

    // Extract and calculate values
    final values =
        data.map((d) => getNumericValue(d[valueColumn]) ?? 0).toList();
    final total = values.fold<double>(0, (sum, val) => sum + val);

    if (total <= 0) return;

    // Animation progress for pie chart
    final pieProgress = math.max(0.0, math.min(1.0, animationProgress));
    if (pieProgress <= 0.001) return;

    // Draw pie slices
    double currentAngle = geometry.startAngle;

    for (int i = 0; i < data.length; i++) {
      final value = values[i];
      if (value <= 0) continue;

      final sweepAngle = (value / total) * 2 * math.pi;
      final category = data[i][categoryColumn];
      final sliceColor = colorScale.scale(category);

      // Animation: each slice grows with a slight delay
      final sliceDelay =
          i / data.length * 0.3; // 30% of animation for staggering
      final sliceProgress = math.max(
        0.0,
        math.min(
          1.0,
          (pieProgress - sliceDelay) / math.max(0.001, 1.0 - sliceDelay),
        ),
      );

      if (sliceProgress <= 0) {
        currentAngle += sweepAngle;
        continue;
      }

      final animatedSweepAngle = sweepAngle * sliceProgress;

      // Calculate slice center for explosion effect
      Offset sliceCenter = center;
      if (geometry.explodeSlices) {
        final midAngle = currentAngle + animatedSweepAngle / 2;
        sliceCenter = Offset(
          center.dx + math.cos(midAngle) * geometry.explodeDistance,
          center.dy + math.sin(midAngle) * geometry.explodeDistance,
        );
      }

      // Create slice path
      final path = Path();
      if (innerRadius > 0) {
        // Donut chart - create proper donut slice path
        final outerStartX =
            sliceCenter.dx + math.cos(currentAngle) * outerRadius;
        final outerStartY =
            sliceCenter.dy + math.sin(currentAngle) * outerRadius;
        final innerEndX = sliceCenter.dx +
            math.cos(currentAngle + animatedSweepAngle) * innerRadius;
        final innerEndY = sliceCenter.dy +
            math.sin(currentAngle + animatedSweepAngle) * innerRadius;

        // Start at outer edge
        path.moveTo(outerStartX, outerStartY);

        // Draw outer arc
        path.arcTo(
          Rect.fromCircle(center: sliceCenter, radius: outerRadius),
          currentAngle,
          animatedSweepAngle,
          false,
        );

        // Draw line to inner edge
        path.lineTo(innerEndX, innerEndY);

        // Draw inner arc (in reverse)
        path.arcTo(
          Rect.fromCircle(center: sliceCenter, radius: innerRadius),
          currentAngle + animatedSweepAngle,
          -animatedSweepAngle,
          false,
        );

        // Close the path
        path.close();
      } else {
        // Full pie chart
        path.moveTo(sliceCenter.dx, sliceCenter.dy);
        path.arcTo(
          Rect.fromCircle(center: sliceCenter, radius: outerRadius),
          currentAngle,
          animatedSweepAngle,
          false,
        );
        path.close();
      }

      // Draw slice
      final fillPaint = Paint()
        ..color = sliceColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // Draw stroke if specified
      if (geometry.strokeWidth > 0) {
        final strokePaint = Paint()
          ..color = geometry.strokeColor ?? Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = geometry.strokeWidth;
        canvas.drawPath(path, strokePaint);
      }

      // Draw labels if enabled and slice is mostly visible
      if (geometry.showLabels && sliceProgress > 0.5) {
        _drawPieSliceLabel(
          canvas,
          sliceCenter,
          currentAngle + animatedSweepAngle / 2,
          value,
          total,
          category.toString(),
          geometry.labelStyle ?? theme.axisTextStyle,
          geometry,
        );
      }

      currentAngle += sweepAngle;
    }
  }

  void _drawPieSliceLabel(
    Canvas canvas,
    Offset center,
    double angle,
    double value,
    double total,
    String category,
    TextStyle style,
    PieGeometry geometry,
  ) {
    final radius = geometry.labelRadius;
    final showPercentages = geometry.showPercentages;

    String labelText;
    if (showPercentages) {
      final percentageRatio = value /
          total; // 0.0-1.0 range, as NumberFormat expects for percentages
      final percentageText = geometry.labelFormatter(percentageRatio);
      labelText = '$category\n$percentageText';
    } else {
      labelText = '$category\n${geometry.labelFormatter(value)}';
    }

    final textPainter = TextPainter(
      text: TextSpan(text: labelText, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final labelOffset = Offset(
      center.dx + math.cos(angle) * radius - textPainter.width / 2,
      center.dy + math.sin(angle) * radius - textPainter.height / 2,
    );

    // Draw label background for better readability
    final labelRect = Rect.fromLTWH(
      labelOffset.dx - 4,
      labelOffset.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      backgroundPaint,
    );

    textPainter.paint(canvas, labelOffset);
  }

  void _drawHeatMapAnimated(
    Canvas canvas,
    Rect plotArea,
    HeatMapGeometry geometry,
    ColorScale colorScale,
  ) {
    // Use heat map specific columns
    final xCol = heatMapXColumn ?? xColumn;
    final yCol = heatMapYColumn ?? yColumn;
    final valueCol = heatMapValueColumn ?? colorColumn;

    if (xCol == null || yCol == null || valueCol == null || data.isEmpty) {
      return;
    }

    // Get unique X and Y values to determine grid
    final xValues =
        data.map((d) => d[xCol]).where((v) => v != null).toSet().toList();
    final yValues =
        data.map((d) => d[yCol]).where((v) => v != null).toSet().toList();

    if (xValues.isEmpty || yValues.isEmpty) {
      return;
    }

    // Sort values for consistent ordering using existing helper
    sortHeatMapValues(xValues);
    sortHeatMapValues(yValues);

    // Calculate cell dimensions considering spacing
    final totalSpacingX = geometry.cellSpacing * (xValues.length + 1);
    final totalSpacingY = geometry.cellSpacing * (yValues.length + 1);
    double cellWidth = (plotArea.width - totalSpacingX) / xValues.length;
    double cellHeight = (plotArea.height - totalSpacingY) / yValues.length;

    if (geometry.cellAspectRatio != null) {
      // Adjust cell dimensions to maintain aspect ratio
      final targetHeight = cellWidth / geometry.cellAspectRatio!;
      if (targetHeight < cellHeight) {
        cellHeight = targetHeight;
      } else {
        cellWidth = cellHeight * geometry.cellAspectRatio!;
      }
    }

    // Get value range for color mapping
    final values = data
        .map((d) => getNumericValue(d[valueCol]))
        .where((v) => v != null && v.isFinite)
        .cast<double>()
        .toList();

    if (values.isEmpty) {
      return;
    }

    final minValue = geometry.minValue ?? values.reduce(math.min);
    final maxValue = geometry.maxValue ?? values.reduce(math.max);
    final valueRange = maxValue - minValue;

    // Create a map for quick lookup
    final dataMap = <String, double>{};
    for (final point in data) {
      final x = point[xCol];
      final y = point[yCol];
      final value = getNumericValue(point[valueCol]);
      if (x != null && y != null && value != null) {
        final key = '${x}_$y';
        dataMap[key] = value;
      }
    }

    // Animation progress
    final heatMapProgress = math.max(0.0, math.min(1.0, animationProgress));
    if (heatMapProgress <= 0.001) {
      return;
    }

    // Draw cells
    for (int xi = 0; xi < xValues.length; xi++) {
      for (int yi = 0; yi < yValues.length; yi++) {
        final xVal = xValues[xi];
        final yVal = yValues[yi];
        final key = '${xVal}_$yVal';
        final value = dataMap[key];

        // Calculate cell position with spacing
        final cellRect = Rect.fromLTWH(
          plotArea.left +
              geometry.cellSpacing +
              xi * (cellWidth + geometry.cellSpacing),
          plotArea.top +
              geometry.cellSpacing +
              yi * (cellHeight + geometry.cellSpacing),
          cellWidth,
          cellHeight,
        );

        if (value == null) {
          // Draw null value cell if color is configured
          if (geometry.nullValueColor != null) {
            final baseAlpha =
                (geometry.nullValueColor!.a * 255.0).round() & 0xff;
            final animatedAlpha = (baseAlpha * heatMapProgress).round();
            final clampedAlpha = animatedAlpha.clamp(0, 255).toInt();

            final nullPaint = Paint()
              ..color = geometry.nullValueColor!.withAlpha(clampedAlpha)
              ..style = PaintingStyle.fill;

            if (geometry.cellBorderRadius != null) {
              canvas.drawRRect(
                geometry.cellBorderRadius!.toRRect(cellRect),
                nullPaint,
              );
            } else {
              canvas.drawRect(cellRect, nullPaint);
            }
          }
          continue;
        }

        // Calculate cell animation with wave effect
        final cellDelay = (xi + yi) / (xValues.length + yValues.length) * 0.3;
        final cellProgress = math.max(
          0.0,
          math.min(
            1.0,
            (heatMapProgress - cellDelay) / math.max(0.001, 1.0 - cellDelay),
          ),
        );

        if (cellProgress <= 0) continue;

        // Calculate color based on value
        Color cellColor;
        // Calculate normalized value once for both color and text logic
        final normalizedValue = valueRange > 0
            ? ((value - minValue) / valueRange).clamp(0.0, 1.0)
            : 0.5;

        if (geometry.colorGradient != null &&
            geometry.colorGradient!.isNotEmpty) {
          // Use provided color gradient
          if (geometry.interpolateColors) {
            cellColor = interpolateGradientColor(
                normalizedValue, geometry.colorGradient!);
          } else {
            // Use discrete colors
            final index =
                (normalizedValue * (geometry.colorGradient!.length - 1))
                    .round();
            cellColor = geometry.colorGradient![index];
          }
        } else {
          // Use default gradient with enhanced visibility
          cellColor = defaultHeatMapColor(normalizedValue);
        }

        // Animate cell
        Rect animatedRect = cellRect;
        final centerX = cellRect.center.dx;
        final centerY = cellRect.center.dy;
        final scaledWidth = cellRect.width * cellProgress;
        final scaledHeight = cellRect.height * cellProgress;
        animatedRect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: scaledWidth,
          height: scaledHeight,
        );

        // Draw cell
        final baseAlpha = (cellColor.a * 255.0).round() & 0xff;
        final animatedAlpha = (baseAlpha * cellProgress).round();
        final minVisibleAlpha = math.max(200, animatedAlpha);
        final clampedAlpha = minVisibleAlpha.clamp(0, 255).toInt();

        final cellPaint = Paint()
          ..color = cellColor.withAlpha(clampedAlpha)
          ..style = PaintingStyle.fill;

        if (geometry.cellBorderRadius != null) {
          // Scale border radius with animation
          final animatedBorderRadius = BorderRadius.only(
            topLeft: geometry.cellBorderRadius!.topLeft * cellProgress,
            topRight: geometry.cellBorderRadius!.topRight * cellProgress,
            bottomLeft: geometry.cellBorderRadius!.bottomLeft * cellProgress,
            bottomRight: geometry.cellBorderRadius!.bottomRight * cellProgress,
          );
          canvas.drawRRect(
            animatedBorderRadius.toRRect(animatedRect),
            cellPaint,
          );
        } else {
          canvas.drawRect(animatedRect, cellPaint);
        }

        // Draw value label if configured
        if (geometry.showValues && cellProgress > 0.5) {
          final labelText =
              geometry.valueFormatter?.call(value) ?? value.toStringAsFixed(1);

          // Use black text for normalized values < 15%, otherwise use brightness-based logic
          final textColor = normalizedValue < 0.15
              ? Colors.black
              : (ThemeData.estimateBrightnessForColor(cellColor) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black);

          final textStyle = geometry.valueTextStyle ??
              TextStyle(
                color: textColor,
                fontSize: 10,
              );

          final textPainter = TextPainter(
            text: TextSpan(
              text: labelText,
              style: textStyle.copyWith(
                color: textStyle.color?.withAlpha((255 * cellProgress).round()),
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          // Calculate text position (center of cell)
          final textOffset = Offset(
            animatedRect.center.dx - textPainter.width / 2,
            animatedRect.center.dy - textPainter.height / 2,
          );

          textPainter.paint(canvas, textOffset);
        }
      }
    }
  }

  void _drawHeatMapAxes(Canvas canvas, Size size, Rect plotArea) {
    // Use heat map specific columns
    final xCol = heatMapXColumn ?? xColumn;
    final yCol = heatMapYColumn ?? yColumn;
    final valueCol = heatMapValueColumn ?? colorColumn;

    if (xCol == null || yCol == null || valueCol == null || data.isEmpty) {
      return;
    }

    // Get unique X and Y values to determine grid
    final xValues =
        data.map((d) => d[xCol]).where((v) => v != null).toSet().toList();
    final yValues =
        data.map((d) => d[yCol]).where((v) => v != null).toSet().toList();

    if (xValues.isEmpty || yValues.isEmpty) {
      return;
    }

    // Sort values for consistent ordering with proper day/time logic
    sortHeatMapValues(xValues);
    sortHeatMapValues(yValues);

    // Find the heat map geometry for styling
    final heatMapGeom = geometries.firstWhere(
      (g) => g is HeatMapGeometry,
      orElse: () => HeatMapGeometry(),
    ) as HeatMapGeometry;

    // Calculate cell dimensions considering spacing
    final totalSpacingX = heatMapGeom.cellSpacing * (xValues.length + 1);
    final totalSpacingY = heatMapGeom.cellSpacing * (yValues.length + 1);
    double cellWidth = (plotArea.width - totalSpacingX) / xValues.length;
    double cellHeight = (plotArea.height - totalSpacingY) / yValues.length;

    if (heatMapGeom.cellAspectRatio != null) {
      // Adjust cell dimensions to maintain aspect ratio
      final targetHeight = cellWidth / heatMapGeom.cellAspectRatio!;
      if (targetHeight < cellHeight) {
        cellHeight = targetHeight;
      } else {
        cellWidth = cellHeight * heatMapGeom.cellAspectRatio!;
      }
    }

    final axisLabelStyle = theme.axisLabelStyle ??
        const TextStyle(color: Colors.black, fontSize: 12);

    // Draw X-axis labels (bottom)
    for (int xi = 0; xi < xValues.length; xi++) {
      final xVal = xValues[xi];
      final centerX = plotArea.left +
          heatMapGeom.cellSpacing +
          xi * (cellWidth + heatMapGeom.cellSpacing) +
          cellWidth / 2;

      final label = xVal.toString();
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: axisLabelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          plotArea.bottom + 8,
        ),
      );
    }

    // Draw Y-axis labels (left)
    for (int yi = 0; yi < yValues.length; yi++) {
      final yVal = yValues[yi];
      final centerY = plotArea.top +
          heatMapGeom.cellSpacing +
          yi * (cellHeight + heatMapGeom.cellSpacing) +
          cellHeight / 2;

      final label = yVal.toString();
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: axisLabelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(minWidth: 0, maxWidth: plotArea.left - 16);
      textPainter.paint(
        canvas,
        Offset(
          plotArea.left - textPainter.width - 8,
          centerY - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.xColumn != xColumn ||
        oldDelegate.yColumn != yColumn ||
        oldDelegate.y2Column != y2Column ||
        oldDelegate.colorColumn != colorColumn ||
        oldDelegate.sizeColumn != sizeColumn ||
        oldDelegate.pieValueColumn != pieValueColumn ||
        oldDelegate.pieCategoryColumn != pieCategoryColumn ||
        oldDelegate.heatMapXColumn != heatMapXColumn ||
        oldDelegate.heatMapYColumn != heatMapYColumn ||
        oldDelegate.heatMapValueColumn != heatMapValueColumn ||
        oldDelegate.geometries != geometries ||
        oldDelegate.xScale != xScale ||
        oldDelegate.yScale != yScale ||
        oldDelegate.y2Scale != y2Scale ||
        oldDelegate.colorScale != colorScale ||
        oldDelegate.sizeScale != sizeScale ||
        oldDelegate.theme != theme ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.coordFlipped != coordFlipped ||
        !_listEquals(oldDelegate.panXDomain, panXDomain) ||
        !_listEquals(oldDelegate.panYDomain, panYDomain);
  }

  /// Helper method to compare two nullable lists for equality
  void _drawProgressAnimated(
    Canvas canvas,
    Rect plotArea,
    ProgressGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    bool isSecondaryY,
  ) {
    // Use progress-specific columns or fall back to regular columns
    final valueColumn = progressValueColumn ?? yColumn;
    final labelColumn = progressLabelColumn ?? xColumn;
    final categoryColumn = progressCategoryColumn ?? colorColumn;

    if (valueColumn == null || data.isEmpty) {
      return;
    }

    // Animation progress for progress bars
    final progressBarProgress = math.max(0.0, math.min(1.0, animationProgress));
    if (progressBarProgress <= 0.001) return;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final value = getNumericValue(point[valueColumn]);
      if (value == null || !value.isFinite) continue;

      // Calculate progress percentage (normalize between min and max)
      final minVal = geometry.minValue ?? 0.0;
      final maxVal = geometry.maxValue ?? 100.0;
      final normalizedValue = ((value - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);

      // Animation delay for each progress bar
      final barDelay = i / data.length * 0.3; // 30% stagger
      final barProgress = math.max(
        0.0,
        math.min(
          1.0,
          (progressBarProgress - barDelay) / math.max(0.001, 1.0 - barDelay),
        ),
      );

      if (barProgress <= 0) continue;

      // Draw progress bar based on orientation
      switch (geometry.orientation) {
        case ProgressOrientation.horizontal:
          _drawHorizontalProgressBar(
            canvas,
            plotArea,
            geometry,
            normalizedValue,
            barProgress,
            point,
            colorScale,
            categoryColumn,
            labelColumn,
            i,
          );
          break;
        case ProgressOrientation.vertical:
          _drawVerticalProgressBar(
            canvas,
            plotArea,
            geometry,
            normalizedValue,
            barProgress,
            point,
            colorScale,
            categoryColumn,
            labelColumn,
            i,
          );
          break;
        case ProgressOrientation.circular:
          _drawCircularProgressBar(
            canvas,
            plotArea,
            geometry,
            normalizedValue,
            barProgress,
            point,
            colorScale,
            categoryColumn,
            labelColumn,
            i,
          );
          break;
      }
    }
  }

  void _drawHorizontalProgressBar(
    Canvas canvas,
    Rect plotArea,
    ProgressGeometry geometry,
    double normalizedValue,
    double animationProgress,
    Map<String, dynamic> point,
    ColorScale colorScale,
    String? categoryColumn,
    String? labelColumn,
    int index,
  ) {
    // Calculate bar position and size
    final barHeight = geometry.thickness;
    final barSpacing = barHeight + 20.0; // Space between bars
    final barY = plotArea.top + (index * barSpacing) + 20.0;
    
    if (barY + barHeight > plotArea.bottom) return; // Don't draw if outside bounds

    final barWidth = plotArea.width * 0.8; // 80% of available width
    final barX = plotArea.left + (plotArea.width - barWidth) / 2; // Center horizontally

    final barRect = Rect.fromLTWH(barX, barY, barWidth, barHeight);

    // Draw background
    final backgroundPaint = Paint()
      ..color = geometry.backgroundColor ?? theme.gridColor.withAlpha(51)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(geometry.cornerRadius)),
      backgroundPaint,
    );

    // Draw progress fill with animation
    final fillWidth = barWidth * normalizedValue * animationProgress;
    final fillRect = Rect.fromLTWH(barX, barY, fillWidth, barHeight);

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Determine fill color/gradient
    Color fillColor = geometry.fillColor ?? 
        (categoryColumn != null ? colorScale.scale(point[categoryColumn]) : theme.primaryColor);

    if (geometry.fillGradient != null) {
      // Apply gradient with animation alpha
      final animatedGradient = _applyAlphaToGradient(geometry.fillGradient!, 1.0);
      fillPaint.shader = animatedGradient.createShader(fillRect);
    } else if (geometry.style == ProgressStyle.gradient) {
      // Default gradient from light to dark version of fill color
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          fillColor.withAlpha(127),
          fillColor,
        ],
      );
      fillPaint.shader = gradient.createShader(fillRect);
    } else {
      fillPaint.color = fillColor;
    }

    // Draw fill with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, Radius.circular(geometry.cornerRadius)),
      fillPaint,
    );

    // Draw stroke if specified
    if (geometry.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = geometry.strokeColor ?? theme.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.strokeWidth;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, Radius.circular(geometry.cornerRadius)),
        strokePaint,
      );
    }

    // Draw label if enabled
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        _drawProgressLabel(
          canvas,
          labelText,
          Offset(barX, barY - geometry.labelOffset),
          geometry.labelStyle ?? theme.axisTextStyle,
        );
      }
    }
  }

  void _drawVerticalProgressBar(
    Canvas canvas,
    Rect plotArea,
    ProgressGeometry geometry,
    double normalizedValue,
    double animationProgress,
    Map<String, dynamic> point,
    ColorScale colorScale,
    String? categoryColumn,
    String? labelColumn,
    int index,
  ) {
    // Calculate bar position and size
    final barWidth = geometry.thickness;
    final barSpacing = barWidth + 20.0;
    final barX = plotArea.left + (index * barSpacing) + 20.0;
    
    if (barX + barWidth > plotArea.right) return;

    final barHeight = plotArea.height * 0.8;
    final barY = plotArea.top + (plotArea.height - barHeight) / 2;

    final barRect = Rect.fromLTWH(barX, barY, barWidth, barHeight);

    // Draw background
    final backgroundPaint = Paint()
      ..color = geometry.backgroundColor ?? theme.gridColor.withAlpha(51)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(geometry.cornerRadius)),
      backgroundPaint,
    );

    // Draw progress fill from bottom up
    final fillHeight = barHeight * normalizedValue * animationProgress;
    final fillY = barY + barHeight - fillHeight; // Start from bottom
    final fillRect = Rect.fromLTWH(barX, fillY, barWidth, fillHeight);

    final fillPaint = Paint()..style = PaintingStyle.fill;

    Color fillColor = geometry.fillColor ?? 
        (categoryColumn != null ? colorScale.scale(point[categoryColumn]) : theme.primaryColor);

    if (geometry.fillGradient != null) {
      final animatedGradient = _applyAlphaToGradient(geometry.fillGradient!, 1.0);
      fillPaint.shader = animatedGradient.createShader(fillRect);
    } else if (geometry.style == ProgressStyle.gradient) {
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          fillColor.withAlpha(127),
          fillColor,
        ],
      );
      fillPaint.shader = gradient.createShader(fillRect);
    } else {
      fillPaint.color = fillColor;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, Radius.circular(geometry.cornerRadius)),
      fillPaint,
    );

    // Draw stroke
    if (geometry.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = geometry.strokeColor ?? theme.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.strokeWidth;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, Radius.circular(geometry.cornerRadius)),
        strokePaint,
      );
    }

    // Draw label
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        _drawProgressLabel(
          canvas,
          labelText,
          Offset(barX + barWidth / 2, barY + barHeight + geometry.labelOffset),
          geometry.labelStyle ?? theme.axisTextStyle,
        );
      }
    }
  }

  void _drawCircularProgressBar(
    Canvas canvas,
    Rect plotArea,
    ProgressGeometry geometry,
    double normalizedValue,
    double animationProgress,
    Map<String, dynamic> point,
    ColorScale colorScale,
    String? categoryColumn,
    String? labelColumn,
    int index,
  ) {
    // Calculate circle properties
    final radius = geometry.thickness;
    final centerSpacing = (radius * 2.5);
    final cols = (plotArea.width / centerSpacing).floor();
    final row = index ~/ cols;
    final col = index % cols;
    
    final centerX = plotArea.left + (col * centerSpacing) + centerSpacing / 2;
    final centerY = plotArea.top + (row * centerSpacing) + centerSpacing / 2;
    final center = Offset(centerX, centerY);

    if (centerY + radius > plotArea.bottom) return;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = geometry.backgroundColor ?? theme.gridColor.withAlpha(51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.2;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final sweepAngle = 2 * math.pi * normalizedValue * animationProgress;
    final startAngle = -math.pi / 2; // Start from top

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.2
      ..strokeCap = StrokeCap.round;

    Color fillColor = geometry.fillColor ?? 
        (categoryColumn != null ? colorScale.scale(point[categoryColumn]) : theme.primaryColor);
    progressPaint.color = fillColor;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw center label
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        _drawProgressLabel(
          canvas,
          labelText,
          Offset(center.dx, center.dy + radius + geometry.labelOffset),
          geometry.labelStyle ?? theme.axisTextStyle,
        );
      }
    }
  }

  void _drawProgressLabel(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    // Center the text at the position
    final offset = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
