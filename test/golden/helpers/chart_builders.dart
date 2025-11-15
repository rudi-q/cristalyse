import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

/// Shared helper functions for building charts in golden tests

// ============================================================================
// Sample Data Sets
// ============================================================================

List<Map<String, dynamic>> get basicNumericData => [
      {'x': 1.0, 'y': 10.0},
      {'x': 2.0, 'y': 25.0},
      {'x': 3.0, 'y': 15.0},
      {'x': 4.0, 'y': 40.0},
      {'x': 5.0, 'y': 30.0},
    ];

List<Map<String, dynamic>> get categoricalData => [
      {'category': 'A', 'value': 30.0},
      {'category': 'B', 'value': 50.0},
      {'category': 'C', 'value': 40.0},
      {'category': 'D', 'value': 70.0},
    ];

List<Map<String, dynamic>> get multiSeriesNumericData => [
      {'x': 1.0, 'y': 10.0, 'series': 'Series A'},
      {'x': 2.0, 'y': 25.0, 'series': 'Series A'},
      {'x': 3.0, 'y': 15.0, 'series': 'Series A'},
      {'x': 1.0, 'y': 15.0, 'series': 'Series B'},
      {'x': 2.0, 'y': 20.0, 'series': 'Series B'},
      {'x': 3.0, 'y': 30.0, 'series': 'Series B'},
      {'x': 1.0, 'y': 8.0, 'series': 'Series C'},
      {'x': 2.0, 'y': 18.0, 'series': 'Series C'},
      {'x': 3.0, 'y': 22.0, 'series': 'Series C'},
    ];

List<Map<String, dynamic>> get multiSeriesCategoricalData => [
      {'category': 'A', 'value': 30.0, 'series': 'Q1'},
      {'category': 'B', 'value': 50.0, 'series': 'Q1'},
      {'category': 'C', 'value': 40.0, 'series': 'Q1'},
      {'category': 'A', 'value': 35.0, 'series': 'Q2'},
      {'category': 'B', 'value': 55.0, 'series': 'Q2'},
      {'category': 'C', 'value': 45.0, 'series': 'Q2'},
    ];

List<Map<String, dynamic>> get pieData => [
      {'category': 'A', 'value': 30.0},
      {'category': 'B', 'value': 50.0},
      {'category': 'C', 'value': 20.0},
    ];

List<Map<String, dynamic>> get heatMapData => [
      {'x': 'Mon', 'y': 'Morning', 'value': 10.0},
      {'x': 'Mon', 'y': 'Afternoon', 'value': 20.0},
      {'x': 'Mon', 'y': 'Evening', 'value': 15.0},
      {'x': 'Tue', 'y': 'Morning', 'value': 25.0},
      {'x': 'Tue', 'y': 'Afternoon', 'value': 30.0},
      {'x': 'Tue', 'y': 'Evening', 'value': 18.0},
      {'x': 'Wed', 'y': 'Morning', 'value': 22.0},
      {'x': 'Wed', 'y': 'Afternoon', 'value': 28.0},
      {'x': 'Wed', 'y': 'Evening', 'value': 20.0},
    ];

List<Map<String, dynamic>> get bubbleData => [
      {'x': 10.0, 'y': 20.0, 'size': 15.0, 'label': 'A'},
      {'x': 20.0, 'y': 30.0, 'size': 25.0, 'label': 'B'},
      {'x': 30.0, 'y': 25.0, 'size': 20.0, 'label': 'C'},
      {'x': 40.0, 'y': 35.0, 'size': 30.0, 'label': 'D'},
    ];

List<Map<String, dynamic>> get progressData => [
      {'label': 'Task A', 'value': 75.0},
      {'label': 'Task B', 'value': 50.0},
      {'label': 'Task C', 'value': 90.0},
    ];

List<Map<String, dynamic>> get dualAxisData => [
      {'category': 'A', 'sales': 30.0, 'conversion': 0.15},
      {'category': 'B', 'sales': 50.0, 'conversion': 0.22},
      {'category': 'C', 'sales': 40.0, 'conversion': 0.18},
      {'category': 'D', 'sales': 70.0, 'conversion': 0.25},
    ];

