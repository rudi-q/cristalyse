import 'package:flutter/material.dart';

import '../export/chart_export.dart';
import '../interaction/chart_interactions.dart';
import '../themes/chart_theme.dart';
import '../widgets/animated_chart_widget.dart';
import 'geometry.dart';
import 'label_formatter.dart';
import 'legend.dart';
import 'scale.dart';

/// Main chart class implementing grammar of graphics API
class CristalyseChart {
  List<Map<String, dynamic>> _data = [];
  String? _xColumn;
  String? _yColumn;

  /// Secondary Y-axis column
  String? _y2Column;
  String? _colorColumn;
  String? _sizeColumn;

  /// Pie chart specific mappings
  String? _pieValueColumn;
  String? _pieCategoryColumn;

  /// Heat map specific mappings
  String? _heatMapXColumn;
  String? _heatMapYColumn;
  String? _heatMapValueColumn;

  final List<Geometry> _geometries = [];
  Scale? _xScale;
  Scale? _yScale;

  /// Secondary Y-axis scale
  Scale? _y2Scale;
  ColorScale? _colorScale;
  SizeScale? _sizeScale;
  ChartTheme _theme = ChartTheme.defaultTheme();

  // Animation properties
  Duration _animationDuration = const Duration(milliseconds: 300);
  Curve _animationCurve = Curves.easeInOut;

  bool _coordFlipped = false;

  /// Interaction configuration
  ChartInteraction _interaction = ChartInteraction.none;

  /// Legend configuration
  LegendConfig? _legendConfig;

  /// Set the data source for the chart
  ///
  /// Example:
  /// ```dart
  /// CristalyseChart().data([
  ///   {'x': 1, 'y': 2, 'y2': 85, 'category': 'A'},
  ///   {'x': 2, 'y': 3, 'y2': 92, 'category': 'B'},
  /// ])
  /// ```
  CristalyseChart data(List<Map<String, dynamic>> data) {
    _data = data;
    return this;
  }

  /// Define aesthetic mappings between data columns and visual properties
  ///
  /// Example:
  /// ```dart
  /// chart.mapping(x: 'date', y: 'revenue', color: 'category')
  /// ```
  CristalyseChart mapping({String? x, String? y, String? color, String? size}) {
    _xColumn = x;
    _yColumn = y;
    _colorColumn = color;
    _sizeColumn = size;
    return this;
  }

  /// Map data to secondary Y-axis (right side)
  ///
  /// Example:
  /// ```dart
  /// chart.mappingY2('conversion_rate')
  /// ```
  CristalyseChart mappingY2(String column) {
    _y2Column = column;
    return this;
  }

  /// Map data for pie charts
  ///
  /// Example:
  /// ```dart
  /// chart.mappingPie(value: 'revenue', category: 'department')
  /// ```
  CristalyseChart mappingPie({String? value, String? category}) {
    _pieValueColumn = value;
    _pieCategoryColumn = category;
    return this;
  }

  /// Map data for heat maps
  ///
  /// Example:
  /// ```dart
  /// chart.mappingHeatMap(x: 'day', y: 'hour', value: 'temperature')
  /// ```
  CristalyseChart mappingHeatMap({String? x, String? y, String? value}) {
    _heatMapXColumn = x;
    _heatMapYColumn = y;
    _heatMapValueColumn = value;
    return this;
  }

  /// Add scatter plot points
  ///
  /// Example:
  /// ```dart
  /// chart.geomPoint(size: 5.0, alpha: 0.7, yAxis: YAxis.secondary)
  /// ```
  CristalyseChart geomPoint({
    double? size,
    Color? color,
    double? alpha,
    PointShape? shape,
    double? borderWidth,
    YAxis? yAxis,
  }) {
    _geometries.add(
      PointGeometry(
        size: size,
        color: color,
        alpha: alpha ?? 1.0,
        shape: shape ?? PointShape.circle,
        borderWidth: borderWidth ?? 0.0,
        yAxis: yAxis ?? YAxis.primary,
      ),
    );
    return this;
  }

