import 'package:flutter/material.dart';

/// Interaction configuration for charts
class ChartInteraction {
  final TooltipConfig? tooltip;
  final HoverConfig? hover;
  final ClickConfig? click;
  final bool enabled;

  const ChartInteraction({
    this.tooltip,
    this.hover,
    this.click,
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
        children:
            columnLabels.entries.map((entry) {
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
