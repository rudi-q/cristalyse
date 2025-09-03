import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/legend.dart';
import '../themes/chart_theme.dart';

/// Widget that renders a chart legend
class LegendWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Create default text style using theme colors
    final defaultTextStyle = TextStyle(fontSize: 12, color: theme.axisColor);

    // Merge with custom text style, preserving theme color if no color is specified
    final effectiveTextStyle = config.textStyle != null
        ? defaultTextStyle.merge(config.textStyle!)
        : defaultTextStyle;

    Widget legendContent;

    if (config.effectiveOrientation == LegendOrientation.horizontal) {
      legendContent = _buildHorizontalLegend(effectiveTextStyle);
    } else {
      legendContent = _buildVerticalLegend(effectiveTextStyle);
    }

    // Wrap with background if specified
    if (config.backgroundColor != null) {
      legendContent = Container(
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
        padding: config.padding,
        child: legendContent,
      );
    } else {
      legendContent = Padding(
        padding: config.padding,
        child: legendContent,
      );
    }

    return legendContent;
  }

  Widget _buildHorizontalLegend(TextStyle textStyle) {
    return Wrap(
      spacing: config.itemSpacing,
      runSpacing: config.itemSpacing / 2,
      children: items.map((item) => _buildLegendItem(item, textStyle)).toList(),
    );
  }

  Widget _buildVerticalLegend(TextStyle textStyle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: config.itemSpacing),
                child: _buildLegendItem(item, textStyle),
              ))
          .toList(),
    );
  }

  Widget _buildLegendItem(LegendItem item, TextStyle textStyle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSymbol(item),
        SizedBox(width: config.itemSpacing / 2),
        Text(
          item.label,
          style: textStyle,
        ),
      ],
    );
  }

  Widget _buildSymbol(LegendItem item) {
    final size = config.symbolSize;

    switch (item.symbol) {
      case LegendSymbol.circle:
      case LegendSymbol.auto: // Default to circle for auto
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        );

      case LegendSymbol.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(2),
          ),
        );

      case LegendSymbol.line:
        return Container(
          width: size + 4, // Slightly wider for lines
          height: 3,
          decoration: BoxDecoration(
            color: item.color,
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