  /// Add line chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomLine(strokeWidth: 2.0, alpha: 0.8, yAxis: YAxis.secondary)
  /// ```
  CristalyseChart geomLine({
    double? strokeWidth,
    Color? color,
    double? alpha,
    LineStyle? style,
    YAxis? yAxis,
  }) {
    _geometries.add(
      LineGeometry(
        strokeWidth: strokeWidth ?? 2.0,
        color: color,
        alpha: alpha ?? 1.0,
        style: style ?? LineStyle.solid,
        yAxis: yAxis ?? YAxis.primary,
      ),
    );
    return this;
  }

  /// Add area chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomArea(strokeWidth: 2.0, alpha: 0.3, yAxis: YAxis.secondary)
  /// ```
  CristalyseChart geomArea({
    double? strokeWidth,
    Color? color,
    double? alpha,
    LineStyle? style,
    bool? fillArea,
    YAxis? yAxis,
  }) {
    _geometries.add(
      AreaGeometry(
        strokeWidth: strokeWidth ?? 2.0,
        color: color,
        alpha: alpha ?? 0.3,
        style: style ?? LineStyle.solid,
        fillArea: fillArea ?? true,
        yAxis: yAxis ?? YAxis.primary,
      ),
    );
    return this;
  }

  /// Add bar chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomBar(width: 0.8, orientation: BarOrientation.vertical, yAxis: YAxis.secondary)
  /// ```
  CristalyseChart geomBar({
    double? width,
    Color? color,
    double? alpha,
    BarOrientation? orientation,
    BarStyle? style,
    BorderRadius? borderRadius,
    double? borderWidth,
    YAxis? yAxis,
  }) {
    final barGeom = BarGeometry(
      width: width ?? 0.8,
      color: color,
      alpha: alpha ?? 1.0,
      orientation: orientation ?? BarOrientation.vertical,
      style: style ?? BarStyle.grouped,
      borderRadius: borderRadius,
      borderWidth: borderWidth ?? 0.0,
      yAxis: yAxis ?? YAxis.primary,
    );
    _geometries.add(barGeom);
    return this;
  }

  /// Add pie chart
  ///
  /// Example:
  /// ```dart
  /// chart.geomPie(
  ///   outerRadius: 120.0,
  ///   innerRadius: 40.0, // For donut chart
  ///   showLabels: true,
  ///   strokeWidth: 2.0,
  ///   labels: (value) => NumberFormat.currency(symbol: '$').format(value),
  /// )
  /// ```
  CristalyseChart geomPie({
    double? innerRadius,
    double? outerRadius,
    Color? strokeColor,
    double? strokeWidth,
    bool? showLabels,
    TextStyle? labelStyle,
    double? labelRadius,
    double? startAngle,
    bool? showPercentages,
    bool? explodeSlices,
    double? explodeDistance,
    LabelCallback? labels,
  }) {
    _geometries.add(
      PieGeometry(
        innerRadius: innerRadius ?? 0.0,
        outerRadius: outerRadius ?? 100.0,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth ?? 1.0,
        showLabels: showLabels ?? true,
        labelStyle: labelStyle,
        labelRadius: labelRadius ?? 120.0,
        startAngle: startAngle ?? -1.5707963267948966, // -π/2
        showPercentages: showPercentages ?? true,
        explodeSlices: explodeSlices ?? false,
        explodeDistance: explodeDistance ?? 10.0,
        labelFormatter: labels,
      ),
    );
    return this;
  }

  /// Add heat map
  ///
  /// Example:
  /// ```dart
  /// chart.geomHeatMap(
  ///   showValues: true,
  ///   colorGradient: [Colors.blue, Colors.yellow, Colors.red],
  ///   cellSpacing: 2.0,
  ///   valueFormatter: (value) => value.toStringAsFixed(1),
  /// )
  /// ```
  CristalyseChart geomHeatMap({
    double? cellSpacing,
    BorderRadius? cellBorderRadius,
    bool? showValues,
    TextStyle? valueTextStyle,
    LabelCallback? valueFormatter,
    double? minValue,
    double? maxValue,
    List<Color>? colorGradient,
    bool? interpolateColors,
    Color? nullValueColor,
    double? cellAspectRatio,
  }) {
    _geometries.add(
      HeatMapGeometry(
        cellSpacing: cellSpacing ?? 1.0,
        cellBorderRadius: cellBorderRadius,
        showValues: showValues ?? false,
        valueTextStyle: valueTextStyle,
        valueFormatter: valueFormatter,
        minValue: minValue,
        maxValue: maxValue,
        colorGradient: colorGradient,
        interpolateColors: interpolateColors ?? true,
        nullValueColor: nullValueColor,
        cellAspectRatio: cellAspectRatio,
      ),
    );
    return this;
  }

