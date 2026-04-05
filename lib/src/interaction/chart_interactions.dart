import 'package:flutter/material.dart';

/// Tooltip trigger mode
enum ChartTooltipTriggerMode {
  /// Tooltip triggers only when hovering directly over a data point
  point,

  /// Tooltip triggers based on X-axis position (shows all series at X position)
  /// Best for line and bar charts with time-series or categorical data
  axis,
}

/// Stroke style for crosshair lines
enum StrokeStyle {
  solid,
  dashed,
  dotted,
}

/// Interaction configuration for charts
class ChartInteraction {
  final TooltipConfig? tooltip;
  final HoverConfig? hover;
  final ClickConfig? click;
  final PanConfig? pan;
  final ZoomConfig? zoom;
  final bool enabled;

  const ChartInteraction({
    this.tooltip,
    this.hover,
    this.click,
    this.pan,
    this.zoom,
    this.enabled = true,
  });

  static const ChartInteraction none = ChartInteraction(enabled: false);
}

/// Configuration for tooltip display
class TooltipConfig {
  final TooltipBuilder? builder;

  /// Builder for multi-point tooltips (used in axis mode)
  final MultiPointTooltipBuilder? multiPointBuilder;

  final Duration showDelay;
  final Duration hideDelay;
  final bool followPointer;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final BoxShadow? shadow;

  /// Trigger mode for tooltips
  final ChartTooltipTriggerMode triggerMode;

  /// Show vertical crosshair line in axis mode
  final bool showCrosshair;

  /// Crosshair line color
  final Color? crosshairColor;

  /// Crosshair line width
  final double crosshairWidth;

  /// Crosshair line style
  final StrokeStyle crosshairStyle;

  const TooltipConfig({
    this.builder,
    this.multiPointBuilder,
    this.showDelay = const Duration(milliseconds: 100),
    this.hideDelay = const Duration(milliseconds: 300),
    this.followPointer = true,
    this.padding = const EdgeInsets.all(8.0),
    this.backgroundColor = const Color(0xFF323232),
    this.textColor = Colors.white,
    this.borderRadius = 4.0,
    this.shadow,
    this.triggerMode = ChartTooltipTriggerMode.point,
    this.showCrosshair = false,
    this.crosshairColor,
    this.crosshairWidth = 1.0,
    this.crosshairStyle = StrokeStyle.solid,
  });

  static TooltipConfig get defaultConfig => const TooltipConfig(
        shadow: BoxShadow(
          color: Color(0x44000000),
          blurRadius: 8.0,
          offset: Offset(0, 2),
        ),
      );

  /// Default config for axis-based tooltips (line/bar charts)
  static TooltipConfig get axisConfig => TooltipConfig(
        shadow: const BoxShadow(
          color: Color(0x44000000),
          blurRadius: 8.0,
          offset: Offset(0, 2),
        ),
        triggerMode: ChartTooltipTriggerMode.axis,
        showCrosshair: true,
        multiPointBuilder: DefaultTooltips.multiPoint(),
      );
}

/// Configuration for hover interactions
class HoverConfig {
  final HoverCallback? onHover;
  final HoverCallback? onExit;
  final Duration debounce;
  final double hitTestRadius;

  const HoverConfig({
    this.onHover,
    this.onExit,
    this.debounce = const Duration(milliseconds: 50),
    this.hitTestRadius = 10.0,
  });
}

/// Configuration for click interactions
class ClickConfig {
  final ClickCallback? onTap;
  final ClickCallback? onDoubleTap;
  final ClickCallback? onLongPress;
  final double hitTestRadius;

  const ClickConfig({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.hitTestRadius = 15.0,
  });
}

/// Data point information passed to interaction callbacks
class DataPointInfo {
  final Map<String, dynamic> data;
  final Offset screenPosition;
  final int dataIndex;
  final String? seriesName;
  final dynamic xValue;
  final dynamic yValue;
  final Color? color;

