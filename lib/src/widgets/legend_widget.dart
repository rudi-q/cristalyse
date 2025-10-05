import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/legend.dart';
import '../core/scale.dart';
import '../themes/chart_theme.dart';

/// Container for rendering bubble size guide in legend
class BubbleSizeGuide {
  final String title;
  final Color color;
  final SizeScale sizeScale;

  const BubbleSizeGuide({
    required this.title,
    required this.color,
    required this.sizeScale,
  });
}

/// Widget that renders a chart legend
class LegendWidget extends StatefulWidget {
  final List<LegendItem> items;
  final LegendConfig config;
  final ChartTheme theme;
  final BubbleSizeGuide? bubbleGuide;

  // Bubble guide layout constants
  static const double _bubbleTitleSpacing = 6.0;
  static const double _bubbleLabelSpacing = 4.0;
  static const double _bubbleLabelFontSizeRatio = 0.85; // 85% of main text size

  const LegendWidget({
    super.key,
    required this.items,
    required this.config,
    required this.theme,
    this.bubbleGuide,
  });

  @override
  State<LegendWidget> createState() => _LegendWidgetState();
}

class _LegendWidgetState extends State<LegendWidget> {
  // Internal state for hidden categories (only used if not externally managed)
  final Set<String> _internalHiddenCategories = {};

  @override
  void initState() {
    super.initState();
    // Seed internal state from hiddenCategories if provided without external control
    if (widget.config.hiddenCategories != null &&
        widget.config.onToggle == null) {
      _internalHiddenCategories.addAll(widget.config.hiddenCategories!);
    }
  }

  @override
  void didUpdateWidget(LegendWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state if hiddenCategories changed and no external control
    if (widget.config.hiddenCategories != oldWidget.config.hiddenCategories &&
        widget.config.hiddenCategories != null &&
        widget.config.onToggle == null) {
      _internalHiddenCategories.clear();
      _internalHiddenCategories.addAll(widget.config.hiddenCategories!);
    }
  }

  Set<String> get _effectiveHiddenCategories {
    // Use external state only if BOTH hiddenCategories and onToggle are provided
    final external = widget.config.hiddenCategories;
    if (external != null && widget.config.onToggle != null) {
      return external;
    }
    // Otherwise use internal state management
    return _internalHiddenCategories;
  }

  void _handleToggle(String category) {
    if (!widget.config.interactive) return;

    final isCurrentlyHidden = _effectiveHiddenCategories.contains(category);
    final willBeVisible = isCurrentlyHidden;

    // Determine if we're using external state management
    final external = widget.config.hiddenCategories;
    final usesExternalState =
        external != null && widget.config.onToggle != null;

    if (usesExternalState) {
      // External state management: delegate to callback
      widget.config.onToggle!(category, willBeVisible);
      return;
    }

    // Internal state management: mutate local state
    setState(() {
      if (isCurrentlyHidden) {
        _internalHiddenCategories.remove(category);
      } else {
        _internalHiddenCategories.add(category);
      }
    });

    // Optionally notify via callback (for user-side logging/analytics)
    widget.config.onToggle?.call(category, willBeVisible);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.bubbleGuide == null) {
      return const SizedBox.shrink();
    }

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

  /// Check if data series items should be stacked vertically next to bubble guide
  bool _shouldStackColorItems(TextStyle textStyle) {
    if (widget.bubbleGuide == null || widget.items.isEmpty) return false;

    // Calculate bubble guide height
    final maxBubbleRadius = widget.bubbleGuide!.sizeScale.scale(
      widget.bubbleGuide!.sizeScale.domain[1],
    );
    final maxBubbleDiameter = maxBubbleRadius * 2;

    // fontSize is guaranteed non-null from effectiveTextStyle in build()
    final baseFontSize = textStyle.fontSize!;
    final bubbleLabelFontSize =
        baseFontSize * LegendWidget._bubbleLabelFontSizeRatio;

    final bubbleGuideHeight = baseFontSize +
        LegendWidget._bubbleTitleSpacing +
        maxBubbleDiameter +
        LegendWidget._bubbleLabelSpacing +
        bubbleLabelFontSize;

    // Calculate stacked color items height
    final itemHeight = widget.config.symbolSize > baseFontSize
        ? widget.config.symbolSize
        : baseFontSize;
    final totalItemsHeight = (itemHeight * widget.items.length) +
        (widget.config.itemSpacing * (widget.items.length - 1));

    return totalItemsHeight <= bubbleGuideHeight;
  }