  /// Add bubble chart
  ///
  /// Bubble charts visualize three-dimensional data where X and Y position
  /// represent two dimensions, and the bubble size represents the third dimension.
  /// Perfect for showing relationships between multiple continuous variables.
  ///
  /// Example:
  /// ```dart
  /// chart.geomBubble(
  ///   minSize: 10.0,
  ///   maxSize: 50.0,
  ///   alpha: 0.7,
  ///   borderWidth: 2.0,
  ///   showLabels: true,
  ///   labelFormatter: (value) => value.toStringAsFixed(1),
  /// )
  /// ```
  CristalyseChart geomBubble({
    double? minSize,
    double? maxSize,
    Color? color,
    double? alpha,
    PointShape? shape,
    double? borderWidth,
    Color? borderColor,
    bool? showLabels,
    TextStyle? labelStyle,
    LabelCallback? labelFormatter,
    double? labelOffset,
    YAxis? yAxis,
  }) {
    // Validate and normalize size parameters
    double normalizedMinSize = (minSize != null && minSize > 0) ? minSize : 5.0;
    double normalizedMaxSize =
        (maxSize != null && maxSize > 0) ? maxSize : 30.0;

    // Ensure minSize <= maxSize; if not, swap or set equal
    if (normalizedMinSize > normalizedMaxSize) {
      normalizedMinSize = normalizedMaxSize;
    }

    _geometries.add(
      BubbleGeometry(
        minSize: normalizedMinSize,
        maxSize: normalizedMaxSize,
        color: color,
        alpha: alpha ?? 0.7,
        shape: shape ?? PointShape.circle,
        borderWidth: borderWidth ?? 1.0,
        borderColor: borderColor,
        showLabels: showLabels ?? false,
        labelStyle: labelStyle,
        labelFormatter: labelFormatter,
        labelOffset: labelOffset ?? 5.0,
        yAxis: yAxis ?? YAxis.primary,
      ),
    );
    return this;
  }

  /// Configure continuous X scale
  CristalyseChart scaleXContinuous(
      {double? min, double? max, LabelCallback? labels}) {
    _xScale = LinearScale(min: min, max: max, labelFormatter: labels);
    return this;
  }

  /// Configure continuous Y scale (primary/left axis)
  CristalyseChart scaleYContinuous(
      {double? min, double? max, LabelCallback? labels}) {
    _yScale = LinearScale(min: min, max: max, labelFormatter: labels);
    return this;
  }

  /// Configure continuous secondary Y scale (right axis)
  ///
  /// Example:
  /// ```dart
  /// chart.scaleY2Continuous(min: 0, max: 100) // For percentage data
  /// ```
  CristalyseChart scaleY2Continuous(
      {double? min, double? max, LabelCallback? labels}) {
    _y2Scale = LinearScale(min: min, max: max, labelFormatter: labels);
    return this;
  }

  /// Configure categorical X scale (useful for bar charts)
  CristalyseChart scaleXOrdinal({LabelCallback? labels}) {
    _xScale = OrdinalScale(labelFormatter: labels);
    return this;
  }

  /// Configure categorical Y scale
  CristalyseChart scaleYOrdinal({LabelCallback? labels}) {
    _yScale = OrdinalScale(labelFormatter: labels);
    return this;
  }

  /// Apply visual theme
  CristalyseChart theme(ChartTheme theme) {
    _theme = theme;
    return this;
  }

