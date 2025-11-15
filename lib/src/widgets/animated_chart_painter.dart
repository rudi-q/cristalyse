import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/geometry_calculator.dart';
import '../core/render_models.dart';
import '../core/scale.dart';
import '../core/util/helper.dart';
import '../themes/chart_theme.dart';

/// Custom painter with animation support
class AnimatedChartPainter extends CustomPainter {
  // Spacing constants for axis label and title positioning
  static const double _tickToLabelSpacing = 4.0;
  static const double _labelToTitleSpacing = 8.0;

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
        .map(
          (color) => color.withAlpha(
            (((color.a * 255.0).round() & 0xff) * clampedAlpha).round(),
          ),
        )
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
    final hasSecondaryY = hasSecondaryYAxis(
      y2Column: y2Column,
      geometries: geometries,
    );

    // Pre-calculate maximum label dimensions for title spacing
    final axisLabelStyle = theme.axisLabelStyle ??
        const TextStyle(color: Colors.black, fontSize: 12);
    final labelDimensions = _calculateMaxLabelDimensions(
      xScale: this.xScale,
      yScale: this.yScale,
      y2Scale: this.y2Scale,
      style: axisLabelStyle,
    );

    // Calculate title font size for dimension calculations
    final titleFontSize = (axisLabelStyle.fontSize ?? 12) + 1;

    // Calculate additional padding for axis titles and labels
    // Space for Y-axis labels + optional title (title height becomes width after -90° rotation)
    final yAxisSpace = this.yScale != null
        ? theme.axisWidth * 2 + // tick marks
            _tickToLabelSpacing + // gap to labels
            labelDimensions.maxYLabelWidth + // labels
            (this.yScale?.title != null
                ? _labelToTitleSpacing + titleFontSize // gap + title height
                : 0.0)
        : 0.0;
    final leftPadding = theme.padding.left + yAxisSpace;

    // Space for Y2-axis labels + optional title (title height becomes width after +90° rotation)
    final y2AxisSpace = this.y2Scale != null
        ? theme.axisWidth * 2 +
            _tickToLabelSpacing +
            labelDimensions.maxY2LabelWidth +
            (this.y2Scale?.title != null
                ? _labelToTitleSpacing + titleFontSize // gap + title height
                : 0.0)
        : 0.0;
    final rightPadding = theme.padding.right + y2AxisSpace;

    // Space for X-axis labels + optional title (not rotated, height is vertical)
    final xAxisSpace = this.xScale != null
        ? theme.axisWidth * 2 +
            _tickToLabelSpacing +
            labelDimensions.maxXLabelHeight +
            (this.xScale?.title != null
                ? _labelToTitleSpacing + titleFontSize // gap + title height
                : 0.0)
        : 0.0;
    final bottomPadding = theme.padding.bottom + xAxisSpace;

    final plotArea = Rect.fromLTWH(
      leftPadding,
      theme.padding.top,
      size.width - leftPadding - rightPadding,
      size.height - theme.padding.top - bottomPadding,
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
    final gradientColorScale = _setupGradientColorScale();

    final hasPieChart = geometries.any((g) => g is PieGeometry);
    final hasHeatMapChart = geometries.any((g) => g is HeatMapGeometry);
    final hasProgressChart = geometries.any((g) => g is ProgressGeometry);

    _drawBackground(canvas, plotArea);

    // Skip grid and axes for pie charts, heatmaps, and progress bars
    // Force disable for progress charts
    final shouldSkipGridAndAxes =
        hasPieChart || hasHeatMapChart || hasProgressChart;
    if (!shouldSkipGridAndAxes) {
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
        gradientColorScale,
      );
    }

    // Restore canvas state to draw axes outside clipped area
    canvas.restore();