  Widget _buildHorizontalLegend(TextStyle textStyle) {
    final widgets = <Widget>[];

    // Add bubble size guide first (left side) if present
    if (widget.bubbleGuide != null) {
      widgets.add(_buildHorizontalBubbleGuide(textStyle));
    }

    // Add color legend items - stack if there's a bubble size guide and
    //they fit, otherwise wrap
    if (widget.items.isNotEmpty) {
      final shouldStack = _shouldStackColorItems(textStyle);

      widgets.add(
        shouldStack
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.items
                    .map((item) => Padding(
                          padding: EdgeInsets.only(
                              bottom: widget.config.itemSpacing / 2),
                          child: _buildLegendItem(item, textStyle),
                        ))
                    .toList(),
              )
            : Wrap(
                spacing: widget.config.itemSpacing,
                runSpacing: widget.config.itemSpacing / 2,
                children: widget.items
                    .map((item) => _buildLegendItem(item, textStyle))
                    .toList(),
              ),
      );
    }

    return Wrap(
      spacing: widget.config.itemSpacing * 2,
      runSpacing: widget.config.itemSpacing,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widgets,
    );
  }

  Widget _buildVerticalLegend(TextStyle textStyle) {
    final widgets = <Widget>[];

    // Add bubble size guide first (top) if present
    if (widget.bubbleGuide != null) {
      widgets.add(_buildVerticalBubbleGuide(textStyle));
      if (widget.items.isNotEmpty) {
        widgets.add(SizedBox(height: widget.config.itemSpacing));
      }
    }

    // Add color legend items
    widgets.addAll(
      widget.items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: widget.config.itemSpacing),
            child: _buildLegendItem(item, textStyle),
          )),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
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

  /// Build horizontal bubble size guide (bubbles in a row, min to max, left to right)
  Widget _buildHorizontalBubbleGuide(TextStyle textStyle) {
    final guide = widget.bubbleGuide!;
    final domain = guide.sizeScale.domain;

    if (domain.isEmpty || domain.length < 2) {
      return const SizedBox.shrink();
    }

    final minValue = domain[0];
    final maxValue = domain[1];
    final midValue = (minValue + maxValue) / 2; // Middle of domain

    // Format values using sizeScale's formatter
    final formatValue = guide.sizeScale.formatLabel;

    // Get actual bubble sizes by mapping domain values through the scale
    // These are the exact sizes that will be rendered in the chart
    final displayMinSize = guide.sizeScale.scale(minValue);
    final displayMaxSize = guide.sizeScale.scale(maxValue);
    final displayMidSize = guide.sizeScale.scale(midValue);

    // fontSize is guaranteed non-null from effectiveTextStyle in build()
    final baseFontSize = textStyle.fontSize!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          guide.title,
          style: textStyle.copyWith(
            fontSize: baseFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: LegendWidget._bubbleTitleSpacing),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bubble guide always shows three bubbles: min, median, and max from the domain
            _buildBubbleItem(
                displayMinSize, formatValue(minValue), guide.color, textStyle),
            SizedBox(width: widget.config.itemSpacing),
            _buildBubbleItem(
                displayMidSize, formatValue(midValue), guide.color, textStyle),
            SizedBox(width: widget.config.itemSpacing),
            _buildBubbleItem(
                displayMaxSize, formatValue(maxValue), guide.color, textStyle),
          ],
        ),
      ],
    );
  }

  /// Build vertical bubble size guide (bubbles in a column, min to max, top to bottom)
  Widget _buildVerticalBubbleGuide(TextStyle textStyle) {
    final guide = widget.bubbleGuide!;
    final domain = guide.sizeScale.domain;

    if (domain.isEmpty || domain.length < 2) {
      return const SizedBox.shrink();
    }

    final minValue = domain[0];
    final maxValue = domain[1];
    final midValue = (minValue + maxValue) / 2; // Middle of domain

    // Format values using sizeScale's formatter
    final formatValue = guide.sizeScale.formatLabel;

    // Get actual bubble sizes by mapping domain values through the scale
    // These are the exact sizes that will be rendered in the chart
    final displayMinSize = guide.sizeScale.scale(minValue);
    final displayMaxSize = guide.sizeScale.scale(maxValue);
    final displayMidSize = guide.sizeScale.scale(midValue);

    final maxDiameter = displayMaxSize * 2;

    // fontSize is guaranteed non-null from effectiveTextStyle in build()
    final baseFontSize = textStyle.fontSize!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          guide.title,
          style: textStyle.copyWith(
            fontSize: baseFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Bubble guide always shows three bubbles: min, median, and max from the domain
        SizedBox(height: LegendWidget._bubbleTitleSpacing),
        _buildBubbleItemWithAlignment(displayMinSize, formatValue(minValue),
            guide.color, maxDiameter, textStyle),
        SizedBox(height: widget.config.itemSpacing / 4),
        _buildBubbleItemWithAlignment(displayMidSize, formatValue(midValue),
            guide.color, maxDiameter, textStyle),
        SizedBox(height: widget.config.itemSpacing / 4),
        _buildBubbleItemWithAlignment(displayMaxSize, formatValue(maxValue),
            guide.color, maxDiameter, textStyle),
      ],
    );
  }

  /// Build a single bubble item (for horizontal layout)
  Widget _buildBubbleItem(
      double size, String value, Color color, TextStyle textStyle) {
    final diameter = size * 2;
    // fontSize is guaranteed non-null from effectiveTextStyle in build()
    final baseFontSize = textStyle.fontSize!;
    final labelFontSize = baseFontSize * LegendWidget._bubbleLabelFontSizeRatio;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        SizedBox(height: LegendWidget._bubbleLabelSpacing),
        Text(
          value,
          style: textStyle.copyWith(
            fontSize: labelFontSize,
          ),
        ),
      ],
    );
  }

  /// Build a single bubble item with alignment (for vertical layout)
  Widget _buildBubbleItemWithAlignment(double size, String value, Color color,
      double maxDiameter, TextStyle textStyle) {
    final diameter = size * 2;
    // fontSize is guaranteed non-null from effectiveTextStyle in build()
    final baseFontSize = textStyle.fontSize!;
    final labelFontSize = baseFontSize * LegendWidget._bubbleLabelFontSizeRatio;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: maxDiameter + 8.0,
          height: diameter + 8.0,
          alignment: Alignment.center,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: textStyle.copyWith(
            fontSize: labelFontSize,
          ),
        ),
      ],
    );
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

  /// Extract bubble size guide data from geometries
  static BubbleSizeGuide? extractBubbleGuide({
    required List<Geometry> geometries,
    required SizeScale? sizeScale,
  }) {
    if (sizeScale == null) return null;

    // Find first BubbleGeometry with a title
    BubbleGeometry? bubbleGeometry;
    for (final geometry in geometries.whereType<BubbleGeometry>()) {
      if (geometry.title != null) {
        bubbleGeometry = geometry;
        break;
      }
    }

    if (bubbleGeometry == null) {
      return null;
    }

    return BubbleSizeGuide(
      title: bubbleGeometry.title!,
      color: bubbleGeometry.color ?? Colors.grey,
      sizeScale: sizeScale,
    );
  }
}