  const DataPointInfo({
    required this.data,
    required this.screenPosition,
    required this.dataIndex,
    this.seriesName,
    this.xValue,
    this.yValue,
    this.color,
  });

  /// Get formatted display value for tooltips
  String getDisplayValue(String column) {
    final value = data[column];
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.round().toString();
      } else {
        return value.toStringAsFixed(2);
      }
    }
    return value?.toString() ?? 'N/A';
  }
}

/// Callback typedefs for interaction events
typedef TooltipBuilder = Widget Function(DataPointInfo point);
typedef MultiPointTooltipBuilder = Widget Function(List<DataPointInfo> points);
typedef HoverCallback = void Function(DataPointInfo? point);
typedef ClickCallback = void Function(DataPointInfo point);
typedef PanCallback = void Function(PanInfo info);
typedef ZoomCallback = void Function(ZoomInfo info);

/// Configuration for pan interactions
class PanConfig {
  final bool enabled;
  final PanCallback? onPanUpdate;
  final PanCallback? onPanStart;
  final PanCallback? onPanEnd;
  final Duration throttle;
  final bool updateXDomain;
  final bool updateYDomain;

  /// Optional external controller to drive programmatic panning.
  /// The widget will listen/unlisten to this in its lifecycle.
  final PanController? controller;

  /// Whether to clamp the pan to the boundaries of the chart.
  final bool boundaryClampingX;
  final bool boundaryClampingY;

  const PanConfig({
    this.enabled = true,
    this.onPanUpdate,
    this.onPanStart,
    this.onPanEnd,
    this.throttle = const Duration(milliseconds: 100),
    this.updateXDomain = false,
    this.updateYDomain = false,
    this.controller,
    this.boundaryClampingX = false,
    this.boundaryClampingY = false,
  });
}

/// Pan state information
enum PanState { start, update, end }

/// Zoom interaction lifecycle states
enum ZoomState { start, update, end }

/// Information about the current pan operation
class PanInfo {
  /// Current visible X range (data coordinates)
  final double? visibleMinX;
  final double? visibleMaxX;

  /// Current visible Y range (data coordinates)
  final double? visibleMinY;
  final double? visibleMaxY;

  /// Pan state (start, update, end)
  final PanState state;

  /// Pan delta from last position (screen coordinates)
  final Offset? delta;

  /// Total pan distance from start (screen coordinates)
  final Offset? totalDelta;

  const PanInfo({
    this.visibleMinX,
    this.visibleMaxX,
    this.visibleMinY,
    this.visibleMaxY,
    required this.state,
    this.delta,
    this.totalDelta,
  });

  @override
  String toString() {
    return 'PanInfo(xRange: [$visibleMinX, $visibleMaxX], yRange: [$visibleMinY, $visibleMaxY], state: $state)';
  }
}

/// Controller for programmatic chart panning.
///
/// Create an instance and pass it to [PanConfig.controller] to enable
/// programmatic pan operations via [panTo] and [panReset].
///
/// The controller must be disposed when no longer needed:
/// ```dart
/// final controller = PanController();
/// // ... use it
/// controller.dispose(); // Clean up
/// ```
class PanController extends ChangeNotifier {
  PanInfo? _targetPan;

  PanInfo? get targetPan => _targetPan;

  /// Programmatically pan the chart to the specified visible range.
  ///
  /// The [info] parameter should contain the desired visible X/Y ranges
  /// and an appropriate [PanState] (typically [PanState.update] or [PanState.end]).
  void panTo(PanInfo info) {
    _targetPan = info;
    notifyListeners();
  }

  /// Reset the pan to the original (unpanned) chart view.
  ///
  /// This restores the chart to its initial domain boundaries.
  void panReset() {
    _targetPan = null;
    notifyListeners();
  }
}

/// Default tooltip builders for common use cases
class DefaultTooltips {
  /// Simple single-value tooltip
  static Text Function(DataPointInfo point) simple(String column) {
    return (DataPointInfo point) {
      return Text(
        point.getDisplayValue(column),
        style: const TextStyle(color: Colors.white),
      );
    };
  }