// ============================================================================
// Chart Builders - Basic Types
// ============================================================================

Widget buildScatterPlot({
  PointShape shape = PointShape.circle,
  ChartTheme? theme,
  String? xAxisTitle,
  String? yAxisTitle,
  double? yMin,
  double? yMax,
  double alpha = 1.0,
  bool coordFlipped = false,
  double borderWidth = 0.0,
  double size = 5.0,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(basicNumericData)
        .mapping(x: 'x', y: 'y')
        .geomPoint(
          shape: shape,
          alpha: alpha,
          borderWidth: borderWidth,
          size: size,
        )
        .scaleXContinuous(title: xAxisTitle)
        .scaleYContinuous(min: yMin, max: yMax, title: yAxisTitle)
        .theme(theme ?? ChartTheme.defaultTheme())
        .conditional(coordFlipped, (chart) => chart.coordFlip())
        .build(),
  );
}

// Helper for conditional method chaining
extension ChartConditional on CristalyseChart {
  CristalyseChart conditional(
      bool condition, CristalyseChart Function(CristalyseChart) apply) {
    return condition ? apply(this) : this;
  }
}

Widget buildLineChart({
  LineStyle style = LineStyle.solid,
  ChartTheme? theme,
  bool coordFlipped = false,
  double strokeWidth = 2.0,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(basicNumericData)
        .mapping(x: 'x', y: 'y')
        .geomLine(style: style, strokeWidth: strokeWidth)
        .scaleXContinuous()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .conditional(coordFlipped, (chart) => chart.coordFlip())
        .build(),
  );
}