  /// Apply custom colors or gradients to specific categories in multi-series charts
  ///
  /// Use this method to assign specific colors or gradients to categories instead of relying
  /// on the theme's default color palette. This is particularly useful for:
  /// - Brand-specific colors (iOS blue, Android green, etc.)
  /// - Semantic coloring (red for errors, green for success)
  /// - Gradient effects for enhanced visual appeal
  /// - Consistent visual identity across charts
  ///
  /// **Important:** This method requires a `color` mapping to be defined.
  /// Call `.mapping(x: 'column', y: 'column', color: 'categoryColumn')` first.
  ///
  /// Categories not specified in [categoryColors] or [categoryGradients] will fall back to the
  /// theme's default color palette.
  ///
  /// Example with solid colors:
  /// ```dart
  /// final platformColors = {
  ///   'iOS': const Color(0xFF007ACC),      // Brand blue
  ///   'Android': const Color(0xFF3DDC84),  // Android green
  ///   'Web': const Color(0xFFFF6B35),      // Web orange
  /// };
  ///
  /// CristalyseChart()
  ///   .data(multiSeriesData)
  ///   .mapping(x: 'month', y: 'users', color: 'platform')
  ///   .geomLine()
  ///   .customPalette(categoryColors: platformColors)
  ///   .build();
  /// ```
  ///
  /// Example with gradients:
  /// ```dart
  /// final quarterlyGradients = {
  ///   'Q1': LinearGradient(
  ///     begin: Alignment.bottomCenter,
  ///     end: Alignment.topCenter,
  ///     colors: [Colors.blue.shade300, Colors.blue.shade700],
  ///   ),
  ///   'Q2': LinearGradient(
  ///     colors: [Colors.green.shade300, Colors.green.shade700],
  ///   ),
  /// };
  ///
  /// CristalyseChart()
  ///   .data(salesData)
  ///   .mapping(x: 'quarter', y: 'revenue', color: 'quarter')
  ///   .geomBar()
  ///   .customPalette(categoryGradients: quarterlyGradients)
  ///   .build();
  /// ```
  ///
  /// Throws [ArgumentError] if:
  /// - No color mapping is defined in `.mapping()`
  /// - Both [categoryColors] and [categoryGradients] are null or empty
  CristalyseChart customPalette({
    Map<String, Color>? categoryColors,
    Map<String, Gradient>? categoryGradients,
  }) {
    if ((categoryColors == null || categoryColors.isEmpty) &&
        (categoryGradients == null || categoryGradients.isEmpty)) {
      throw ArgumentError(
          'Either categoryColors or categoryGradients must be provided and non-empty');
    }
    if (_colorColumn != null) {
      final String colorColumn = _colorColumn ?? '';

      // Apply solid colors if provided
      if (categoryColors != null && categoryColors.isNotEmpty) {
        _theme = _theme.customPalette(
            data: _data, color: colorColumn, categoryColors: categoryColors);
      }

      // Apply gradients if provided
      if (categoryGradients != null && categoryGradients.isNotEmpty) {
        _theme = _theme.customGradientPalette(
            data: _data,
            color: colorColumn,
            categoryGradients: categoryGradients);
      }
    } else {
      throw ArgumentError("'color' argument is missing from .mapping. \n"
          "The correct code should look like this .mapping(x:'', y='', color='')\n"
          "If you don't wish to add a category column, remove customPalette() from your CristalyseChart declaration code.\n\n");
    }
    return this;
  }

  /// Configure animations
  ///
  /// Example:
  /// ```dart
  /// chart.animate(
  ///   duration: Duration(milliseconds: 500),
  ///   curve: Curves.bounceOut,
  /// )
  /// ```
  CristalyseChart animate({Duration? duration, Curve? curve}) {
    _animationDuration = duration ?? _animationDuration;
    _animationCurve = curve ?? _animationCurve;
    return this;
  }

  /// Flips the coordinate system.
  ///
  /// This is typically used to create horizontal bar charts from vertical ones,
  /// or to swap the roles of X and Y axes for other chart types.
  CristalyseChart coordFlip() {
    _coordFlipped = true;
    return this;
  }

  /// Configure chart interactions
  ///
  /// Example with simple tooltip:
  /// ```dart
  /// chart.interaction(
  ///   tooltip: TooltipConfig(
  ///     builder: DefaultTooltips.simple('revenue'),
  ///   ),
  /// )
  /// ```
  ///
  /// Example with hover and click:
  /// ```dart
  /// chart.interaction(
  ///   tooltip: TooltipConfig(
  ///     builder: DefaultTooltips.multi({
  ///       'revenue': 'Revenue',
  ///       'conversion_rate': 'Conversion Rate',
  ///     }),
  ///   ),
  ///   hover: HoverConfig(
  ///     onHover: (point) => print('Hovering: ${point?.data}'),
  ///   ),
  ///   click: ClickConfig(
  ///     onTap: (point) => showDetailsDialog(point),
  ///   ),
  /// )
  /// ```
  ///
  /// Example with panning:
  /// ```dart
  /// chart.interaction(
  ///   pan: PanConfig(
  ///     enabled: true,
  ///     onPanUpdate: (info) => print('Visible X: ${info.visibleMinX} - ${info.visibleMaxX}'),
  ///   ),
  /// )
  /// ```
  CristalyseChart interaction({
    TooltipConfig? tooltip,
    HoverConfig? hover,
    ClickConfig? click,
    PanConfig? pan,
    bool enabled = true,
  }) {
    _interaction = ChartInteraction(
      tooltip: tooltip,
      hover: hover,
      click: click,
      pan: pan,
      enabled: enabled,
    );
    return this;
  }

