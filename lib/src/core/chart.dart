import 'package:flutter/material.dart';

import '../export/chart_export.dart';
import '../interaction/chart_interactions.dart';
import '../themes/chart_theme.dart';
import '../widgets/animated_chart_widget.dart';
import 'axis_formatter.dart';
import 'geometry.dart';
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

  // Axis formatters
  AxisFormatter _xAxisFormatter = AxisFormatter.defaultFormatter;
  AxisFormatter _yAxisFormatter = AxisFormatter.defaultFormatter;
  AxisFormatter _y2AxisFormatter = AxisFormatter.defaultFormatter;

  /// Interaction configuration
  ChartInteraction _interaction = ChartInteraction.none;

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
      ),
    );
    return this;
  }

  /// Configure continuous X scale
  CristalyseChart scaleXContinuous({double? min, double? max}) {
    _xScale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure continuous Y scale (primary/left axis)
  CristalyseChart scaleYContinuous({double? min, double? max}) {
    _yScale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure continuous secondary Y scale (right axis)
  ///
  /// Example:
  /// ```dart
  /// chart.scaleY2Continuous(min: 0, max: 100) // For percentage data
  /// ```
  CristalyseChart scaleY2Continuous({double? min, double? max}) {
    _y2Scale = LinearScale(min: min, max: max);
    return this;
  }

  /// Configure categorical X scale (useful for bar charts)
  CristalyseChart scaleXOrdinal() {
    _xScale = OrdinalScale();
    return this;
  }

  /// Configure categorical Y scale
  CristalyseChart scaleYOrdinal() {
    _yScale = OrdinalScale();
    return this;
  }

  /// Apply visual theme
  CristalyseChart theme(ChartTheme theme) {
    _theme = theme;
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

  /// Format X-axis labels
  ///
  /// Example:
  /// ```dart
  /// chart.formatXAxis(prefix: '\$', suffix: '', decimals: 2)
  /// chart.formatXAxis(formatter: AxisFormatter.currency)
  /// ```
  CristalyseChart formatXAxis({
    String? prefix,
    String? suffix,
    int? decimals,
    AxisFormatter? formatter,
  }) {
    if (formatter != null) {
      _xAxisFormatter = formatter;
    } else {
      _xAxisFormatter = AxisFormatter(
        prefix: prefix ?? '',
        suffix: suffix ?? '',
        decimals: decimals,
      );
    }
    return this;
  }

  /// Format Y-axis labels (primary/left axis)
  ///
  /// Example:
  /// ```dart
  /// chart.formatYAxis(prefix: '', suffix: '%', decimals: 1)
  /// chart.formatYAxis(formatter: AxisFormatter.percentage)
  /// ```
  CristalyseChart formatYAxis({
    String? prefix,
    String? suffix,
    int? decimals,
    AxisFormatter? formatter,
  }) {
    if (formatter != null) {
      _yAxisFormatter = formatter;
    } else {
      _yAxisFormatter = AxisFormatter(
        prefix: prefix ?? '',
        suffix: suffix ?? '',
        decimals: decimals,
      );
    }
    return this;
  }

  /// Format secondary Y-axis labels (right axis)
  ///
  /// Example:
  /// ```dart
  /// chart.formatY2Axis(prefix: 'JPY ', suffix: '', decimals: 0)
  /// chart.formatY2Axis(formatter: AxisFormatter.currencyWithSymbol('€'))
  /// ```
  CristalyseChart formatY2Axis({
    String? prefix,
    String? suffix,
    int? decimals,
    AxisFormatter? formatter,
  }) {
    if (formatter != null) {
      _y2AxisFormatter = formatter;
    } else {
      _y2AxisFormatter = AxisFormatter(
        prefix: prefix ?? '',
        suffix: suffix ?? '',
        decimals: decimals,
      );
    }
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
      xAxisFormatter: _xAxisFormatter,
      yAxisFormatter: _yAxisFormatter,
      y2AxisFormatter: _y2AxisFormatter,
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
