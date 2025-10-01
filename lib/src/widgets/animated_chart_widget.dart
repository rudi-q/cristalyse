import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/legend.dart';
import '../core/scale.dart';
import '../core/util/helper.dart';
import '../core/util/painter.dart';
import '../interaction/chart_interactions.dart';
import '../interaction/crosshair_widget.dart';
import '../interaction/interaction_detector.dart';
import '../interaction/tooltip_widget.dart';
import '../themes/chart_theme.dart';
import 'legend_widget.dart';

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
  final String? progressValueColumn; // Progress bar value column
  final String? progressLabelColumn; // Progress bar label column
  final String? progressCategoryColumn; // Progress bar category column
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
  final LegendConfig? legendConfig;

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
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.coordFlipped = false,
    this.interaction = ChartInteraction.none,
    this.legendConfig,
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

  /// Crosshair position for axis-based tooltips
  Offset? _crosshairPosition;

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
            widget.interaction.tooltip?.builder == null &&
            widget.interaction.tooltip?.multiPointBuilder == null)) {
      return;
    }

    if (_interactionDetector == null) {
      _setupInteractionDetector(plotArea);
    }

    // Convert local position to global for tooltip positioning
    final RenderBox renderBox = hoverContext.findRenderObject() as RenderBox;
    final Offset globalPosition = renderBox.localToGlobal(event.localPosition);

    // Check tooltip trigger mode
    final tooltipConfig = widget.interaction.tooltip;
    final useAxisMode =
        tooltipConfig?.triggerMode == ChartTooltipTriggerMode.axis;

    if (useAxisMode) {
      // Axis mode: detect all points at X position
      // Always snaps to nearest X position for continuous tooltip display
      final points = _interactionDetector!.detectPointsByXPosition(
        event.localPosition,
      );

      // Update crosshair position if needed
      if (tooltipConfig?.showCrosshair == true && points.isNotEmpty) {
        setState(() {
          _crosshairPosition = event.localPosition;
        });
      } else if (_crosshairPosition != null) {
        setState(() {
          _crosshairPosition = null;
        });
      }

      // Handle hover callbacks (use first point for backward compatibility)
      widget.interaction.hover?.onHover
          ?.call(points.isNotEmpty ? points.first : null);

      // Handle tooltips
      if (tooltipConfig != null) {
        if (points.isNotEmpty) {
          // Show multi-point tooltip
          _showMultiPointTooltip(hoverContext, points, globalPosition);
        } else {
          // No points found - hide tooltip
          hideTooltip(hoverContext);
        }
      }
    } else {
      // Point mode: detect single closest point
      final hitRadius = math.max(
        widget.interaction.hover?.hitTestRadius ?? 20.0,
        25.0, // Minimum generous radius
      );

      final point = _interactionDetector!.detectPoint(
        event.localPosition,
        maxDistance: hitRadius,
      );

      // Handle hover callbacks
      widget.interaction.hover?.onHover?.call(point);

      // Handle tooltips
      if (tooltipConfig?.builder != null) {
        if (point != null) {
          // Keep showing tooltip as long as we have a valid point
          showTooltip(hoverContext, point, globalPosition);
        } else {
          // Only hide if we truly have no nearby points
          hideTooltip(hoverContext);
        }
      }
    }
  }

  /// Helper to show multi-point tooltip
  void _showMultiPointTooltip(
    BuildContext context,
    List<DataPointInfo> points,
    Offset globalPosition,
  ) {
    if (_cachedTooltipController != null) {
      _cachedTooltipController!.showMultiPointTooltip(points, globalPosition);
    } else {
      showMultiPointTooltip(context, points, globalPosition);
    }
  }

  void _handleMouseExit(BuildContext exitContext, PointerExitEvent event) {
    if (!widget.interaction.enabled) return;

    widget.interaction.hover?.onExit?.call(null);

    // Clear crosshair
    if (_crosshairPosition != null) {
      setState(() {
        _crosshairPosition = null;
      });
    }

    // Always hide tooltip when mouse exits the chart area
    if (widget.interaction.tooltip?.builder != null ||
        widget.interaction.tooltip?.multiPointBuilder != null) {
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

      // Convert local position to global for tooltip positioning
      final RenderBox renderBox = panContext.findRenderObject() as RenderBox;
      final Offset globalPosition = renderBox.localToGlobal(
        details.localPosition,
      );

      final tooltipConfig = widget.interaction.tooltip;
      final useAxisMode =
          tooltipConfig?.triggerMode == ChartTooltipTriggerMode.axis;

      if (useAxisMode) {
        // Axis mode: detect all points at X position
        // Always snaps to nearest X position for continuous tooltip display
        final points = _interactionDetector!.detectPointsByXPosition(
          details.localPosition,
        );

        // Update crosshair position if needed
        if (tooltipConfig?.showCrosshair == true && points.isNotEmpty) {
          setState(() {
            _crosshairPosition = details.localPosition;
          });
        } else if (_crosshairPosition != null) {
          setState(() {
            _crosshairPosition = null;
          });
        }

        // Handle hover callbacks (use first point)
        widget.interaction.hover?.onHover
            ?.call(points.isNotEmpty ? points.first : null);

        // Handle tooltips
        if (tooltipConfig != null && tooltipConfig.followPointer) {
          if (points.isNotEmpty) {
            _showMultiPointTooltip(panContext, points, globalPosition);
          } else {
            hideTooltip(panContext);
          }
        }
      } else {
        // Point mode: use larger radius for touch interactions
        final hitRadius = math.max(
          widget.interaction.hover?.hitTestRadius ?? 30.0,
          35.0, // Even more generous for touch
        );

        final point = _interactionDetector!.detectPoint(
          details.localPosition,
          maxDistance: hitRadius,
        );

        // Handle hover callbacks
        widget.interaction.hover?.onHover?.call(point);

        // Handle tooltips
        if (tooltipConfig?.builder != null) {
          if (point != null && tooltipConfig!.followPointer) {
            showTooltip(panContext, point, globalPosition);
          } else if (point == null) {
            hideTooltip(panContext);
          }
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

    // Clear crosshair on gesture end
    if (_crosshairPosition != null) {
      setState(() {
        _crosshairPosition = null;
      });
    }

    widget.interaction.hover?.onExit?.call(null);

    // Always hide tooltip on gesture end (not just when builder != null)
    // This ensures both single-point and multi-point tooltips are hidden
    hideTooltip(panEndContext);
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
    final y2Scale = hasSecondaryYAxis(
            y2Column: widget.y2Column, geometries: widget.geometries)
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
          painter: chartPainterAnimated(
              widget: widget,
              context: context,
              size: size,
              animationProgress: 1.0,
              panXDomain: _panXDomain,
              panYDomain: _panYDomain),
          child: Container(),
        ),
      );
    }

    final hasSecondaryY = hasSecondaryYAxis(
        y2Column: widget.y2Column, geometries: widget.geometries);
    final rightPadding = hasSecondaryY ? 80.0 : widget.theme.padding.right;

    final plotArea = Rect.fromLTWH(
      widget.theme.padding.left,
      widget.theme.padding.top,
      size.width - widget.theme.padding.left - rightPadding,
      size.height - widget.theme.padding.vertical,
    );

    final chartPainter = chartPainterAnimated(
        widget: widget,
        context: context,
        size: size,
        animationProgress: math.max(0.0, math.min(1.0, animationValue)),
        panXDomain: _panXDomain,
        panYDomain: _panYDomain);

    Widget chart = CustomPaint(painter: chartPainter, child: Container());

    // Add crosshair overlay if enabled in axis mode
    final showCrosshair = widget.interaction.tooltip?.showCrosshair == true &&
        widget.interaction.tooltip?.triggerMode == ChartTooltipTriggerMode.axis;

    if (showCrosshair) {
      chart = Stack(
        children: [
          chart,
          CrosshairOverlay(
            position: _crosshairPosition,
            plotArea: plotArea,
            config: widget.interaction.tooltip!,
          ),
        ],
      );
    }

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

    // Add legend if configured
    if (widget.legendConfig != null) {
      chart = _buildChartWithLegend(context, chart);
    }

    return chart;
  }

  /// Build chart with legend positioned according to configuration
  Widget _buildChartWithLegend(BuildContext context, Widget chart) {
    final config = widget.legendConfig!;

    // Generate legend items from chart data
    final legendItems = LegendGenerator.generateFromData(
      data: widget.data,
      colorColumn: widget.colorColumn,
      colorPalette: widget.theme.colorPalette,
      geometries: widget.geometries,
    );

    // If no legend items, return chart as-is
    if (legendItems.isEmpty) return chart;

    final legend = LegendWidget(
      items: legendItems,
      config: config,
      theme: widget.theme,
    );

    // Position legend based on configuration
    return _positionLegend(chart, legend, config);
  }

  /// Position legend relative to chart based on configuration
  Widget _positionLegend(Widget chart, Widget legend, LegendConfig config) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we have bounded constraints
        final hasFiniteWidth = constraints.maxWidth != double.infinity;
        final hasFiniteHeight = constraints.maxHeight != double.infinity;

        // If constraints are unbounded, use overlay positioning
        if (!hasFiniteWidth || !hasFiniteHeight) {
          return _buildOverlayLegend(chart, legend, config);
        }

        final spacing = SizedBox(
          width: config.isRightSide || config.isLeftSide ? config.spacing : 0,
          height: config.isTopSide || config.isBottomSide ? config.spacing : 0,
        );

        return _buildFlexLegend(chart, legend, config, spacing);
      },
    );
  }

  /// Build legend using overlay positioning for unbounded constraints
  Widget _buildOverlayLegend(Widget chart, Widget legend, LegendConfig config) {
    Alignment alignment;
    EdgeInsets padding;

    switch (config.position) {
      case LegendPosition.top:
        alignment = Alignment.topCenter;
        padding = EdgeInsets.only(top: config.spacing);
        break;
      case LegendPosition.bottom:
        alignment = Alignment.bottomCenter;
        padding = EdgeInsets.only(bottom: config.spacing);
        break;
      case LegendPosition.left:
        alignment = Alignment.centerLeft;
        padding = EdgeInsets.only(left: config.spacing);
        break;
      case LegendPosition.right:
        alignment = Alignment.centerRight;
        padding = EdgeInsets.only(right: config.spacing);
        break;
      case LegendPosition.topLeft:
        alignment = Alignment.topLeft;
        padding = EdgeInsets.only(top: config.spacing, left: config.spacing);
        break;
      case LegendPosition.topRight:
        alignment = Alignment.topRight;
        padding = EdgeInsets.only(top: config.spacing, right: config.spacing);
        break;
      case LegendPosition.bottomLeft:
        alignment = Alignment.bottomLeft;
        padding = EdgeInsets.only(bottom: config.spacing, left: config.spacing);
        break;
      case LegendPosition.bottomRight:
        alignment = Alignment.bottomRight;
        padding =
            EdgeInsets.only(bottom: config.spacing, right: config.spacing);
        break;
    }

    return Stack(
      children: [
        chart,
        Align(
          alignment: alignment,
          child: Padding(
            padding: padding,
            child: legend,
          ),
        ),
      ],
    );
  }

  /// Build legend using Flex layout for bounded constraints
  Widget _buildFlexLegend(
      Widget chart, Widget legend, LegendConfig config, Widget spacing) {
    switch (config.position) {
      case LegendPosition.top:
        return Column(
          children: [legend, spacing, Flexible(child: chart)],
        );

      case LegendPosition.bottom:
        return Column(
          children: [Flexible(child: chart), spacing, legend],
        );

      case LegendPosition.left:
        return Row(
          children: [legend, spacing, Flexible(child: chart)],
        );

      case LegendPosition.right:
        return Row(
          children: [Flexible(child: chart), spacing, legend],
        );

      case LegendPosition.topLeft:
        return Column(
          children: [
            Row(
              children: [legend, Flexible(child: Container())],
            ),
            spacing,
            Flexible(child: chart),
          ],
        );

      case LegendPosition.topRight:
        return Column(
          children: [
            Row(
              children: [Flexible(child: Container()), legend],
            ),
            spacing,
            Flexible(child: chart),
          ],
        );

      case LegendPosition.bottomLeft:
        return Column(
          children: [
            Flexible(child: chart),
            spacing,
            Row(
              children: [legend, Flexible(child: Container())],
            ),
          ],
        );

      case LegendPosition.bottomRight:
        return Column(
          children: [
            Flexible(child: chart),
            spacing,
            Row(
              children: [Flexible(child: Container()), legend],
            ),
          ],
        );
    }
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
      final preconfigured = widget.xScale;
      final dataCol = widget.xColumn;
      if (preconfigured is OrdinalScale ||
          (hasBarGeometry && isColumnCategorical(dataCol, widget.data))) {
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
          final y = getNumericValue(point[dataCol]);
          if (y == null || !y.isFinite || y <= 0) continue;

          groups[x] = (groups[x] ?? 0) + y;
        }
        values = groups.values.where((v) => v.isFinite).cast<double>().toList();
      } else {
        values = widget.data
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
