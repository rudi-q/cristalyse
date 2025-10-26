import 'package:flutter/material.dart';

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
  final Duration showDelay;
  final Duration hideDelay;
  final bool followPointer;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final BoxShadow? shadow;

  const TooltipConfig({
    this.builder,
    this.showDelay = const Duration(milliseconds: 100),
    this.hideDelay = const Duration(milliseconds: 300),
    this.followPointer = true,
    this.padding = const EdgeInsets.all(8.0),
    this.backgroundColor = const Color(0xFF323232),
    this.textColor = Colors.white,
    this.borderRadius = 4.0,
    this.shadow,
  });

  static TooltipConfig get defaultConfig => const TooltipConfig(
        shadow: BoxShadow(
          color: Color(0x44000000),
          blurRadius: 8.0,
          offset: Offset(0, 2),
        ),
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
typedef HoverCallback = void Function(DataPointInfo? point);
typedef ClickCallback = void Function(DataPointInfo point);
typedef PanCallback = void Function(PanInfo info);

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

  const PanConfig({
    this.enabled = true,
    this.onPanUpdate,
    this.onPanStart,
    this.onPanEnd,
    this.throttle = const Duration(milliseconds: 100),
    this.updateXDomain = false,
    this.updateYDomain = false,
    this.controller,
  });
}

/// Pan state information
enum PanState { start, update, end }

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

class ZoomConfig {
  final bool updateXDomain;
  final bool updateYDomain;

  const ZoomConfig({
    this.updateXDomain = false,
    this.updateYDomain = false,
  });
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
}