  /// Quick tooltip setup for common cases
  ///
  /// Example:
  /// ```dart
  /// chart.tooltip(DefaultTooltips.simple('revenue'))
  /// ```
  CristalyseChart tooltip(TooltipBuilder builder, {TooltipConfig? config}) {
    _interaction = ChartInteraction(
      tooltip: (config ?? TooltipConfig.defaultConfig).copyWith(
        builder: builder,
      ),
      enabled: true,
    );
    return this;
  }

  /// Quick hover setup
  ///
  /// Example:
  /// ```dart
  /// chart.onHover((point) => print('Hovering over: ${point?.getDisplayValue('revenue')}'))
  /// ```
  CristalyseChart onHover(HoverCallback callback) {
    _interaction = ChartInteraction(
      hover: HoverConfig(onHover: callback),
      enabled: true,
    );
    return this;
  }

  /// Quick pan setup
  ///
  /// Example:
  /// ```dart
  /// chart.onPan((info) => {
  ///   print('Panning - X range: ${info.visibleMinX} to ${info.visibleMaxX}'),
  ///   // Update your data source based on visible range
  ///   fetchDataForRange(info.visibleMinX, info.visibleMaxX),
  /// })
  /// ```
  CristalyseChart onPan(PanCallback callback, {Duration? throttle}) {
    _interaction = ChartInteraction(
      pan: PanConfig(
        enabled: true,
        onPanUpdate: callback,
        throttle: throttle ?? const Duration(milliseconds: 100),
      ),
      enabled: true,
    );
    return this;
  }

  /// Quick click setup
  ///
  /// Example:
  /// ```dart
  /// chart.onClick((point) => Navigator.push(context, DetailPage(point.data)))
  /// ```
  CristalyseChart onClick(ClickCallback callback) {
    _interaction = ChartInteraction(
      click: ClickConfig(onTap: callback),
      enabled: true,
    );
    return this;
  }