    // Skip axes for pie charts, heatmaps, and progress bars
    // Use the same shouldSkipGridAndAxes variable for consistency
    if (!shouldSkipGridAndAxes) {
      _drawAxes(
        canvas,
        size,
        plotArea,
        xScale,
        yScale,
        y2Scale,
        labelDimensions,
      );
    } else if (hasHeatMapChart && !hasProgressChart) {
      // Only draw heat map axes if it's not a progress chart
      _drawHeatMapAxes(canvas, size, plotArea);
    }
  }

  Scale _setupXScale(double width, bool hasBarGeometry) {
    if (coordFlipped) {
      final preconfigured = yScale;
      final scale =
          (preconfigured is LinearScale ? preconfigured : LinearScale());
      final dataCol = yColumn;

      scale.range = [
        0,
        width,
      ]; // Set range BEFORE setBounds for correct Wilkinson computation

      if (dataCol == null || data.isEmpty) {
        scale.setBounds([], null, geometries);
        return scale;
      }

      final values = data
          .map((d) => getNumericValue(d[dataCol]))
          .where((v) => v != null && v.isFinite)
          .cast<double>()
          .toList();

      if (values.isNotEmpty) {
        scale.setBounds(values, null, geometries);
      } else {
        scale.setBounds([], null, geometries);
      }
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
        scale.range = [
          0,
          width,
        ]; // Set range BEFORE setBounds for correct Wilkinson computation

        if (dataCol == null || data.isEmpty) {
          scale.setBounds([], null, geometries);
          return scale;
        }
        final values = data
            .map((d) => getNumericValue(d[dataCol]))
            .where((v) => v != null && v.isFinite)
            .cast<double>()
            .toList();

        if (values.isNotEmpty) {
          // Use setBounds for consistent bounds calculation
          scale.setBounds(values, null, geometries);

          // Use pan domain if available (for visual panning)
          if (!coordFlipped && panXDomain != null) {
            scale.setBounds(
                values,
                (
                  panXDomain![0],
                  panXDomain![1],
                ),
                geometries);
          }
        } else {
          scale.setBounds([], null, geometries);
        }
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
      scale.range = [
        height,
        0,
      ]; // Set range BEFORE setBounds for correct Wilkinson computation

      if (dataCol == null || data.isEmpty) {
        scale.setBounds([], null, geometries);
        return scale;
      }

      final relevantGeometries =
          geometries.where((g) => g.yAxis == axis).toList();
      if (relevantGeometries.isEmpty) {
        scale.setBounds([0, 1], null, geometries);
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
        // Use setBounds for consistent bounds calculation
        // Wilkinson algorithm provides visual padding
        scale.setBounds(values, null, geometries);

        // Use pan domain if available (for visual panning)
        if (!coordFlipped && axis == YAxis.primary && panYDomain != null) {
          scale.setBounds(values, (panYDomain![0], panYDomain![1]), geometries);
        }
      } else {
        scale.setBounds([], null, geometries);
      }
      return scale;
    }
  }

  ColorScale _setupColorScale() {
    // If a colorScale was provided (e.g., for interactive legends with filtering),
    // use it to preserve color-to-category mapping
    if (colorScale != null) {
      return colorScale!;
    }

    // Otherwise, create a new ColorScale from the data
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

  GradientColorScale _setupGradientColorScale() {
    // Find heat map geometry if present
    HeatMapGeometry? heatMapGeom;
    for (final geom in geometries) {
      if (geom is HeatMapGeometry) {
        heatMapGeom = geom;
        break;
      }
    }

    // If no heat map configured, return default scale without scanning data
    if (heatMapGeom == null) {
      return GradientColorScale.heatMap();
    }

    // Create gradient color scale based on heat map configuration
    GradientColorScale scale;

    if (heatMapGeom.colorGradient != null &&
        heatMapGeom.colorGradient!.isNotEmpty) {
      // Use custom gradient from geometry
      scale = GradientColorScale(
        colors: heatMapGeom.colorGradient!,
        interpolate: heatMapGeom.interpolateColors,
      );
    } else {
      // Use default heat map gradient
      scale = GradientColorScale.heatMap();
    }

    // Validate heat map value column requirement
    if (heatMapValueColumn == null) {
      throw ArgumentError(
        'Heat maps require a value column for color mapping. '
        'Use .mappingHeatMap(x: "xCol", y: "yCol", value: "valueCol") '
        'instead of .mapping() when creating heat maps.',
      );
    }

    // Set domain using Scale's setBounds()
    if (data.isNotEmpty) {
      final values = data
          .map((d) => getNumericValue(d[heatMapValueColumn]))
          .where((v) => v != null && v.isFinite)
          .cast<double>()
          .toList();

      scale.setBounds(
          values,
          (
            heatMapGeom.minValue,
            heatMapGeom.maxValue,
          ),
          geometries);
    }

    return scale;
  }

  SizeScale _setupSizeScale() {
    if (sizeColumn == null) return SizeScale();
    final values = data
        .map((d) => getNumericValue(d[sizeColumn]))
        .where((v) => v != null)
        .cast<double>()
        .toList();
    if (values.isNotEmpty) {
      // Get bubble geometry and use its preconfigured size scale
      final bubbleGeometries = geometries.whereType<BubbleGeometry>().toList();
      final effectiveSizeScale = bubbleGeometries.isNotEmpty
          ? bubbleGeometries.first.createSizeScale()
          : (sizeScale ??
              SizeScale(range: [theme.pointSizeMin, theme.pointSizeMax]));

      // Set domain from data - limits are already in the scale
      effectiveSizeScale.setBounds(values, null, geometries);
      return effectiveSizeScale;
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
    final xTicks = xScale.getTicks();
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
    final yTicks = yScale.getTicks();
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
    GradientColorScale gradientColorScale,
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
      _drawPieAnimated(canvas, plotArea, geometry, colorScale);
    } else if (geometry is HeatMapGeometry) {
      _drawHeatMapAnimated(canvas, plotArea, geometry, gradientColorScale);
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
    // Use GeometryCalculator to get all bar geometries
    final calculator = GeometryCalculator(
      data: data,
      xColumn: xColumn,
      yColumn: yColumn,
      colorColumn: colorColumn,
      sizeColumn: sizeColumn,
      theme: theme,
      coordFlipped: coordFlipped,
    );

    final bars = calculator.calculateSimpleBars(
      geometry,
      xScale,
      yScale,
      colorScale,
      plotArea,
      yCol,
    );

    // Apply animation and render each bar
    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];

      final barDelay = bars.isNotEmpty ? i / bars.length * 0.2 : 0.0;
      final barProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - barDelay) / math.max(0.001, 1.0 - barDelay),
        ),
      );

      if (barProgress <= 0) continue;

      // Apply animation to bar height/width
      final animatedBar = _applyBarAnimation(bar, barProgress);

      // Render the bar
      _renderBar(canvas, animatedBar);
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
    // Use GeometryCalculator to get all bar geometries
    final calculator = GeometryCalculator(
      data: data,
      xColumn: xColumn,
      yColumn: yColumn,
      colorColumn: colorColumn,
      sizeColumn: sizeColumn,
      theme: theme,
      coordFlipped: coordFlipped,
    );

    final bars = calculator.calculateGroupedBars(
      geometry,
      xScale,
      yScale,
      colorScale,
      plotArea,
      yCol,
    );

    // Group bars by X value to calculate group-based animation delays
    final barsByX = <dynamic, List<BarRenderData>>{};
    for (final bar in bars) {
      final x = bar.dataPoint[xColumn];
      barsByX.putIfAbsent(x, () => []).add(bar);
    }

    int groupIndex = 0;
    for (final groupBars in barsByX.values) {
      final groupDelay =
          barsByX.isNotEmpty ? groupIndex / barsByX.length * 0.2 : 0.0;
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

      // Render all bars in this group with the same animation progress
      for (final bar in groupBars) {
        final animatedBar = _applyBarAnimation(bar, groupProgress);
        _renderBar(canvas, animatedBar);
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
    // For stacked bars, animation is more complex - we need to animate
    // each segment's VALUE (not just the final rect), so we can't use
    // the calculator for the full stack. Instead, we calculate and render
    // each segment with its animated value.
    final calculator = GeometryCalculator(
      data: data,
      xColumn: xColumn,
      yColumn: yColumn,
      colorColumn: colorColumn,
      sizeColumn: sizeColumn,
      theme: theme,
      coordFlipped: coordFlipped,
    );

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

        // Calculate bar with animated Y value
        final bar = calculator.calculateSingleBar(
          x,
          y * segmentProgress,
          xScale,
          yScale,
          colorScale,
          geometry,
          point,
          plotArea,
          yStackOffset: cumulativeValue,
        );

        if (bar != null) {
          _renderBar(canvas, bar); // No additional animation - it's in the Y value
        }

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
      final alphaGradient = _applyAlphaToGradient(
        colorOrGradient,
        geometry.alpha,
      );
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

  /// Applies animation to a bar by scaling its height/width.
  ///
  /// For vertical bars: animates height from bottom up
  /// For horizontal bars: animates width from left to right
  BarRenderData _applyBarAnimation(BarRenderData bar, double progress) {
    if (coordFlipped) {
      // Horizontal bar: animate width from left
      final animatedWidth = bar.rect.width * progress;
      return bar.copyWith(
        rect: Rect.fromLTWH(
          bar.rect.left,
          bar.rect.top,
          animatedWidth,
          bar.rect.height,
        ),
      );
    } else {
      // Vertical bar: animate height from bottom
      final animatedHeight = bar.rect.height * progress;
      final yOffset = bar.rect.height * (1 - progress);
      return bar.copyWith(
        rect: Rect.fromLTWH(
          bar.rect.left,
          bar.rect.top + yOffset,
          bar.rect.width,
          animatedHeight,
        ),
      );
    }
  }

  /// Renders a bar to the canvas using its RenderData.
  ///
  /// Handles gradients, solid colors, borders, and border radius.
  void _renderBar(Canvas canvas, BarRenderData bar) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Apply gradient or solid color based on what we received
    if (bar.colorOrGradient is Gradient) {
      final alphaGradient = _applyAlphaToGradient(
        bar.colorOrGradient,
        bar.alpha,
      );
      paint.shader = alphaGradient.createShader(bar.rect);
    } else {
      final color = bar.colorOrGradient as Color;
      paint.color = color.withAlpha((bar.alpha * 255).round());
    }

    if (bar.borderRadius != null && bar.borderRadius != BorderRadius.zero) {
      canvas.drawRRect(bar.borderRadius!.toRRect(bar.rect), paint);
    } else {
      canvas.drawRect(bar.rect, paint);
    }

    if (bar.borderWidth > 0 && bar.borderColor != null) {
      final borderPaint = Paint()
        ..color = bar.borderColor!.withAlpha((bar.alpha * 255).round())
        ..strokeWidth = bar.borderWidth
        ..style = PaintingStyle.stroke;

      if (bar.borderRadius != null && bar.borderRadius != BorderRadius.zero) {
        canvas.drawRRect(bar.borderRadius!.toRRect(bar.rect), borderPaint);
      } else {
        canvas.drawRect(bar.rect, borderPaint);
      }
    }
  }

  /// Renders a line to the canvas using its RenderData.
  ///
  /// Handles progressive animation (drawing segment by segment).
  void _renderLine(Canvas canvas, LineRenderData line) {
    final lineProgress = math.max(0.0, math.min(1.0, animationProgress));
    if (lineProgress <= 0.001 || line.points.length < 2) {
      return;
    }

    final paint = Paint()
      ..color = line.color.withAlpha((line.alpha * 255).round())
      ..strokeWidth = line.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final int numSegments = line.points.length - 1;

    final double totalProgressiveSegments = numSegments * lineProgress;
    final int fullyDrawnSegments = totalProgressiveSegments.floor();
    final double partialSegmentProgress =
        totalProgressiveSegments - fullyDrawnSegments;

    path.moveTo(line.points[0].dx, line.points[0].dy);

    for (int i = 0; i < fullyDrawnSegments; i++) {
      path.lineTo(line.points[i + 1].dx, line.points[i + 1].dy);
    }

    if (partialSegmentProgress > 0.001 && fullyDrawnSegments < numSegments) {
      final Offset lastFullPoint = line.points[fullyDrawnSegments];
      final Offset nextPoint = line.points[fullyDrawnSegments + 1];

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

  /// Renders a point to the canvas using its RenderData.
  ///
  /// Handles different point shapes (circle, square, triangle) and borders.
  void _renderPoint(Canvas canvas, PointRenderData point, double progress) {
    final animatedSize = point.size * progress;
    final animatedAlpha = point.alpha * progress;

    final paint = Paint()..style = PaintingStyle.fill;

    // Apply gradient or solid color based on what we received
    if (point.colorOrGradient is Gradient) {
      // For points, create a square shader area around the point
      final shaderRect = Rect.fromCenter(
        center: point.position,
        width: point.size * 2,
        height: point.size * 2,
      );
      final alphaGradient = _applyAlphaToGradient(
        point.colorOrGradient,
        animatedAlpha,
      );
      paint.shader = alphaGradient.createShader(shaderRect);
    } else {
      final color = point.colorOrGradient as Color;
      paint.color = color.withAlpha((animatedAlpha * 255).round());
    }

    // Draw the point shape
    if (point.shape == PointShape.circle) {
      canvas.drawCircle(point.position, animatedSize, paint);
    } else if (point.shape == PointShape.square) {
      canvas.drawRect(
        Rect.fromCenter(
          center: point.position,
          width: animatedSize,
          height: animatedSize,
        ),
        paint,
      );
    } else if (point.shape == PointShape.triangle) {
      final path = Path();
      path.moveTo(point.position.dx, point.position.dy - animatedSize);
      path.lineTo(
        point.position.dx - animatedSize,
        point.position.dy + animatedSize,
      );
      path.lineTo(
        point.position.dx + animatedSize,
        point.position.dy + animatedSize,
      );
      path.close();
      canvas.drawPath(path, paint);
    }

    // Draw border if needed
    if (point.borderWidth > 0 && point.borderColor != null) {
      final borderPaint = Paint()
        ..color = point.borderColor!.withAlpha((animatedAlpha * 255).round())
        ..strokeWidth = point.borderWidth
        ..style = PaintingStyle.stroke;

      if (point.shape == PointShape.circle) {
        canvas.drawCircle(point.position, animatedSize, borderPaint);
      } else if (point.shape == PointShape.square) {
        canvas.drawRect(
          Rect.fromCenter(
            center: point.position,
            width: animatedSize,
            height: animatedSize,
          ),
          borderPaint,
        );
      } else if (point.shape == PointShape.triangle) {
        final path = Path();
        path.moveTo(point.position.dx, point.position.dy - animatedSize);
        path.lineTo(
          point.position.dx - animatedSize,
          point.position.dy + animatedSize,
        );
        path.lineTo(
          point.position.dx + animatedSize,
          point.position.dy + animatedSize,
        );
        path.close();
        canvas.drawPath(path, borderPaint);
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

    // Use GeometryCalculator to get all point geometries
    final calculator = GeometryCalculator(
      data: data,
      xColumn: xColumn,
      yColumn: yColumn,
      colorColumn: colorColumn,
      sizeColumn: sizeColumn,
      theme: theme,
      coordFlipped: coordFlipped,
    );

    final points = calculator.calculatePoints(
      geometry,
      xScale,
      yScale,
      colorScale,
      sizeScale,
      plotArea,
      yCol,
    );

    // Apply animation and render each point
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      final pointDelay = points.isNotEmpty ? i / points.length * 0.2 : 0.0;
      final pointProgress = math.max(
        0.0,
        math.min(
          1.0,
          (animationProgress - pointDelay) / math.max(0.001, 1.0 - pointDelay),
        ),
      );

      if (pointProgress <= 0) continue;

      // Render the point with animation
      _renderPoint(canvas, point, pointProgress);
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
        canvas.drawCircle(Offset(pointX, pointY), animatedSize, paint);
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
        path.lineTo(pointX - animatedSize, pointY + animatedSize);
        path.lineTo(pointX + animatedSize, pointY + animatedSize);
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
          canvas.drawCircle(Offset(pointX, pointY), animatedSize, borderPaint);
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
          path.lineTo(pointX - animatedSize, pointY + animatedSize);
          path.lineTo(pointX + animatedSize, pointY + animatedSize);
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
              color: textStyle.color?.withAlpha((255 * bubbleProgress).round()),
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
          ..color = Colors.white.withValues(alpha: 0.8 * bubbleProgress)
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

    // Use GeometryCalculator to get all line geometries
    final calculator = GeometryCalculator(
      data: data,
      xColumn: xColumn,
      yColumn: yColumn,
      colorColumn: colorColumn,
      sizeColumn: sizeColumn,
      theme: theme,
      coordFlipped: coordFlipped,
    );

    final lines = calculator.calculateLines(
      geometry,
      xScale,
      yScale,
      colorScale,
      plotArea,
      yCol,
    );

    // Render each line with animation
    for (final line in lines) {
      _renderLine(canvas, line);
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
    _LabelDimensions labelDimensions,
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

    // Calculate tick outer edges for consistent label positioning
    final xTickOuterEdge = plotArea.bottom + theme.axisWidth * 2;
    final yTickOuterEdge = plotArea.left - theme.axisWidth * 2;
    final y2TickOuterEdge = plotArea.right + theme.axisWidth * 2;

    // Use pre-calculated max label dimensions
    final maxXLabelHeight = labelDimensions.maxXLabelHeight;
    final maxYLabelWidth = labelDimensions.maxYLabelWidth;
    final maxY2LabelWidth = labelDimensions.maxY2LabelWidth;

    // X-axis labels
    final xTicks = xScale.getTicks();
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
          xTickOuterEdge + _tickToLabelSpacing,
        ),
      );
    }

    // Primary Y-axis labels (left)
    final yTicks = yScale.getTicks();
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
          yTickOuterEdge - _tickToLabelSpacing - textPainter.width,
          pos - textPainter.height / 2,
        ),
      );
    }

    // Secondary Y-axis labels (right)
    if (y2Scale != null) {
      final y2Ticks = y2Scale.getTicks();
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
            y2TickOuterEdge + _tickToLabelSpacing,
            pos - textPainter.height / 2,
          ),
        );
      }
    }

    // Calculate label alignment positions (where label edges meet tick spacing)
    final xLabelAlignEdge =
        xTickOuterEdge + _tickToLabelSpacing; // Top edge of X labels
    final yLabelAlignEdge =
        yTickOuterEdge - _tickToLabelSpacing; // Right edge of Y labels
    final y2LabelAlignEdge =
        y2TickOuterEdge + _tickToLabelSpacing; // Left edge of Y2 labels

    // Calculate label outer edges using alignment position and max dimensions
    final xLabelOuterEdge = xLabelAlignEdge + maxXLabelHeight; // Bottom edge
    final yLabelOuterEdge = yLabelAlignEdge - maxYLabelWidth; // Left edge
    final y2LabelOuterEdge = y2LabelAlignEdge + maxY2LabelWidth; // Right edge

    // Draw axis titles with calculated label dimensions
    _drawAxisTitles(
      canvas,
      plotArea,
      xScale,
      yScale,
      y2Scale,
      axisLabelStyle,
      xLabelOuterEdge,
      yLabelOuterEdge,
      y2LabelOuterEdge,
      _labelToTitleSpacing,
    );
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
    final innerRadius = math.min(
      geometry.innerRadius,
      outerRadius * 0.8,
    ); // Ensure inner radius isn't too close to outer

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
    GradientColorScale gradientColorScale,
  ) {
    // Use heat map specific columns
    final xCol = heatMapXColumn ?? xColumn;
    final yCol = heatMapYColumn ?? yColumn;
    final valueCol = heatMapValueColumn;

    if (valueCol == null) {
      throw ArgumentError(
        'Heat maps require heatMapValueColumn. '
        'Use .mappingHeatMap(x: "xCol", y: "yCol", value: "valueCol").',
      );
    }

    if (xCol == null || yCol == null || data.isEmpty) {
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

        // Calculate color using GradientColorScale
        final cellColor = gradientColorScale.scale(value);

        // Calculate normalized value for text color logic
        final normalizedValue = gradientColorScale.normalize(value);

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
              TextStyle(color: textColor, fontSize: 10);

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
    final valueCol = heatMapValueColumn;

    if (valueCol == null) {
      throw ArgumentError(
        'Heat maps require heatMapValueColumn. '
        'Use .mappingHeatMap(x: "xCol", y: "yCol", value: "valueCol").',
      );
    }

    if (xCol == null || yCol == null || data.isEmpty) {
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
        Offset(centerX - textPainter.width / 2, plotArea.bottom + 8),
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

  /// Draw axis titles for X, Y, and Y2 axes
  void _drawAxisTitles(
    Canvas canvas,
    Rect plotArea,
    Scale? xScale,
    Scale? yScale,
    Scale? y2Scale,
    TextStyle axisLabelStyle,
    double xLabelOuterEdge,
    double yLabelOuterEdge,
    double y2LabelOuterEdge,
    double labelToTitleSpacing,
  ) {
    final titleStyle = axisLabelStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: (axisLabelStyle.fontSize ?? 12) + 1,
    );

    // Draw X-axis title (horizontal, centered below tick labels)
    if (xScale?.title != null) {
      final xTitle = xScale!.title!;

      final textPainter = TextPainter(
        text: TextSpan(text: xTitle, style: titleStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();

      // Position below tick labels, using calculated label outer edge
      textPainter.paint(
        canvas,
        Offset(
          plotArea.left + (plotArea.width - textPainter.width) / 2,
          xLabelOuterEdge + labelToTitleSpacing,
        ),
      );
    }

    // Draw Y-axis title (vertical, rotated 90° counter-clockwise)
    if (yScale?.title != null) {
      final yTitle = yScale!.title!;

      final textPainter = TextPainter(
        text: TextSpan(text: yTitle, style: titleStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      // Position to the left of tick labels, accounting for title height after rotation
      // After -90° rotation, title extends LEFT by its height from translate point
      canvas.translate(
        yLabelOuterEdge - labelToTitleSpacing - textPainter.height,
        plotArea.top + (plotArea.height + textPainter.width) / 2,
      );
      canvas.rotate(-math.pi / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Draw Y2-axis title (vertical, rotated 90° clockwise)
    if (y2Scale?.title != null) {
      final y2Title = y2Scale!.title!;

      final y2TitleStyle = titleStyle.copyWith(
        color: theme.colorPalette.length > 1
            ? theme.colorPalette[1]
            : theme.axisColor,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: y2Title, style: y2TitleStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      // Position to the right of tick labels, accounting for title height after rotation
      // After +90° rotation, title extends RIGHT by its height from translate point
      canvas.translate(
        y2LabelOuterEdge + labelToTitleSpacing + textPainter.height,
        plotArea.top + (plotArea.height - textPainter.width) / 2,
      );
      canvas.rotate(math.pi / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
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
      final range = maxVal - minVal;
      final double normalizedValue;
      if (range <= 0.0 || !range.isFinite) {
        // Fallback for invalid range: treat as 50% complete
        normalizedValue = 0.5;
      } else {
        normalizedValue = ((value - minVal) / range).clamp(0.0, 1.0);
      }

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

      // Draw progress bar based on style first, then orientation
      switch (geometry.style) {
        case ProgressStyle.stacked:
          _drawStackedProgressBar(
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
        case ProgressStyle.grouped:
          _drawGroupedProgressBar(
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
        case ProgressStyle.gauge:
          _drawGaugeProgressBar(
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
        case ProgressStyle.concentric:
          _drawConcentricProgressBar(
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
        default:
          // Handle basic styles with existing orientation logic
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
    // Calculate bar position and size with dynamic spacing
    final barHeight = geometry.thickness;
    final barSpacing = math.max(barHeight * 0.3, 8.0); // Dynamic spacing
    final totalHeight = data.length * (barHeight + barSpacing);

    // Scale down bars if they don't fit
    final scaleFactor =
        totalHeight > plotArea.height ? plotArea.height / totalHeight : 1.0;
    final adjustedBarHeight = barHeight * scaleFactor;
    final adjustedSpacing = barSpacing * scaleFactor;

    final barY = plotArea.top +
        (index * (adjustedBarHeight + adjustedSpacing)) +
        adjustedSpacing;

    if (barY + adjustedBarHeight > plotArea.bottom) {
      return; // Don't draw if outside bounds
    }

    final barWidth = plotArea.width * 0.8; // 80% of available width
    final barX =
        plotArea.left + (plotArea.width - barWidth) / 2; // Center horizontally

    final barRect = Rect.fromLTWH(barX, barY, barWidth, adjustedBarHeight);

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
    final fillRect = Rect.fromLTWH(barX, barY, fillWidth, adjustedBarHeight);

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Determine fill color from geometry or theme palette
    // Priority: explicit fillColor > theme palette by index (always use theme for responsiveness)
    final fillColor = geometry.fillColor ??
        theme.colorPalette[index % theme.colorPalette.length];

    if (geometry.fillGradient != null) {
      // Explicit gradient takes precedence
      final animatedGradient = _applyAlphaToGradient(
        geometry.fillGradient!,
        1.0,
      );
      fillPaint.shader = animatedGradient.createShader(fillRect);
    } else if (geometry.style == ProgressStyle.gradient) {
      // Default gradient from light to dark version of fill color
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [fillColor.withAlpha(127), fillColor],
      );
      fillPaint.shader = gradient.createShader(fillRect);
    } else if (geometry.style == ProgressStyle.striped) {
      // Striped pattern
      fillPaint.color = fillColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          fillRect,
          Radius.circular(geometry.cornerRadius),
        ),
        fillPaint,
      );
      // Draw diagonal stripes
      _drawStripes(canvas, fillRect, fillColor, geometry.cornerRadius);
      // Return early to avoid double-drawing
      _drawProgressBarStroke(canvas, barRect, geometry);
      _drawProgressBarLabel(
        canvas,
        barRect,
        point,
        labelColumn,
        geometry,
        adjustedBarHeight,
        true,
      );
      return;
    } else {
      // Solid color
      fillPaint.color = fillColor;
    }

    // Draw fill with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, Radius.circular(geometry.cornerRadius)),
      fillPaint,
    );

    // Draw stroke if specified
    _drawProgressBarStroke(canvas, barRect, geometry);

    // Draw label if enabled - positioned to the left of the bar
    _drawProgressBarLabel(
      canvas,
      barRect,
      point,
      labelColumn,
      geometry,
      adjustedBarHeight,
      true,
    );
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
    // Calculate bar position and size with dynamic spacing
    final barWidth = geometry.thickness;

    // Add extra spacing for labels if they're enabled
    final labelSpace = geometry.showLabel && labelColumn != null ? 40.0 : 0.0;
    final minSpacing =
        20.0 + labelSpace; // Minimum spacing between bars plus label space
    final barSpacing = math.max(barWidth * 0.8, minSpacing);
    final totalWidth = data.length * (barWidth + barSpacing);

    // Scale down bars if they don't fit, but maintain minimum spacing
    final scaleFactor =
        totalWidth > plotArea.width ? plotArea.width / totalWidth : 1.0;
    final adjustedBarWidth = barWidth * scaleFactor;
    final adjustedSpacing = math.max(
      barSpacing * scaleFactor,
      minSpacing * 0.5,
    );

    final barX = plotArea.left +
        (index * (adjustedBarWidth + adjustedSpacing)) +
        adjustedSpacing;

    if (barX + adjustedBarWidth > plotArea.right) return;

    final barHeight = plotArea.height * 0.8;
    final barY = plotArea.top + (plotArea.height - barHeight) / 2;

    final barRect = Rect.fromLTWH(barX, barY, adjustedBarWidth, barHeight);

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
    final fillRect = Rect.fromLTWH(barX, fillY, adjustedBarWidth, fillHeight);

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Determine fill color from geometry or theme palette
    // Priority: explicit fillColor > theme palette by index (always use theme for responsiveness)
    final fillColor = geometry.fillColor ??
        theme.colorPalette[index % theme.colorPalette.length];

    if (geometry.fillGradient != null) {
      // Explicit gradient takes precedence
      final animatedGradient = _applyAlphaToGradient(
        geometry.fillGradient!,
        1.0,
      );
      fillPaint.shader = animatedGradient.createShader(fillRect);
    } else if (geometry.style == ProgressStyle.gradient) {
      // Default gradient from light to dark version of fill color
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [fillColor.withAlpha(127), fillColor],
      );
      fillPaint.shader = gradient.createShader(fillRect);
    } else if (geometry.style == ProgressStyle.striped) {
      // Striped pattern
      fillPaint.color = fillColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          fillRect,
          Radius.circular(geometry.cornerRadius),
        ),
        fillPaint,
      );
      // Draw diagonal stripes
      _drawStripes(canvas, fillRect, fillColor, geometry.cornerRadius);
      // Return early to avoid double-drawing
      _drawProgressBarStroke(canvas, barRect, geometry);
      _drawProgressBarLabel(
        canvas,
        barRect,
        point,
        labelColumn,
        geometry,
        adjustedBarWidth,
        false,
      );
      return;
    } else {
      // Solid color
      fillPaint.color = fillColor;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, Radius.circular(geometry.cornerRadius)),
      fillPaint,
    );

    // Draw stroke
    _drawProgressBarStroke(canvas, barRect, geometry);

    // Draw label if enabled - positioned below the bar
    _drawProgressBarLabel(
      canvas,
      barRect,
      point,
      labelColumn,
      geometry,
      adjustedBarWidth,
      false,
    );
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
    // Calculate circle properties with proper spacing for labels
    final radius = geometry.thickness;
    final labelSpace = geometry.showLabel && labelColumn != null ? 35.0 : 10.0;
    final minSpacing = 20.0; // Minimum gap between circles
    final centerSpacing = math.max(
      (radius * 2.0) + minSpacing + labelSpace,
      radius * 3.0,
    );

    final cols = math.max(1, (plotArea.width / centerSpacing).floor());
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

    // Priority: explicit fillColor > theme palette by index (always use theme for responsiveness)
    Color fillColor = geometry.fillColor ??
        theme.colorPalette[index % theme.colorPalette.length];
    progressPaint.color = fillColor;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw label if enabled - positioned below the circular progress
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: geometry.labelStyle ?? theme.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();

        final position = Offset(
          center.dx - textPainter.width / 2,
          center.dy + radius + 10.0,
        );
        textPainter.paint(canvas, position);
      }
    }
  }

  /// Helper method to draw stripes for striped progress bars
  void _drawStripes(
    Canvas canvas,
    Rect rect,
    Color baseColor,
    double cornerRadius,
  ) {
    // Create a darker color for stripes
    final stripeColor = Color.fromARGB(
      ((baseColor.a * 255.0).round() * 0.5).round(),
      (baseColor.r * 255.0).round(),
      (baseColor.g * 255.0).round(),
      (baseColor.b * 255.0).round(),
    );

    final stripePaint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;

    // Draw diagonal stripes
    final stripeWidth = 8.0;
    final stripeSpacing = 12.0;

    // Save canvas state for clipping
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
    );

    // Draw stripes at 45-degree angle
    for (double x = rect.left - rect.height;
        x < rect.right + rect.height;
        x += stripeSpacing) {
      final path = Path()
        ..moveTo(x, rect.top)
        ..lineTo(x + stripeWidth, rect.top)
        ..lineTo(x + stripeWidth + rect.height, rect.bottom)
        ..lineTo(x + rect.height, rect.bottom)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    canvas.restore();
  }

  /// Helper method to draw stroke for progress bars
  void _drawProgressBarStroke(
    Canvas canvas,
    Rect barRect,
    ProgressGeometry geometry,
  ) {
    if (geometry.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = geometry.strokeColor ?? theme.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.strokeWidth;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          barRect,
          Radius.circular(geometry.cornerRadius),
        ),
        strokePaint,
      );
    }
  }

  /// Helper method to draw label for progress bars
  void _drawProgressBarLabel(
    Canvas canvas,
    Rect barRect,
    Map<String, dynamic> point,
    String? labelColumn,
    ProgressGeometry geometry,
    double barSize,
    bool isHorizontal,
  ) {
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: geometry.labelStyle ?? theme.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: isHorizontal ? TextAlign.right : TextAlign.center,
        );
        textPainter.layout();

        final Offset position;
        if (isHorizontal) {
          // Position label to the LEFT of the bar, right-aligned
          final labelOffset = 8.0;
          position = Offset(
            barRect.left - labelOffset - textPainter.width,
            barRect.top + (barSize - textPainter.height) / 2,
          );
        } else {
          // Position label BELOW the bar, centered
          final labelOffset = 8.0;
          position = Offset(
            barRect.left + (barSize - textPainter.width) / 2,
            barRect.bottom + labelOffset,
          );
        }

        textPainter.paint(canvas, position);
      }
    }
  }

  /// Draw stacked progress bar with multiple segments
  void _drawStackedProgressBar(
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
    final segments = geometry.segments ?? [normalizedValue];
    final segmentColors = geometry.segmentColors ?? [];

    // Calculate bar dimensions based on orientation
    final isHorizontal = geometry.orientation == ProgressOrientation.horizontal;
    final barThickness = geometry.thickness;
    final barSpacing = barThickness + 20.0;

    late Rect barRect;
    if (isHorizontal) {
      final barY = plotArea.top + (index * barSpacing) + 20.0;
      if (barY + barThickness > plotArea.bottom) return;
      final barWidth = plotArea.width * 0.8;
      final barX = plotArea.left + (plotArea.width - barWidth) / 2;
      barRect = Rect.fromLTWH(barX, barY, barWidth, barThickness);
    } else {
      final barX = plotArea.left + (index * barSpacing) + 20.0;
      if (barX + barThickness > plotArea.right) return;
      final barHeight = plotArea.height * 0.8;
      final barY = plotArea.top + (plotArea.height - barHeight) / 2;
      barRect = Rect.fromLTWH(barX, barY, barThickness, barHeight);
    }

    // Draw background
    final backgroundPaint = Paint()
      ..color = geometry.backgroundColor ?? theme.gridColor.withAlpha(51)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(geometry.cornerRadius)),
      backgroundPaint,
    );

    // Draw each segment
    double currentPosition = 0.0;
    final totalValue = segments.fold(0.0, (sum, segment) => sum + segment);

    // Safety check for division by zero
    if (totalValue <= 0.0) {
      return; // Nothing to draw if total is zero
    }

    for (int i = 0; i < segments.length; i++) {
      final segmentValue = segments[i];
      final segmentRatio = segmentValue / totalValue;
      final animatedRatio = segmentRatio * animationProgress;

      Color segmentColor;
      if (i < segmentColors.length) {
        segmentColor = segmentColors[i];
      } else if (categoryColumn != null) {
        segmentColor = colorScale.scale(point[categoryColumn]);
      } else {
        // Use theme color palette
        segmentColor = theme.colorPalette[i % theme.colorPalette.length];
      }

      late Rect segmentRect;
      if (isHorizontal) {
        final segmentWidth = barRect.width * animatedRatio;
        segmentRect = Rect.fromLTWH(
          barRect.left + (barRect.width * currentPosition),
          barRect.top,
          segmentWidth,
          barRect.height,
        );
      } else {
        final segmentHeight = barRect.height * animatedRatio;
        segmentRect = Rect.fromLTWH(
          barRect.left,
          barRect.bottom - (barRect.height * currentPosition) - segmentHeight,
          barRect.width,
          segmentHeight,
        );
      }

      final segmentPaint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          segmentRect,
          Radius.circular(geometry.cornerRadius),
        ),
        segmentPaint,
      );

      currentPosition += segmentRatio;
    }

    // Draw stroke
    if (geometry.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = geometry.strokeColor ?? theme.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.strokeWidth;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          barRect,
          Radius.circular(geometry.cornerRadius),
        ),
        strokePaint,
      );
    }

    // Draw label for stacked bars
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: geometry.labelStyle ?? theme.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: isHorizontal ? TextAlign.right : TextAlign.center,
        );
        textPainter.layout();

        final Offset position;
        if (isHorizontal) {
          // Position label to the LEFT of the bar
          position = Offset(
            barRect.left - 8.0 - textPainter.width,
            barRect.top + (barRect.height - textPainter.height) / 2,
          );
        } else {
          // Position label BELOW the bar
          position = Offset(
            barRect.left + (barRect.width - textPainter.width) / 2,
            barRect.bottom + 8.0,
          );
        }
        textPainter.paint(canvas, position);
      }
    }
  }

  /// Draw grouped progress bars (multiple bars side by side)
  void _drawGroupedProgressBar(
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
    final groupCount = geometry.groupCount ?? 3;
    final groupSpacing = geometry.groupSpacing ?? 8.0;
    final isHorizontal = geometry.orientation == ProgressOrientation.horizontal;
    final minGroupSpacing = 30.0; // Minimum space between different data items

    // Calculate group layout
    // NOTE: In production, each bar in a group should represent different data series
    // For example: Q1, Q2, Q3, Q4 sales for the same product
    // Currently showing slight variations of the same value for demonstration purposes
    for (int groupIndex = 0; groupIndex < groupCount; groupIndex++) {
      // Apply subtle variation (±5% per group) to demonstrate grouping visually
      // In real usage, these would be distinct values from your dataset
      final variation = 0.95 + (groupIndex * 0.033); // 95%, 98%, 101%, 104%
      final groupValue = (normalizedValue * variation).clamp(0.0, 1.0);

      // Always use theme palette for consistent theme responsiveness
      final groupColor =
          theme.colorPalette[groupIndex % theme.colorPalette.length];
      theme.colorPalette[groupIndex % theme.colorPalette.length];

      late Rect barRect;
      if (isHorizontal) {
        final barHeight = geometry.thickness * 0.75;
        final totalGroupHeight =
            (barHeight * groupCount) + (groupSpacing * (groupCount - 1));
        final totalItemHeight = totalGroupHeight + minGroupSpacing;

        // Check if we need to scale down
        final totalNeededHeight = data.length * totalItemHeight;
        final scaleFactor = totalNeededHeight > plotArea.height
            ? plotArea.height / totalNeededHeight
            : 1.0;

        final adjustedBarHeight = barHeight * scaleFactor;
        final adjustedGroupSpacing = groupSpacing * scaleFactor;
        final adjustedTotalHeight = (adjustedBarHeight * groupCount) +
            (adjustedGroupSpacing * (groupCount - 1));

        final groupY = plotArea.top +
            (index * (adjustedTotalHeight + (minGroupSpacing * scaleFactor))) +
            (minGroupSpacing * scaleFactor * 0.5) +
            (groupIndex * (adjustedBarHeight + adjustedGroupSpacing));

        if (groupY + adjustedBarHeight > plotArea.bottom) continue;

        final barWidth = plotArea.width * 0.75;
        final barX = plotArea.left + (plotArea.width - barWidth) / 2;
        barRect = Rect.fromLTWH(barX, groupY, barWidth, adjustedBarHeight);
      } else {
        final barWidth = geometry.thickness * 0.75;
        final totalGroupWidth =
            (barWidth * groupCount) + (groupSpacing * (groupCount - 1));
        final totalItemWidth = totalGroupWidth + minGroupSpacing;

        // Check if we need to scale down
        final totalNeededWidth = data.length * totalItemWidth;
        final scaleFactor = totalNeededWidth > plotArea.width
            ? plotArea.width / totalNeededWidth
            : 1.0;

        final adjustedBarWidth = barWidth * scaleFactor;
        final adjustedGroupSpacing = groupSpacing * scaleFactor;
        final adjustedTotalWidth = (adjustedBarWidth * groupCount) +
            (adjustedGroupSpacing * (groupCount - 1));

        final groupX = plotArea.left +
            (index * (adjustedTotalWidth + (minGroupSpacing * scaleFactor))) +
            (minGroupSpacing * scaleFactor * 0.5) +
            (groupIndex * (adjustedBarWidth + adjustedGroupSpacing));

        if (groupX + adjustedBarWidth > plotArea.right) continue;

        final barHeight = plotArea.height * 0.75;
        final barY = plotArea.top + (plotArea.height - barHeight) / 2;
        barRect = Rect.fromLTWH(groupX, barY, adjustedBarWidth, barHeight);
      }

      // Draw background
      final backgroundPaint = Paint()
        ..color = geometry.backgroundColor ?? theme.gridColor.withAlpha(51)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          barRect,
          Radius.circular(geometry.cornerRadius),
        ),
        backgroundPaint,
      );

      // Draw progress fill
      late Rect fillRect;
      if (isHorizontal) {
        final fillWidth = barRect.width * groupValue * animationProgress;
        fillRect = Rect.fromLTWH(
          barRect.left,
          barRect.top,
          fillWidth,
          barRect.height,
        );
      } else {
        final fillHeight = barRect.height * groupValue * animationProgress;
        fillRect = Rect.fromLTWH(
          barRect.left,
          barRect.bottom - fillHeight,
          barRect.width,
          fillHeight,
        );
      }

      final fillPaint = Paint()
        ..color = groupColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          fillRect,
          Radius.circular(geometry.cornerRadius),
        ),
        fillPaint,
      );
    }

    // Draw label for the group (only once per data item, not per group bar)
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: geometry.labelStyle ?? theme.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: isHorizontal ? TextAlign.right : TextAlign.center,
        );
        textPainter.layout();

        // Calculate actual bar positioning using the same logic as bar drawing
        if (isHorizontal) {
          final barHeight = geometry.thickness * 0.75;
          final totalGroupHeight =
              (barHeight * groupCount) + (groupSpacing * (groupCount - 1));
          final totalItemHeight = totalGroupHeight + minGroupSpacing;

          // Apply the same scaling as the bars
          final totalNeededHeight = data.length * totalItemHeight;
          final scaleFactor = totalNeededHeight > plotArea.height
              ? plotArea.height / totalNeededHeight
              : 1.0;

          final adjustedBarHeight = barHeight * scaleFactor;
          final adjustedGroupSpacing = groupSpacing * scaleFactor;
          final adjustedTotalHeight = (adjustedBarHeight * groupCount) +
              (adjustedGroupSpacing * (groupCount - 1));

          final groupY = plotArea.top +
              (index *
                  (adjustedTotalHeight + (minGroupSpacing * scaleFactor))) +
              (minGroupSpacing * scaleFactor * 0.5);

          final barWidth = plotArea.width * 0.75;
          final barX = plotArea.left + (plotArea.width - barWidth) / 2;

          // Position label to the LEFT of the group, vertically centered
          final position = Offset(
            barX - 8.0 - textPainter.width,
            groupY + (adjustedTotalHeight - textPainter.height) / 2,
          );
          textPainter.paint(canvas, position);
        } else {
          final barWidth = geometry.thickness * 0.75;
          final totalGroupWidth =
              (barWidth * groupCount) + (groupSpacing * (groupCount - 1));
          final totalItemWidth = totalGroupWidth + minGroupSpacing;

          // Apply the same scaling as the bars
          final totalNeededWidth = data.length * totalItemWidth;
          final scaleFactor = totalNeededWidth > plotArea.width
              ? plotArea.width / totalNeededWidth
              : 1.0;

          final adjustedBarWidth = barWidth * scaleFactor;
          final adjustedGroupSpacing = groupSpacing * scaleFactor;
          final adjustedTotalWidth = (adjustedBarWidth * groupCount) +
              (adjustedGroupSpacing * (groupCount - 1));

          final groupX = plotArea.left +
              (index * (adjustedTotalWidth + (minGroupSpacing * scaleFactor))) +
              (minGroupSpacing * scaleFactor * 0.5);

          final barHeight = plotArea.height * 0.75;
          final barY = plotArea.top + (plotArea.height - barHeight) / 2;

          // Position label BELOW the group, horizontally centered
          final position = Offset(
            groupX + (adjustedTotalWidth - textPainter.width) / 2,
            barY + barHeight + 8.0,
          );
          textPainter.paint(canvas, position);
        }
      }
    }
  }

  /// Draw gauge/speedometer style progress bar
  void _drawGaugeProgressBar(
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
    final radius = geometry.gaugeRadius ??
        (math.min(plotArea.width, plotArea.height) * 0.3);
    final centerSpacing = radius * 2.5;
    final cols = math.max(1, (plotArea.width / centerSpacing).floor());
    final row = index ~/ cols;
    final col = index % cols;

    final centerX = plotArea.left + (col * centerSpacing) + centerSpacing / 2;
    final centerY = plotArea.top + (row * centerSpacing) + centerSpacing / 2;
    final center = Offset(centerX, centerY);

    if (centerY + radius > plotArea.bottom) return;

    final startAngle = geometry.startAngle ?? -math.pi;
    final sweepAngle = geometry.sweepAngle ?? math.pi;
    final strokeWidth = geometry.thickness * 0.3;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = geometry.backgroundColor ?? theme.gridColor.withAlpha(77)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw tick marks if enabled
    if (geometry.showTicks) {
      final tickCount = geometry.tickCount ?? 10;
      final tickPaint = Paint()
        ..color = theme.axisColor
        ..strokeWidth = 1.0;

      for (int i = 0; i <= tickCount; i++) {
        final tickAngle = startAngle + (sweepAngle * i / tickCount);
        final tickStart = Offset(
          center.dx + (radius - 10) * math.cos(tickAngle),
          center.dy + (radius - 10) * math.sin(tickAngle),
        );
        final tickEnd = Offset(
          center.dx + radius * math.cos(tickAngle),
          center.dy + radius * math.sin(tickAngle),
        );
        canvas.drawLine(tickStart, tickEnd, tickPaint);
      }
    }

    // Draw progress arc
    final progressSweep = sweepAngle * normalizedValue * animationProgress;
    final progressPaint = Paint()
      ..color = geometry.fillColor ??
          theme.colorPalette[index % theme.colorPalette.length]
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Draw needle/indicator
    final needleAngle = startAngle + progressSweep;
    final needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    final needleEnd = Offset(
      center.dx + (radius - 5) * math.cos(needleAngle),
      center.dy + (radius - 5) * math.sin(needleAngle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center dot
    canvas.drawCircle(center, 3.0, Paint()..color = Colors.red);

    // Draw label for gauge
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: geometry.labelStyle ?? theme.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();

        final position = Offset(
          center.dx - textPainter.width / 2,
          center.dy + radius + 10.0,
        );
        textPainter.paint(canvas, position);
      }
    }
  }

  /// Draw concentric circular progress bars
  void _drawConcentricProgressBar(
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
    final baseRadius = geometry.thickness;
    final radii = geometry.concentricRadii ??
        [baseRadius, baseRadius * 1.5, baseRadius * 2.0];
    final thicknesses = geometry.concentricThicknesses ??
        [baseRadius * 0.2, baseRadius * 0.2, baseRadius * 0.2];

    final centerSpacing = (radii.last + thicknesses.last) * 2.5;
    final cols = math.max(1, (plotArea.width / centerSpacing).floor());
    final row = index ~/ cols;
    final col = index % cols;

    final centerX = plotArea.left + (col * centerSpacing) + centerSpacing / 2;
    final centerY = plotArea.top + (row * centerSpacing) + centerSpacing / 2;
    final center = Offset(centerX, centerY);

    if (centerY + radii.last + thicknesses.last > plotArea.bottom) return;

    // Draw each concentric ring
    for (int ringIndex = 0; ringIndex < radii.length; ringIndex++) {
      final radius = radii[ringIndex];
      final thickness = ringIndex < thicknesses.length
          ? thicknesses[ringIndex]
          : thicknesses.last;

      // Vary the progress for each ring
      final ringProgress = normalizedValue * (0.5 + (ringIndex * 0.3));
      // Use theme color palette for rings
      final ringColor =
          theme.colorPalette[ringIndex % theme.colorPalette.length];

      // Draw background ring
      final backgroundPaint = Paint()
        ..color = geometry.backgroundColor ?? theme.gridColor.withAlpha(51)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;

      canvas.drawCircle(center, radius, backgroundPaint);

      // Draw progress arc
      final progressSweep = 2 * math.pi * ringProgress * animationProgress;
      final progressPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        progressSweep,
        false,
        progressPaint,
      );
    }

    // Draw label below concentric rings
    if (geometry.showLabel && labelColumn != null) {
      final labelText = point[labelColumn]?.toString() ?? '';
      if (labelText.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: geometry.labelStyle ?? theme.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();

        final position = Offset(
          center.dx - textPainter.width / 2,
          center.dy + radii.last + thicknesses.last + 10.0,
        );
        textPainter.paint(canvas, position);
      }
    }
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

  /// Pre-calculate maximum label dimensions for layout spacing
  _LabelDimensions _calculateMaxLabelDimensions({
    required Scale? xScale,
    required Scale? yScale,
    required Scale? y2Scale,
    required TextStyle style,
  }) {
    double maxXLabelHeight = 0.0;
    double maxYLabelWidth = 0.0;
    double maxY2LabelWidth = 0.0;

    // Measure X-axis labels
    if (xScale != null) {
      final xTicks = xScale.getTicks();
      for (final tick in xTicks) {
        final label = xScale.formatLabel(tick);
        final textPainter = TextPainter(
          text: TextSpan(text: label, style: style),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        maxXLabelHeight = math.max(maxXLabelHeight, textPainter.height);
      }
    }

    // Measure Y-axis labels
    if (yScale != null) {
      final yTicks = yScale.getTicks();
      for (final tick in yTicks) {
        final label = yScale.formatLabel(tick);
        final textPainter = TextPainter(
          text: TextSpan(text: label, style: style),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        maxYLabelWidth = math.max(maxYLabelWidth, textPainter.width);
      }
    }

    // Measure Y2-axis labels
    if (y2Scale != null) {
      final y2Ticks = y2Scale.getTicks();
      for (final tick in y2Ticks) {
        final label = y2Scale.formatLabel(tick);
        final textPainter = TextPainter(
          text: TextSpan(text: label, style: style),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        maxY2LabelWidth = math.max(maxY2LabelWidth, textPainter.width);
      }
    }

    return _LabelDimensions(
      maxXLabelHeight: maxXLabelHeight,
      maxYLabelWidth: maxYLabelWidth,
      maxY2LabelWidth: maxY2LabelWidth,
    );
  }
}

/// Helper class to store maximum label dimensions
class _LabelDimensions {
  final double maxXLabelHeight;
  final double maxYLabelWidth;
  final double maxY2LabelWidth;

  const _LabelDimensions({
    required this.maxXLabelHeight,
    required this.maxYLabelWidth,
    required this.maxY2LabelWidth,
  });
}
