import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/legend.dart';
import '../themes/chart_theme.dart';

/// Widget that renders a chart legend
class LegendWidget extends StatefulWidget {
  final List<LegendItem> items;
  final LegendConfig config;
  final ChartTheme theme;

  const LegendWidget({
    super.key,
    required this.items,
    required this.config,
    required this.theme,
  });

  @override
  State<LegendWidget> createState() => _LegendWidgetState();
}

class _LegendWidgetState extends State<LegendWidget> {
  // Internal state for hidden categories (only used if not externally managed)
  final Set<String> _internalHiddenCategories = {};

  Set<String> get _effectiveHiddenCategories {
    // Use external state if provided, otherwise use internal state
    return widget.config.hiddenCategories ?? _internalHiddenCategories;
  }

  void _handleToggle(String category) {
    if (!widget.config.interactive) return;

    final isCurrentlyHidden = _effectiveHiddenCategories.contains(category);
    final willBeVisible = isCurrentlyHidden;

    // If using external state management, just call the callback
    if (widget.config.hiddenCategories != null) {
      widget.config.onToggle?.call(category, willBeVisible);
    } else {
      // Use internal state management
      setState(() {
        if (isCurrentlyHidden) {
          _internalHiddenCategories.remove(category);
        } else {
          _internalHiddenCategories.add(category);
        }
      });
      widget.config.onToggle?.call(category, willBeVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    // Create default text style using theme colors
    final defaultTextStyle =
        TextStyle(fontSize: 12, color: widget.theme.axisColor);

    // Merge with custom text style, preserving theme color if no color is specified
    final effectiveTextStyle = widget.config.textStyle != null
        ? defaultTextStyle.merge(widget.config.textStyle!)
        : defaultTextStyle;

    Widget legendContent;

    if (widget.config.effectiveOrientation == LegendOrientation.horizontal) {
      legendContent = _buildHorizontalLegend(effectiveTextStyle);
    } else {
      legendContent = _buildVerticalLegend(effectiveTextStyle);
    }

    // Wrap with background if specified
    if (widget.config.backgroundColor != null) {
      legendContent = Container(
        decoration: BoxDecoration(
          color: widget.config.backgroundColor,
          borderRadius: BorderRadius.circular(widget.config.borderRadius),
        ),
        padding: widget.config.padding,
        child: legendContent,
      );
    } else {
      legendContent = Padding(
        padding: widget.config.padding,
        child: legendContent,
      );
    }

    return legendContent;
  }

  Widget _buildHorizontalLegend(TextStyle textStyle) {
    return Wrap(
      spacing: widget.config.itemSpacing,
      runSpacing: widget.config.itemSpacing / 2,
      children: widget.items
          .map((item) => _buildLegendItem(item, textStyle))
          .toList(),
    );
  }

  Widget _buildVerticalLegend(TextStyle textStyle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.items
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: widget.config.itemSpacing),
                child: _buildLegendItem(item, textStyle),
              ))
          .toList(),
    );
  }

  Widget _buildLegendItem(LegendItem item, TextStyle textStyle) {
    final isHidden = _effectiveHiddenCategories.contains(item.label);
    final isActive = !isHidden;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSymbol(item, isActive),
        SizedBox(width: widget.config.itemSpacing / 2),
        Text(
          item.label,
          style: textStyle.copyWith(
            decoration: isHidden ? TextDecoration.lineThrough : null,
            decorationThickness: 2.0,
          ),
        ),
      ],
    );

    // Wrap with animated opacity for smooth transitions
    content = AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: content,
    );

    // Add tap handling if interactive
    if (widget.config.interactive) {
      content = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _handleToggle(item.label),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildSymbol(LegendItem item, bool isActive) {
    final size = widget.config.symbolSize;
    final effectiveColor =
        isActive ? item.color : item.color.withValues(alpha: 0.3);

    switch (item.symbol) {
      case LegendSymbol.circle:
      case LegendSymbol.auto: // Default to circle for auto
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: effectiveColor,
            shape: BoxShape.circle,
          ),
        );

      case LegendSymbol.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );

      case LegendSymbol.line:
        return Container(
          width: size + 4, // Slightly wider for lines
          height: 3,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(1.5),
          ),
          margin: EdgeInsets.symmetric(vertical: (size - 3) / 2),
        );
    }
  }
}

/// Utility class to generate legend items from chart data and configuration
class LegendGenerator {
  /// Generate legend items from chart data and color column
  static List<LegendItem> generateFromData({
    required List<Map<String, dynamic>> data,
    required String? colorColumn,
    required List<Color> colorPalette,
    required List<Geometry> geometries,
  }) {
    if (colorColumn == null || data.isEmpty || colorPalette.isEmpty) return [];

    // Extract unique categories from the color column
    final categories = data
        .map((d) => d[colorColumn]?.toString())
        .where((value) => value != null)
        .cast<String>()
        .toSet()
        .toList();

    if (categories.isEmpty) return [];

    // Determine the appropriate symbol based on geometries
    final symbol = _determineSymbolFromGeometries(geometries);

    // Create legend items
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final color = colorPalette[index % colorPalette.length];

      return LegendItem(
        label: category,
        color: color,
        symbol: symbol,
      );
    }).toList();
  }

  /// Determine the most appropriate symbol based on chart geometries
  static LegendSymbol _determineSymbolFromGeometries(
      List<Geometry> geometries) {
    if (geometries.isEmpty) return LegendSymbol.circle;

    // Priority: check for specific geometry types
    for (final geometry in geometries) {
      if (geometry is LineGeometry || geometry is AreaGeometry) {
        return LegendSymbol.line;
      } else if (geometry is BarGeometry) {
        return LegendSymbol.square;
      } else if (geometry is PointGeometry || geometry is BubbleGeometry) {
        return LegendSymbol.circle;
      }
    }

    // Default fallback
    return LegendSymbol.circle;
  }
}