Widget buildMultiSeriesLineChart({ChartTheme? theme}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(multiSeriesNumericData)
        .mapping(x: 'x', y: 'y', color: 'series')
        .geomLine()
        .scaleXContinuous()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildBarChart({
  BarOrientation orientation = BarOrientation.vertical,
  BarStyle style = BarStyle.grouped,
  BorderRadius? borderRadius,
  ChartTheme? theme,
  String? xAxisTitle,
  String? yAxisTitle,
  double? yMin,
  double? yMax,
  double alpha = 1.0,
  double borderWidth = 0.0,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(categoricalData)
        .mapping(x: 'category', y: 'value')
        .geomBar(
          orientation: orientation,
          style: style,
          borderRadius: borderRadius,
          alpha: alpha,
          borderWidth: borderWidth,
        )
        .scaleXOrdinal(title: xAxisTitle)
        .scaleYContinuous(min: yMin, max: yMax, title: yAxisTitle)
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildMultiSeriesBarChart({
  BarStyle style = BarStyle.grouped,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(multiSeriesCategoricalData)
        .mapping(x: 'category', y: 'value', color: 'series')
        .geomBar(style: style)
        .scaleXOrdinal()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildAreaChart({
  bool fillArea = true,
  double alpha = 0.3,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(basicNumericData)
        .mapping(x: 'x', y: 'y')
        .geomArea(fillArea: fillArea, alpha: alpha)
        .scaleXContinuous()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildMultiSeriesAreaChart({ChartTheme? theme}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(multiSeriesNumericData)
        .mapping(x: 'x', y: 'y', color: 'series')
        .geomArea()
        .scaleXContinuous()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildPieChart({
  double innerRadius = 0.0,
  bool showLabels = false,
  bool showPercentages = false,
  bool explodeSlices = false,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(pieData)
        .mappingPie(category: 'category', value: 'value')
        .geomPie(
          innerRadius: innerRadius,
          showLabels: showLabels,
          showPercentages: showPercentages,
          explodeSlices: explodeSlices,
        )
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildHeatMap({
  GradientColorScale? colorScale,
  BorderRadius? cellBorderRadius,
  bool showValues = false,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(heatMapData)
        .mappingHeatMap(x: 'x', y: 'y', value: 'value')
        .geomHeatMap(
          cellBorderRadius: cellBorderRadius,
          showValues: showValues,
          colorGradient: colorScale?.colors,
        )
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildBubbleChart({
  bool showSizeGuide = false,
  bool showLabels = false,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(bubbleData)
        .mapping(x: 'x', y: 'y', size: 'size')
        .geomBubble(
          minSize: 10.0,
          maxSize: 40.0,
          title: showSizeGuide ? 'Size' : null,
          showLabels: showLabels,
        )
        .scaleXContinuous()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildProgressBar({
  ProgressOrientation orientation = ProgressOrientation.horizontal,
  ProgressStyle style = ProgressStyle.filled,
  ChartTheme? theme,
  List<double>? segments,
  List<Color>? segmentColors,
  double? gaugeRadius,
  bool? showTicks,
  List<double>? concentricRadii,
  List<double>? concentricThicknesses,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(progressData)
        .mappingProgress(label: 'label', value: 'value')
        .geomProgress(
          orientation: orientation,
          style: style,
          segments: segments,
          segmentColors: segmentColors,
          gaugeRadius: gaugeRadius,
          showTicks: showTicks,
          concentricRadii: concentricRadii,
          concentricThicknesses: concentricThicknesses,
        )
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildDualYAxisChart({ChartTheme? theme}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(dualAxisData)
        .mapping(x: 'category', y: 'sales')
        .mappingY2('conversion')
        .geomBar(yAxis: YAxis.primary)
        .geomLine(yAxis: YAxis.secondary, strokeWidth: 3.0)
        .scaleXOrdinal(title: 'Category')
        .scaleYContinuous(title: 'Sales')
        .scaleY2Continuous(title: 'Conversion Rate')
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

// ============================================================================
// Chart Builders - With Legends
// ============================================================================

Widget buildChartWithLegend({
  LegendPosition position = LegendPosition.topRight,
  LegendOrientation? orientation,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(multiSeriesNumericData)
        .mapping(x: 'x', y: 'y', color: 'series')
        .geomLine()
        .scaleXContinuous()
        .scaleYContinuous()
        .legend(
          position: position,
          orientation: orientation ?? LegendOrientation.auto,
        )
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

// ============================================================================
// Chart Builders - Complex Combinations
// ============================================================================

Widget buildComplexMultiGeometryChart({ChartTheme? theme}) {
  final data = [
    {'x': 1.0, 'y': 10.0},
    {'x': 2.0, 'y': 25.0},
    {'x': 3.0, 'y': 15.0},
    {'x': 4.0, 'y': 40.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'x', y: 'y')
        .geomArea(alpha: 0.3)
        .geomLine(strokeWidth: 2.0)
        .geomPoint(size: 6.0)
        .scaleXContinuous()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildComplexDualAxisWithLegend({ChartTheme? theme}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(dualAxisData)
        .mapping(x: 'category', y: 'sales')
        .mappingY2('conversion')
        .geomBar(yAxis: YAxis.primary)
        .geomLine(yAxis: YAxis.secondary, strokeWidth: 3.0)
        .scaleXOrdinal(title: 'Category')
        .scaleYContinuous(title: 'Sales')
        .scaleY2Continuous(title: 'Conversion Rate')
        .legend(position: LegendPosition.topRight)
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildComplexThemedWithCustomizations({ChartTheme? theme}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(categoricalData)
        .mapping(x: 'category', y: 'value')
        .geomBar(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        )
        .scaleXOrdinal(title: 'Product')
        .scaleYContinuous(title: 'Revenue')
        .theme(theme ?? ChartTheme.darkTheme())
        .build(),
  );
}

Widget buildMultiSeriesScatterPlot({ChartTheme? theme}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(multiSeriesNumericData)
        .mapping(x: 'x', y: 'y', color: 'series')
        .geomPoint()
        .scaleXContinuous()
        .scaleYContinuous()
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}