  /// Configure chart legend
  ///
  /// Automatically generates a legend based on the color mapping column.
  /// Only works when a `color` mapping is defined in `.mapping()`.
  ///
  /// Basic usage:
  /// ```dart
  /// CristalyseChart()
  ///   .data(salesData)
  ///   .mapping(x: 'month', y: 'revenue', color: 'product')
  ///   .geomBar()
  ///   .legend() // Simple legend with smart defaults
  ///   .build();
  /// ```
  ///
  /// With positioning:
  /// ```dart
  /// chart.legend(position: LegendPosition.bottom)
  /// ```
  ///
  /// With custom styling:
  /// ```dart
  /// chart.legend(
  ///   position: LegendPosition.right,
  ///   backgroundColor: Colors.white.withOpacity(0.9),
  ///   textStyle: TextStyle(fontSize: 12),
  /// )
  /// ```
  CristalyseChart legend({
    LegendPosition? position,
    LegendOrientation? orientation,
    double? spacing,
    double? itemSpacing,
    double? symbolSize,
    TextStyle? textStyle,
    Color? backgroundColor,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    _legendConfig = LegendConfig(
      position: position ?? LegendPosition.topRight,
      orientation: orientation ?? LegendOrientation.auto,
      spacing: spacing ?? 12.0,
      itemSpacing: itemSpacing ?? 8.0,
      symbolSize: symbolSize ?? 12.0,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
      padding: padding ?? const EdgeInsets.all(8.0),
      borderRadius: borderRadius ?? 4.0,
    );
    return this;
  }

  /// Export the chart as SVG image
  ///
  /// Example:
  /// ```dart
  /// final result = await chart.exportAsSvg(
  ///   width: 1200,
  ///   height: 800,
  ///   filename: 'sales_chart',
  /// );
  /// print('Chart exported to: ${result.filePath}');
  /// ```
  Future<ExportResult> exportAsSvg({
    double width = 800,
    double height = 600,
    Color? backgroundColor,
    String? filename,
    String? customPath,
  }) async {
    final chartWidget = build();
    return chartWidget.exportAsSvg(
      width: width,
      height: height,
      backgroundColor: backgroundColor ?? _theme.backgroundColor,
      filename: filename,
      customPath: customPath,
    );
  }

  /// Export the chart with custom configuration
  ///
  /// Example:
  /// ```dart
  /// final config = ExportConfig(
  ///   width: 1920,
  ///   height: 1080,
  ///   format: ExportFormat.svg,
  ///   filename: 'high_res_chart',
  /// );
  /// final result = await chart.export(config);
  /// ```
  Future<ExportResult> export(ExportConfig config, {String? customPath}) async {
    final chartWidget = build();
    return ChartExporter.exportChart(
      chartWidget: chartWidget,
      config: config,
      customPath: customPath,
    );
  }

  /// Build the chart widget
  Widget build() {
    return AnimatedCristalyseChartWidget(
      data: _data,
      xColumn: _xColumn,
      yColumn: _yColumn,
      y2Column: _y2Column,
      colorColumn: _colorColumn,
      sizeColumn: _sizeColumn,
      pieValueColumn: _pieValueColumn,
      pieCategoryColumn: _pieCategoryColumn,
      heatMapXColumn: _heatMapXColumn,
      heatMapYColumn: _heatMapYColumn,
      heatMapValueColumn: _heatMapValueColumn,
      geometries: _geometries,
      xScale: _xScale,
      yScale: _yScale,
      y2Scale: _y2Scale,
      colorScale: _colorScale,
      sizeScale: _sizeScale,
      theme: _theme,
      animationDuration: _animationDuration,
      animationCurve: _animationCurve,
      coordFlipped: _coordFlipped,
      interaction: _interaction,
      legendConfig: _legendConfig,
    );
  }
}

/// Extension for TooltipConfig to add copyWith method
extension TooltipConfigExtension on TooltipConfig {
  TooltipConfig copyWith({
    TooltipBuilder? builder,
    Duration? showDelay,
    Duration? hideDelay,
    bool? followPointer,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    BoxShadow? shadow,
  }) {
    return TooltipConfig(
      builder: builder ?? this.builder,
      showDelay: showDelay ?? this.showDelay,
      hideDelay: hideDelay ?? this.hideDelay,
      followPointer: followPointer ?? this.followPointer,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
      shadow: shadow ?? this.shadow,
    );
  }
}

/// Extension that adds utility methods to [ChartTheme] for enhanced customization
/// and theme manipulation capabilities.
extension ChartThemeExtension on ChartTheme {
  /// Creates a copy of this [ChartTheme] with the given fields replaced with new values
  ///
  /// This method allows for easy theme customization by modifying only specific
  /// properties while preserving all other theme settings.
  ///
  /// Example:
  /// ```dart
  /// final customTheme = ChartTheme.defaultTheme().copyWith(
  ///   primaryColor: Colors.deepPurple,
  ///   colorPalette: [Colors.purple, Colors.amber, Colors.teal],
  ///   padding: const EdgeInsets.all(20),
  /// );
  /// ```
  ChartTheme copyWith({
    Color? backgroundColor,
    Color? plotBackgroundColor,
    Color? primaryColor,
    Color? borderColor,
    Color? gridColor,
    Color? axisColor,
    double? gridWidth,
    double? axisWidth,
    double? pointSizeDefault,
    double? pointSizeMin,
    double? pointSizeMax,
    List<Color>? colorPalette,
    EdgeInsets? padding,
    TextStyle? axisTextStyle,
    TextStyle? axisLabelStyle,
    Map<String, Gradient>? categoryGradients,
  }) {
    return ChartTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      plotBackgroundColor: plotBackgroundColor ?? this.plotBackgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      borderColor: borderColor ?? this.borderColor,
      gridColor: gridColor ?? this.gridColor,
      axisColor: axisColor ?? this.axisColor,
      gridWidth: gridWidth ?? this.gridWidth,
      axisWidth: axisWidth ?? this.axisWidth,
      pointSizeDefault: pointSizeDefault ?? this.pointSizeDefault,
      pointSizeMin: pointSizeMin ?? this.pointSizeMin,
      pointSizeMax: pointSizeMax ?? this.pointSizeMax,
      colorPalette: colorPalette ?? this.colorPalette,
      padding: padding ?? this.padding,
      axisTextStyle: axisTextStyle ?? this.axisTextStyle,
      axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
      categoryGradients: categoryGradients ?? this.categoryGradients,
    );
  }

