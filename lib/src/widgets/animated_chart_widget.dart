import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/scale.dart';
import '../interaction/chart_interactions.dart';
import '../interaction/interaction_detector.dart';
import '../interaction/tooltip_widget.dart';
import '../themes/chart_theme.dart';

/// Animated wrapper for the chart widget
class AnimatedCristalyseChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String? xColumn;
  final String? yColumn;
  final String? y2Column; // Secondary Y column
  final String? colorColumn;
  final String? sizeColumn;
  final String? pieValueColumn; // Pie chart value column
  final String? pieCategoryColumn; // Pie chart category column
  final String? heatMapXColumn; // Heat map X column
  final String? heatMapYColumn; // Heat map Y column
  final String? heatMapValueColumn; // Heat map value column
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
  final ChartInteraction interaction;

  const AnimatedCristalyseChartWidget({
    super.key,
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
    this.interaction = ChartInteraction.none,
  });

  @override
  State<AnimatedCristalyseChartWidget> createState() =>
      _AnimatedCristalyseChartWidgetState();
}

class _AnimatedCristalyseChartWidgetState
    extends State<AnimatedCristalyseChartWidget>
    with SingleTickerProviderStateMixin, TooltipMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  InteractionDetector? _interactionDetector;

  TooltipController? _cachedTooltipController;

  /// Pan state tracking
  DateTime? _lastPanCallback;
  Offset? _panStartPosition;
  Offset? _panCurrentPosition;

  /// Pan domain tracking
  List<double>? _panXDomain;
  List<double>? _panYDomain;

  /// Original domain boundaries for pan limits
  List<double>? _originalXDomain;
  List<double>? _originalYDomain;

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
      _interactionDetector?.invalidate();
    }

    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.interaction.tooltip?.builder != null) {
      _cachedTooltipController = ChartTooltipProvider.of(
        context,
        listen: false,
      );
    } else {
      _cachedTooltipController = null;
    }
  }

  @override
  void dispose() {
    _cachedTooltipController?.hideTooltip();
    _animationController.dispose();
    super.dispose();
  }

  void _handleMouseHover(
    BuildContext hoverContext,
    PointerHoverEvent event,
    Rect plotArea,
  ) {
    if (!widget.interaction.enabled ||
        (widget.interaction.hover?.onHover == null &&
            widget.interaction.tooltip?.builder == null)) {
      return;
    }

    if (_interactionDetector == null) {
      _setupInteractionDetector(plotArea);
    }

    // Use larger hit test radius for more forgiving detection
    final hitRadius = math.max(
      widget.interaction.hover?.hitTestRadius ?? 20.0,
      25.0, // Minimum generous radius
    );

    final point = _interactionDetector!.detectPoint(
      event.localPosition,
      maxDistance: hitRadius,
    );

    // Convert local position to global for tooltip positioning
    final RenderBox renderBox = hoverContext.findRenderObject() as RenderBox;
    final Offset globalPosition = renderBox.localToGlobal(event.localPosition);

    // Handle hover callbacks
    widget.interaction.hover?.onHover?.call(point);

    // Handle tooltips
    if (widget.interaction.tooltip?.builder != null) {
      if (point != null) {
        // Keep showing tooltip as long as we have a valid point
        showTooltip(hoverContext, point, globalPosition);
      } else {
        // Only hide if we truly have no nearby points
        hideTooltip(hoverContext);
      }
    }
  }

  void _handleMouseExit(BuildContext exitContext, PointerExitEvent event) {
    if (!widget.interaction.enabled) return;

    widget.interaction.hover?.onExit?.call(null);

    // Always hide tooltip when mouse exits the chart area
    if (widget.interaction.tooltip?.builder != null) {
      hideTooltip(exitContext);
    }
  }

  void _handlePanStart(
    BuildContext panContext,
    DragStartDetails details,
    Rect plotArea,
  ) {
    _panStartPosition = details.localPosition;
    _panCurrentPosition = details.localPosition;

    // Store original domains for panning
    if (widget.interaction.pan?.enabled == true) {
      final xScale = _setupXScale(
        plotArea.width,
        widget.geometries.any((g) => g is BarGeometry),
      );
      final yScale = _setupYScale(
        plotArea.height,
        widget.geometries.any((g) => g is BarGeometry),
        YAxis.primary,
      );

      if (xScale is LinearScale) {
        // Initialize pan domain if not already set
        _panXDomain ??= List.from(xScale.domain);
        // Store original domain boundaries for pan limits
        _originalXDomain ??= List.from(xScale.domain);
      }
      if (yScale is LinearScale) {
        // Initialize pan domain if not already set
        _panYDomain ??= List.from(yScale.domain);
        // Store original domain boundaries for pan limits
        _originalYDomain ??= List.from(yScale.domain);
      }
    }

    // Handle pan start callback
    if (widget.interaction.pan?.enabled == true &&
        widget.interaction.pan?.onPanStart != null) {
      final panInfo = _calculatePanInfo(
        plotArea,
        PanState.start,
        details.localPosition,
      );
      widget.interaction.pan!.onPanStart!(panInfo);
    }
  }

  void _handlePanUpdate(
    BuildContext panContext,
    DragUpdateDetails details,
    Rect plotArea,
  ) {
    final panConfig = widget.interaction.pan;
    final hasTooltips = widget.interaction.hover?.onHover != null ||
        widget.interaction.tooltip?.builder != null;

    if (!widget.interaction.enabled) {
      return;
    }

    _panCurrentPosition = details.localPosition;

    // Handle pan update callback with throttling - ONLY if pan is enabled
    if (panConfig?.enabled == true) {
      // Update pan domains based on delta
      _updatePanDomains(plotArea, details.delta);

      // Fire callbacks with throttling
      if (panConfig?.onPanUpdate != null) {
        final now = DateTime.now();
        if (_lastPanCallback == null ||
            now.difference(_lastPanCallback!) >= panConfig!.throttle) {
          _lastPanCallback = now;
          final panInfo = _calculatePanInfo(
            plotArea,
            PanState.update,
            details.localPosition,
            details.delta,
          );
          panConfig!.onPanUpdate!(panInfo);
        }
      }

      // Trigger rebuild to show visual pan
      setState(() {});

      // If panning is enabled, don't process tooltips during pan to avoid conflicts
      return;
    }

    // Handle tooltip/hover interactions ONLY if panning is not enabled
    if (hasTooltips && panConfig?.enabled != true) {
      if (_interactionDetector == null) {
        _setupInteractionDetector(plotArea);
      }

      // Use even larger radius for touch interactions
      final hitRadius = math.max(
        widget.interaction.hover?.hitTestRadius ?? 30.0,
        35.0, // Even more generous for touch
      );

      final point = _interactionDetector!.detectPoint(
        details.localPosition,
        maxDistance: hitRadius,
      );

      // Convert local position to global for tooltip positioning
      final RenderBox renderBox = panContext.findRenderObject() as RenderBox;
      final Offset globalPosition = renderBox.localToGlobal(
        details.localPosition,
      );

      // Handle hover callbacks
      widget.interaction.hover?.onHover?.call(point);

      // Handle tooltips
      if (widget.interaction.tooltip?.builder != null) {
        if (point != null && widget.interaction.tooltip!.followPointer) {
          showTooltip(panContext, point, globalPosition);
        } else if (point == null) {
          hideTooltip(panContext);
        }
      }
    }
  }

  void _handlePanEnd(
    BuildContext panEndContext,
    DragEndDetails details,
    Rect plotArea,
  ) {
    if (!widget.interaction.enabled) return;

    // Handle pan end callback
    if (widget.interaction.pan?.enabled == true &&
        widget.interaction.pan?.onPanEnd != null) {
      final panInfo = _calculatePanInfo(
        plotArea,
        PanState.end,
        _panCurrentPosition ?? Offset.zero,
      );
      widget.interaction.pan!.onPanEnd!(panInfo);
    }

    // Reset pan tracking
    _panStartPosition = null;
    _panCurrentPosition = null;
    _lastPanCallback = null;

    // Keep pan domains to maintain the panned view
    // Don't reset them so the chart stays in the panned position

    widget.interaction.hover?.onExit?.call(null);

    if (widget.interaction.tooltip?.builder != null) {
      hideTooltip(panEndContext);
    }
  }

  void _handleTap(
    BuildContext tapContext,
    TapUpDetails details,
    Rect plotArea,
  ) {
    if (!widget.interaction.enabled ||
        widget.interaction.click?.onTap == null) {
      return;
    }

    if (_interactionDetector == null) {
      _setupInteractionDetector(plotArea);
    }

    final point = _interactionDetector!.detectPoint(
      details.localPosition,
      maxDistance: widget.interaction.click?.hitTestRadius ?? 15.0,
    );

    // Convert local position to global for tooltip positioning
    final RenderBox renderBox = tapContext.findRenderObject() as RenderBox;
    final Offset globalPosition = renderBox.localToGlobal(
      details.localPosition,
    );

    if (point != null) {
      widget.interaction.click!.onTap!(point);
      if (widget.interaction.tooltip?.builder != null) {
        showTooltip(tapContext, point, globalPosition); // Use globalPosition
      }
    }
  }

  void _setupInteractionDetector(Rect plotArea) {
    final xScale = _setupXScale(
      plotArea.width,
      widget.geometries.any((g) => g is BarGeometry),
    );
    final yScale = _setupYScale(
      plotArea.height,
      widget.geometries.any((g) => g is BarGeometry),
      YAxis.primary,
    );
    final y2Scale = _hasSecondaryYAxis()
        ? _setupYScale(
            plotArea.height,
            widget.geometries.any((g) => g is BarGeometry),
            YAxis.secondary,
          )
        : null;

    _interactionDetector = InteractionDetector(
      data: widget.data,
      geometries: widget.geometries,
      xScale: xScale,
      yScale: yScale,
      y2Scale: y2Scale,
      plotArea: plotArea,
      xColumn: widget.xColumn,
      yColumn: widget.yColumn,
      y2Column: widget.y2Column,
      colorColumn: widget.colorColumn,
      coordFlipped: widget.coordFlipped,
    );
  }

  Widget _buildInteractiveChart(BuildContext context, Size size) {
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
            pieValueColumn: widget.pieValueColumn,
            pieCategoryColumn: widget.pieCategoryColumn,
            heatMapXColumn: widget.heatMapXColumn,
            heatMapYColumn: widget.heatMapYColumn,
            heatMapValueColumn: widget.heatMapValueColumn,
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

    final hasSecondaryY = _hasSecondaryYAxis();
    final rightPadding = hasSecondaryY ? 80.0 : widget.theme.padding.right;

    final plotArea = Rect.fromLTWH(
      widget.theme.padding.left,
      widget.theme.padding.top,
      size.width - widget.theme.padding.left - rightPadding,
      size.height - widget.theme.padding.vertical,
    );

    final chartPainter = _AnimatedChartPainter(
      data: widget.data,
      xColumn: widget.xColumn,
      yColumn: widget.yColumn,
      y2Column: widget.y2Column,
      colorColumn: widget.colorColumn,
      sizeColumn: widget.sizeColumn,
      pieValueColumn: widget.pieValueColumn,
      pieCategoryColumn: widget.pieCategoryColumn,
      heatMapXColumn: widget.heatMapXColumn,
      heatMapYColumn: widget.heatMapYColumn,
      heatMapValueColumn: widget.heatMapValueColumn,
      geometries: widget.geometries,
      xScale: widget.xScale,
      yScale: widget.yScale,
      y2Scale: widget.y2Scale,
      colorScale: widget.colorScale,
      sizeScale: widget.sizeScale,
      theme: widget.theme,
      animationProgress: math.max(0.0, math.min(1.0, animationValue)),
      coordFlipped: widget.coordFlipped,
      panXDomain: _panXDomain,
      panYDomain: _panYDomain,
    );

    Widget chart = CustomPaint(painter: chartPainter, child: Container());

    // Wrap with gesture detection if interactions are enabled
    if (widget.interaction.enabled) {
      chart = MouseRegion(
        onHover: (event) => _handleMouseHover(context, event, plotArea),
        onExit: (event) => _handleMouseExit(context, event),
        child: GestureDetector(
          onPanStart: (details) => _handlePanStart(context, details, plotArea),
          onPanUpdate: (details) =>
              _handlePanUpdate(context, details, plotArea),
          onPanEnd: (details) => _handlePanEnd(context, details, plotArea),
          onTapUp: (details) => _handleTap(context, details, plotArea),
          child: chart,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        border: Border.all(color: widget.theme.borderColor),
      ),
      child: chart,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget chart = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return _buildInteractiveChart(context, constraints.biggest);
          },
        );
      },
    );

    // Wrap with tooltip overlay if tooltips are enabled
    if (widget.interaction.enabled && widget.interaction.tooltip != null) {
      chart = ChartTooltipOverlay(
        config: widget.interaction.tooltip!,
        tooltipBuilder: widget.interaction.tooltip!.builder,
        child: chart,
      );
    }

    return chart;
  }

  bool _hasSecondaryYAxis() {
    return widget.y2Column != null &&
        widget.geometries.any((g) => g.yAxis == YAxis.secondary);
  }

  Scale _setupXScale(double width, bool hasBarGeometry) {
    if (widget.coordFlipped) {
      final preconfigured = widget.yScale;
      final scale =
          (preconfigured is LinearScale ? preconfigured : LinearScale());
      final dataCol = widget.yColumn;

      if (dataCol == null || widget.data.isEmpty) {
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
        scale.range = [0, width];
        return scale;
      }

      final values = widget.data
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
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
      }
      scale.range = [0, width];
      return scale;
    } else {
      final preconfigured = widget.xScale;
      final dataCol = widget.xColumn;
      if (preconfigured is OrdinalScale ||
          (hasBarGeometry && _isColumnCategorical(dataCol))) {
        final scale =
            (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
        if (dataCol == null || widget.data.isEmpty) {
          scale.domain = [];
          scale.range = [0, width];
          return scale;
        }
        if (scale.domain.isEmpty) {
          final distinctValues = widget.data
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
        if (dataCol == null || widget.data.isEmpty) {
          scale.domain = scale.min != null && scale.max != null
              ? [scale.min!, scale.max!]
              : [0, 1];
          scale.range = [0, width];
          return scale;
        }
        final values = widget.data
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
    if (widget.coordFlipped) {
      final preconfigured = widget.xScale;
      final scale =
          (preconfigured is OrdinalScale ? preconfigured : OrdinalScale());
      final dataCol = widget.xColumn;

      if (dataCol == null || widget.data.isEmpty) {
        scale.domain = [];
        scale.range = [0, height];
        return scale;
      }
      if (scale.domain.isEmpty) {
        final distinctValues = widget.data
            .map((d) => d[dataCol])
            .where((v) => v != null)
            .toSet()
            .toList();
        scale.domain = distinctValues;
      }
      scale.range = [0, height];
      return scale;
    } else {
      final preconfigured =
          axis == YAxis.primary ? widget.yScale : widget.y2Scale;
      final dataCol = axis == YAxis.primary ? widget.yColumn : widget.y2Column;

      final scale =
          (preconfigured is LinearScale ? preconfigured : LinearScale());
      if (dataCol == null || widget.data.isEmpty) {
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
        scale.range = [height, 0];
        return scale;
      }

      final relevantGeometries =
          widget.geometries.where((g) => g.yAxis == axis).toList();
      if (relevantGeometries.isEmpty) {
        scale.domain = [0, 1];
        scale.range = [height, 0];
        return scale;
      }

      final hasStackedBars = relevantGeometries.any(
        (g) => g is BarGeometry && g.style == BarStyle.stacked,
      );

      List<double> values;

      if (hasStackedBars && widget.colorColumn != null) {
        final groups = <dynamic, double>{};
        for (final point in widget.data) {
          final x = point[widget.xColumn];
          final y = _getNumericValue(point[dataCol]);
          if (y == null || !y.isFinite || y <= 0) continue;

          groups[x] = (groups[x] ?? 0) + y;
        }
        values = groups.values.where((v) => v.isFinite).cast<double>().toList();
      } else {
        values = widget.data
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
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
      }
      scale.range = [height, 0];
      return scale;
    }
  }

  bool _isColumnCategorical(String? column) {
    if (column == null || widget.data.isEmpty) return false;
    for (final row in widget.data) {
      final value = row[column];
      if (value != null) {
        return value is String || value is bool;
      }
    }
    return false;
  }

  double? _getNumericValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Update pan domains based on delta movement
  void _updatePanDomains(Rect plotArea, Offset delta) {
    if (_panXDomain == null) return;

    // Calculate the data range per pixel for current pan domain
    final xRange = _panXDomain![1] - _panXDomain![0];
    final pixelsPerXUnit = plotArea.width / xRange;

    // Convert pixel delta to data delta
    final xDataDelta =
        -delta.dx / pixelsPerXUnit; // Negative for natural pan direction

    // Update the pan domain progressively - allow infinite panning
    if (widget.interaction.pan?.updateXDomain != false) {
      // Default to true if not specified
      final newXMin = _panXDomain![0] + xDataDelta;
      final newXMax = _panXDomain![1] + xDataDelta;

      // Always allow panning - no blocking, visual clipping will handle boundaries
      _panXDomain![0] = newXMin;
      _panXDomain![1] = newXMax;
    }

    // Optionally handle Y panning too - allow infinite panning
    if (widget.interaction.pan?.updateYDomain == true && _panYDomain != null) {
      final yRange = _panYDomain![1] - _panYDomain![0];
      final pixelsPerYUnit = plotArea.height / yRange;
      final yDataDelta =
          delta.dy / pixelsPerYUnit; // Positive for natural pan direction

      final newYMin = _panYDomain![0] + yDataDelta;
      final newYMax = _panYDomain![1] + yDataDelta;

      // Always allow panning - visual clipping will handle boundaries
      _panYDomain![0] = newYMin;
      _panYDomain![1] = newYMax;
    }
  }

  /// Calculate pan information for callbacks
  PanInfo _calculatePanInfo(
    Rect plotArea,
    PanState state,
    Offset currentPosition, [
    Offset? delta,
  ]) {
    double? visibleMinX, visibleMaxX, visibleMinY, visibleMaxY;

    // If we have pan domains, use them directly for the visible range
    if (_panXDomain != null && _panYDomain != null) {
      if (widget.coordFlipped) {
        // For flipped coordinates, X domain becomes Y range and vice versa
        visibleMinY = _panXDomain![0];
        visibleMaxY = _panXDomain![1];
        // For Y, we might not have ordinal pan domains, so fallback to scale calculation
        try {
          final yScale = _setupYScale(
            plotArea.height,
            widget.geometries.any((g) => g is BarGeometry),
            YAxis.primary,
          );
          visibleMinX = yScale.invert(plotArea.height);
          visibleMaxX = yScale.invert(0);
        } catch (e) {
          // Fallback if invert not supported
          visibleMinX = null;
          visibleMaxX = null;
        }
      } else {
        // Normal charts
        visibleMinX = _panXDomain![0];
        visibleMaxX = _panXDomain![1];
        visibleMinY = _panYDomain![0];
        visibleMaxY = _panYDomain![1];
      }
    } else {
      // Fallback to scale calculation if no pan domains
      final xScale = _setupXScale(
        plotArea.width,
        widget.geometries.any((g) => g is BarGeometry),
      );
      final yScale = _setupYScale(
        plotArea.height,
        widget.geometries.any((g) => g is BarGeometry),
        YAxis.primary,
      );

      try {
        if (widget.coordFlipped) {
          // Horizontal charts: X becomes Y, Y becomes X
          visibleMinY = yScale.invert(0);
          visibleMaxY = yScale.invert(plotArea.height);
          visibleMinX = xScale.invert(plotArea.width);
          visibleMaxX = xScale.invert(0);
        } else {
          // Normal charts
          visibleMinX = xScale.invert(0);
          visibleMaxX = xScale.invert(plotArea.width);
          visibleMinY = yScale.invert(plotArea.height);
          visibleMaxY = yScale.invert(0);
        }
      } catch (e) {
        // If scales don't support invert (like OrdinalScale in some cases),
        // provide null values
      }
    }

    final totalDelta =
        _panStartPosition != null ? currentPosition - _panStartPosition! : null;

    return PanInfo(
      visibleMinX: visibleMinX,
      visibleMaxX: visibleMaxX,
      visibleMinY: visibleMinY,
      visibleMaxY: visibleMaxY,
      state: state,
      delta: delta,
      totalDelta: totalDelta,
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
  final String? pieValueColumn;
  final String? pieCategoryColumn;
  final String? heatMapXColumn;
  final String? heatMapYColumn;
  final String? heatMapValueColumn;
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

  _AnimatedChartPainter({
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

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || geometries.isEmpty) return;

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
        scale.domain = scale.min != null && scale.max != null
            ? [scale.min!, scale.max!]
            : [0, 1];
        scale.range = [0, width];
        return scale;
      }

      final values = data
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
          (hasBarGeometry && _isColumnCategorical(dataCol))) {
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
          final y = _getNumericValue(point[dataCol]);
          if (y == null || !y.isFinite || y <= 0) continue;

          groups[x] = (groups[x] ?? 0) + y;
        }
        values = groups.values.where((v) => v.isFinite).cast<double>().toList();
      } else {
        values = data
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
    // For pie charts, use category column; otherwise use color column
    final hasPieChart = geometries.any((g) => g is PieGeometry);
    final columnToUse = hasPieChart && pieCategoryColumn != null
        ? pieCategoryColumn
        : colorColumn;

    if (columnToUse == null) return ColorScale();
    final values = data.map((d) => d[columnToUse]).toSet().toList();
    return ColorScale(values: values, colors: theme.colorPalette);
  }

  SizeScale _setupSizeScale() {
    if (sizeColumn == null) return SizeScale();
    final values = data
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
    final color = colorColumn != null
        ? colorScale.scale(dataPoint[colorColumn])
        : (theme.colorPalette.isNotEmpty
            ? theme.colorPalette.first
            : theme.primaryColor);

    final paint = Paint()
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

      final color = colorColumn != null
          ? colorScale.scale(point[colorColumn])
          : (theme.colorPalette.isNotEmpty
              ? theme.colorPalette.first
              : theme.primaryColor);

      final size = sizeColumn != null
          ? sizeScale.scale(point[sizeColumn])
          : theme.pointSizeDefault;

      final paint = Paint()
        ..color = color.withAlpha(
          (geometry.alpha * pointProgress * 255).round(),
        )
        ..style = PaintingStyle.fill;

      final pointX = plotArea.left + xScale.scale(x);
      final pointY = plotArea.top + yScale.scale(y);

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

    final color = geometry.color ??
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
        final ordinalScale = xScale;
        screenX = plotArea.left + ordinalScale.bandCenter(xRawValue);
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

    final paint = Paint()
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
      final aX = _getNumericValue(a[xColumn]) ?? 0;
      final bX = _getNumericValue(b[xColumn]) ?? 0;
      return aX.compareTo(bX);
    });

    final points = <Offset>[];
    for (int i = 0; i < sortedData.length; i++) {
      final point = sortedData[i];
      final xRawValue = point[xColumn];
      final yVal = _getNumericValue(point[yCol]);

      if (xRawValue == null || yVal == null) continue;

      // Handle both ordinal and continuous X-scales
      double screenX;
      if (xScale is OrdinalScale) {
        // For ordinal scales, use the raw string value with bandCenter
        final ordinalScale = xScale;
        screenX = plotArea.left + ordinalScale.bandCenter(xRawValue);
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
        data.map((d) => _getNumericValue(d[valueColumn]) ?? 0).toList();
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

    // Sort values for consistent ordering
    xValues.sort((a, b) => a.toString().compareTo(b.toString()));
    yValues.sort((a, b) => a.toString().compareTo(b.toString()));

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
        .map((d) => _getNumericValue(d[valueCol]))
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
      final value = _getNumericValue(point[valueCol]);
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
            final nullPaint = Paint()
              ..color = geometry.nullValueColor!.withAlpha(
                ((geometry.nullValueColor!.a * 255.0) * heatMapProgress)
                        .round() &
                    0xff,
              )
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
        if (geometry.colorGradient != null &&
            geometry.colorGradient!.isNotEmpty) {
          // Use provided color gradient
          final normalizedValue = valueRange > 0
              ? ((value - minValue) / valueRange).clamp(0.0, 1.0)
              : 0.5;

          if (geometry.interpolateColors) {
            cellColor = _interpolateGradientColor(
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
          final normalizedValue = valueRange > 0
              ? ((value - minValue) / valueRange).clamp(0.0, 1.0)
              : 0.5;
          cellColor = _defaultHeatMapColor(normalizedValue);
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
        final cellPaint = Paint()
          ..color = cellColor.withAlpha(
            math.max(
                200,
                ((cellColor.a * 255.0) * cellProgress).round() &
                    0xff), // Ensure minimum visibility
          )
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

          // Use black text for values < 15%, otherwise use brightness-based logic
          final textColor = value < 0.15
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

  Color _interpolateGradientColor(double value, List<Color> gradient) {
    // Ensure value is in [0, 1]
    value = value.clamp(0.0, 1.0);

    if (gradient.isEmpty) return Colors.grey;
    if (gradient.length == 1) return gradient.first;

    // Calculate position in gradient
    final scaledValue = value * (gradient.length - 1);
    final index = scaledValue.floor();
    final t = scaledValue - index;

    if (index >= gradient.length - 1) {
      return gradient.last;
    }

    return Color.lerp(gradient[index], gradient[index + 1], t)!;
  }

  Color _defaultHeatMapColor(double value) {
    // Enhanced default gradient with higher intensity
    value = value.clamp(0.0, 1.0);

    // Make colors more vibrant and increase the minimum intensity
    final minIntensity = 0.4; // Ensure cells are never too faint
    final adjustedValue = minIntensity + (value * (1.0 - minIntensity));

    if (adjustedValue < 0.5) {
      // Dark blue to bright cyan (more intense)
      return Color.lerp(
        const Color(0xFF000080), // Dark blue
        const Color(0xFF00FFFF), // Bright cyan
        adjustedValue * 2,
      )!;
    } else if (adjustedValue < 0.75) {
      // Bright cyan to lime green
      return Color.lerp(
        const Color(0xFF00FFFF), // Bright cyan
        const Color(0xFF32FF32), // Lime green
        (adjustedValue - 0.5) * 4,
      )!;
    } else {
      // Lime green to bright red
      return Color.lerp(
        const Color(0xFF32FF32), // Lime green
        const Color(0xFFFF0000), // Bright red
        (adjustedValue - 0.75) * 4,
      )!;
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
    _sortHeatMapValues(xValues);
    _sortHeatMapValues(yValues);

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

  /// Smart sorting for heatmap values that handles days of the week and time properly
  void _sortHeatMapValues(List<dynamic> values) {
    // Define ordered lists for common patterns
    final dayOrder = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sun',
      'mon',
      'tue',
      'wed',
      'thu',
      'fri',
      'sat'
    ];

    final monthOrder = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];

    values.sort((a, b) {
      final aStr = a.toString().toLowerCase();
      final bStr = b.toString().toLowerCase();

      // Check if both are days of the week
      final aDay = dayOrder.indexOf(aStr);
      final bDay = dayOrder.indexOf(bStr);
      if (aDay != -1 && bDay != -1) {
        // Both are days - use day order, but normalize Sunday=0 to Sunday=7 for weekly view
        final normalizedA =
            aDay < 7 ? (aDay == 0 ? 7 : aDay) : (aDay - 7 == 0 ? 7 : aDay - 7);
        final normalizedB =
            bDay < 7 ? (bDay == 0 ? 7 : bDay) : (bDay - 7 == 0 ? 7 : bDay - 7);
        return normalizedA.compareTo(normalizedB);
      }

      // Check if both are months
      final aMonth = monthOrder.indexOf(aStr);
      final bMonth = monthOrder.indexOf(bStr);
      if (aMonth != -1 && bMonth != -1) {
        final normalizedA = aMonth < 12 ? aMonth : aMonth - 12;
        final normalizedB = bMonth < 12 ? bMonth : bMonth - 12;
        return normalizedA.compareTo(normalizedB);
      }

      // Check if both are time values (like 8am, 2pm, 14:30, etc.)
      final aTime = _parseTimeValue(aStr);
      final bTime = _parseTimeValue(bStr);
      if (aTime != null && bTime != null) {
        return aTime.compareTo(bTime);
      }

      // Check if both are numeric
      final aNum = double.tryParse(aStr);
      final bNum = double.tryParse(bStr);
      if (aNum != null && bNum != null) {
        return aNum.compareTo(bNum);
      }

      // Fall back to alphabetical sorting
      return aStr.compareTo(bStr);
    });
  }

  /// Parse time values like "8am", "2pm", "14:30", "9:15am" into comparable integers (minutes since midnight)
  int? _parseTimeValue(String timeStr) {
    // Remove common time separators and normalize
    final normalized = timeStr.replaceAll(RegExp(r'[:\s]'), '').toLowerCase();

    // Match patterns like 8am, 2pm, 14h, 830am, 915pm, etc.
    final timeRegex = RegExp(r'^(\d{1,2})(\d{2})?(am|pm|h)?$');
    final match = timeRegex.firstMatch(normalized);

    if (match == null) return null;

    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final meridiem = match.group(3);

    if (hour == null || hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;

    int finalHour = hour;

    // Handle AM/PM
    if (meridiem == 'am') {
      if (hour == 12) finalHour = 0; // 12am = midnight
    } else if (meridiem == 'pm') {
      if (hour != 12) finalHour = hour + 12; // Convert to 24-hour format
    }
    // For 'h' suffix or no suffix, assume 24-hour format already

    return finalHour * 60 + minute; // Convert to minutes since midnight
  }

  @override
  bool shouldRepaint(covariant _AnimatedChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.theme != theme ||
        oldDelegate.geometries != geometries ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.coordFlipped != coordFlipped ||
        oldDelegate.y2Column != y2Column ||
        oldDelegate.pieValueColumn != pieValueColumn ||
        oldDelegate.pieCategoryColumn != pieCategoryColumn;
  }
}
