import 'package:flutter/material.dart';

/// Position options for chart legends
enum LegendPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
  floating, // Free-floating legend with custom positioning
}

/// Orientation for legend items
enum LegendOrientation {
  horizontal,
  vertical,
  auto, // Determined by position
}

/// Symbol shapes for legend items
enum LegendSymbol {
  auto, // Match chart geometry type
  circle,
  square,
  line,
}

/// Represents a single item in the legend
class LegendItem {
  final String label;
  final Color color;
  final LegendSymbol symbol;

  const LegendItem({
    required this.label,
    required this.color,
    this.symbol = LegendSymbol.auto,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegendItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          color == other.color &&
          symbol == other.symbol;

  @override
  int get hashCode => label.hashCode ^ color.hashCode ^ symbol.hashCode;
}

/// Configuration for chart legends
class LegendConfig {
  final LegendPosition position;
  final LegendOrientation orientation;
  final double spacing; // Space between legend and chart
  final double itemSpacing; // Space between legend items
  final double symbolSize;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final double borderRadius;

  // Floating legend configuration
  final Offset? floatingOffset; // Absolute position when position is floating
  final bool floatingDraggable; // Whether floating legend is draggable

  const LegendConfig({
    this.position = LegendPosition.topRight,
    this.orientation = LegendOrientation.auto,
    this.spacing = 12.0,
    this.itemSpacing = 8.0,
    this.symbolSize = 12.0,
    this.textStyle,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8.0),
    this.borderRadius = 4.0,
    this.floatingOffset,
    this.floatingDraggable = false,
  });

  /// Get the effective orientation based on position
  LegendOrientation get effectiveOrientation {
    if (orientation != LegendOrientation.auto) return orientation;

    switch (position) {
      case LegendPosition.left:
      case LegendPosition.right:
      case LegendPosition.topLeft:
      case LegendPosition.topRight:
      case LegendPosition.bottomLeft:
      case LegendPosition.bottomRight:
        return LegendOrientation.vertical;
      case LegendPosition.top:
      case LegendPosition.bottom:
        return LegendOrientation.horizontal;
      case LegendPosition.floating:
        return LegendOrientation.vertical; // Default for floating
    }
  }

  /// Check if legend should be positioned on the right side
  bool get isRightSide => [
        LegendPosition.right,
        LegendPosition.topRight,
        LegendPosition.bottomRight,
      ].contains(position);

  /// Check if legend should be positioned on the left side
  bool get isLeftSide => [
        LegendPosition.left,
        LegendPosition.topLeft,
        LegendPosition.bottomLeft,
      ].contains(position);

  /// Check if legend should be positioned on the top
  bool get isTopSide => [
        LegendPosition.top,
        LegendPosition.topLeft,
        LegendPosition.topRight,
      ].contains(position);

  /// Check if legend should be positioned on the bottom
  bool get isBottomSide => [
        LegendPosition.bottom,
        LegendPosition.bottomLeft,
        LegendPosition.bottomRight,
      ].contains(position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegendConfig &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          orientation == other.orientation &&
          spacing == other.spacing &&
          itemSpacing == other.itemSpacing &&
          symbolSize == other.symbolSize &&
          textStyle == other.textStyle &&
          backgroundColor == other.backgroundColor &&
          padding == other.padding &&
          borderRadius == other.borderRadius &&
          floatingOffset == other.floatingOffset &&
          floatingDraggable == other.floatingDraggable;

  @override
  int get hashCode =>
      position.hashCode ^
      orientation.hashCode ^
      spacing.hashCode ^
      itemSpacing.hashCode ^
      symbolSize.hashCode ^
      textStyle.hashCode ^
      backgroundColor.hashCode ^
      padding.hashCode ^
      borderRadius.hashCode ^
      floatingOffset.hashCode ^
      floatingDraggable.hashCode;

  LegendConfig copyWith({
    LegendPosition? position,
    LegendOrientation? orientation,
    double? spacing,
    double? itemSpacing,
    double? symbolSize,
    TextStyle? textStyle,
    Color? backgroundColor,
    EdgeInsets? padding,
    double? borderRadius,
    Offset? floatingOffset,
    bool? floatingDraggable,
  }) {
    return LegendConfig(
      position: position ?? this.position,
      orientation: orientation ?? this.orientation,
      spacing: spacing ?? this.spacing,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      symbolSize: symbolSize ?? this.symbolSize,
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      floatingOffset: floatingOffset ?? this.floatingOffset,
      floatingDraggable: floatingDraggable ?? this.floatingDraggable,
    );
  }
}