  /// Multi-column tooltip with labels
  static Column Function(DataPointInfo point) multi(
    Map<String, String> columnLabels,
  ) {
    return (DataPointInfo point) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnLabels.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              '${entry.value}: ${point.getDisplayValue(entry.key)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }).toList(),
      );
    };
  }

  /// Rich tooltip with custom formatting
  static Column Function(DataPointInfo point) rich({
    required String title,
    required Map<String, String> fields,
    Color? accentColor,
  }) {
    return (DataPointInfo point) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accentColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          ...fields.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${entry.value}: ',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    point.getDisplayValue(entry.key),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    };
  }

  /// Multi-point tooltip for axis mode (shows all series at X position)
  ///
  /// This is the default tooltip builder for axis-based tooltips.
  /// It shows all series values at a given X position, with color indicators.
  static Column Function(List<DataPointInfo> points) multiPoint({
    String? xColumn,
    String? yColumn,
  }) {
    return (List<DataPointInfo> points) {
      if (points.isEmpty) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'No data',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        );
      }

      // Get X value from first point (all should have same X)
      final xValue =
          xColumn != null ? points.first.getDisplayValue(xColumn) : null;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show X value as header if provided
          if (xValue != null)
            Text(
              xValue,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          if (xValue != null) const SizedBox(height: 6),
          // Show each series
          ...points.map((point) {
            final seriesName = point.seriesName ?? 'Series';
            // Fallback to point's actual yValue if yColumn is not specified
            final yValue = yColumn != null
                ? point.getDisplayValue(yColumn)
                : (point.yValue?.toString() ??
                    point.data['y']?.toString() ??
                    'N/A');
            final color = point.color ?? Colors.blue;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color indicator
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Series name and value
                  Text(
                    '$seriesName: ',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    yValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    };
  }
}

/// Axes that can respond to zooming
enum ZoomAxis { x, y, both }

/// Configuration for zoom interactions
class ZoomConfig {
  final bool enabled;
  final ZoomAxis axes;
  final double maxScale;
  final double minScale;
  final double wheelSensitivity;
  final double buttonStep;
  final bool showButtons;
  final Alignment buttonAlignment;
  final EdgeInsets buttonPadding;
  final ZoomCallback? onZoomStart;
  final ZoomCallback? onZoomUpdate;
  final ZoomCallback? onZoomEnd;

  const ZoomConfig({
    this.enabled = true,
    this.axes = ZoomAxis.x,
    this.maxScale = 16.0,
    this.minScale = 1.0,
    this.wheelSensitivity = 0.0015,
    this.buttonStep = 1.4,
    this.showButtons = true,
    this.buttonAlignment = Alignment.bottomRight,
    this.buttonPadding = const EdgeInsets.all(12),
    this.onZoomStart,
    this.onZoomUpdate,
    this.onZoomEnd,
  })  : assert(
          maxScale >= minScale && maxScale > 0 && minScale > 0,
          'Zoom scales must be positive and max >= min',
        ),
        assert(
          wheelSensitivity >= 0.0005 && wheelSensitivity <= 0.0035,
          'wheelSensitivity must be between 0.0005 and 0.0035 (inclusive); '
          'received $wheelSensitivity',
        );
}

/// Information emitted during zoom interactions
class ZoomInfo {
  final double? visibleMinX;
  final double? visibleMaxX;
  final double? visibleMinY;
  final double? visibleMaxY;
  final double? scaleX;
  final double? scaleY;
  final ZoomState state;

  const ZoomInfo({
    this.visibleMinX,
    this.visibleMaxX,
    this.visibleMinY,
    this.visibleMaxY,
    this.scaleX,
    this.scaleY,
    required this.state,
  });

  @override
  String toString() {
    return 'ZoomInfo(xRange: [$visibleMinX, $visibleMaxX], '
        'yRange: [$visibleMinY, $visibleMaxY], '
        'scaleX: $scaleX, scaleY: $scaleY, state: $state)';
  }
}