  /// Creates a new [ChartTheme] with a custom color palette based on category mapping
  ///
  /// This method analyzes the provided [data] to extract unique categories from the
  /// specified [color] column, then creates a color palette that maps specific
  /// colors to categories as defined in [categoryColors].
  ///
  /// **Algorithm:**
  /// 1. Extracts unique categories from `data[color]` column
  /// 2. Maps each category to a color from [categoryColors]
  /// 3. Falls back to the current theme's color palette for unmapped categories
  /// 4. Returns a new theme with the custom color palette
  ///
  /// **Fallback behavior:**
  /// If a category is not found in [categoryColors], the method will use the
  /// color at the corresponding index from the current theme's `colorPalette`.
  /// This ensures all categories have colors and prevents visual inconsistencies.
  ///
  /// Parameters:
  /// - [data]: The chart data containing category information
  /// - [color]: The column name that contains category values
  /// - [categoryColors]: Map of category names to their desired colors
  ///
  /// Example:
  /// ```dart
  /// final customTheme = baseTheme.customPalette(
  ///   data: chartData,
  ///   color: 'platform',
  ///   categoryColors: {
  ///     'iOS': Colors.blue,
  ///     'Android': Colors.green,
  ///     'Web': Colors.orange,
  ///   },
  /// );
  /// ```
  ///
  /// Returns a new [ChartTheme] with the custom color palette applied.
  ChartTheme customPalette(
      {required List<Map<String, dynamic>> data,
      required String color,
      required Map<String, Color> categoryColors}) {
    // Extract unique categories
    final categories = data.map((d) => d[color] as String).toSet().toList();
    // Build color palette in the order categories appear
    final colorPalette = categories
        .map((category) =>
            categoryColors[category] ??
            this.colorPalette[categories.indexOf(category)])
        .toList();
    return copyWith(
      colorPalette: colorPalette,
    );
  }

  /// Creates a new [ChartTheme] with custom gradients for specific categories
  ///
  /// This method allows you to assign gradient fills to specific categories instead of
  /// solid colors. Perfect for creating visually rich charts with depth and dimension.
  ///
  /// **Important:** This method requires a `color` mapping to be defined.
  /// Call `.mapping(x: 'column', y: 'column', color: 'categoryColumn')` first.
  ///
  /// Categories not specified in [categoryGradients] will fall back to solid colors
  /// from the theme's color palette.
  ///
  /// Example:
  /// ```dart
  /// final quarterlyGradients = {
  ///   'Q1': LinearGradient(
  ///     begin: Alignment.bottomCenter,
  ///     end: Alignment.topCenter,
  ///     colors: [Colors.blue.shade300, Colors.blue.shade700],
  ///   ),
  ///   'Q2': RadialGradient(
  ///     colors: [Colors.green.shade200, Colors.green.shade800],
  ///   ),
  /// };
  ///
  /// CristalyseChart()
  ///   .data(salesData)
  ///   .mapping(x: 'quarter', y: 'revenue', color: 'quarter')
  ///   .geomBar()
  ///   .theme(ChartTheme.defaultTheme().customGradientPalette(
  ///     data: salesData,
  ///     color: 'quarter',
  ///     categoryGradients: quarterlyGradients,
  ///   ))
  ///   .build();
  /// ```
  ///
  /// Parameters:
  /// - [data]: The chart data containing category information
  /// - [color]: The column name that contains category values
  /// - [categoryGradients]: Map of category names to their desired gradients
  ///
  /// Returns a new [ChartTheme] with the custom gradient mapping applied.
  ChartTheme customGradientPalette({
    required List<Map<String, dynamic>> data,
    required String color,
    required Map<String, Gradient> categoryGradients,
  }) {
    return copyWith(
      categoryGradients: categoryGradients,
    );
  }
}
