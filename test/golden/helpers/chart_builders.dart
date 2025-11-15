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
        .scale(
          x: LinearScale(title: xAxisTitle),
          y: LinearScale(min: yMin, max: yMax, title: yAxisTitle),
        )
        .geom(
          PointGeometry(
            shape: shape,
            alpha: alpha,
            borderWidth: borderWidth,
            size: size,
          ),
        )
        .theme(theme ?? ChartTheme.defaultTheme())
        .coordFlip(coordFlipped)
        .build(),
  );
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
        .scale(x: LinearScale(), y: LinearScale())
        .geom(LineGeometry(style: style, strokeWidth: strokeWidth))
        .theme(theme ?? ChartTheme.defaultTheme())
        .coordFlip(coordFlipped)
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
        .scale(x: LinearScale(), y: LinearScale())
        .geom(LineGeometry())
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
        .scale(
          x: OrdinalScale(title: xAxisTitle),
          y: LinearScale(min: yMin, max: yMax, title: yAxisTitle),
        )
        .geom(
          BarGeometry(
            orientation: orientation,
            style: style,
            borderRadius: borderRadius,
            alpha: alpha,
            borderWidth: borderWidth,
          ),
        )
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
        .scale(x: OrdinalScale(), y: LinearScale())
        .geom(BarGeometry(style: style))
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
        .scale(x: LinearScale(), y: LinearScale())
        .geom(AreaGeometry(fillArea: fillArea, alpha: alpha))
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
        .scale(x: LinearScale(), y: LinearScale())
        .geom(AreaGeometry())
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
        .geom(
          PieGeometry(
            innerRadius: innerRadius,
            showLabels: showLabels,
            showPercentages: showPercentages,
            explodeSlices: explodeSlices,
          ),
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
        .scaleColor(colorScale ?? GradientColorScale.viridis())
        .geom(
          HeatMapGeometry(
            cellBorderRadius: cellBorderRadius,
            showValues: showValues,
          ),
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
        .scale(x: LinearScale(), y: LinearScale())
        .scaleSize(SizeScale(range: [10.0, 40.0]))
        .geom(
          BubbleGeometry(
            showSizeGuide: showSizeGuide,
            showLabels: showLabels,
          ),
        )
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget buildProgressBar({
  ProgressOrientation orientation = ProgressOrientation.horizontal,
  ProgressStyle style = ProgressStyle.filled,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(progressData)
        .mappingProgress(label: 'label', value: 'value')
        .geom(
          ProgressGeometry(
            orientation: orientation,
            style: style,
          ),
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
        .scale(
          x: OrdinalScale(title: 'Category'),
          y: LinearScale(title: 'Sales'),
          y2: LinearScale(title: 'Conversion Rate'),
        )
        .geom(BarGeometry(yAxis: YAxis.primary))
        .geom(LineGeometry(yAxis: YAxis.secondary, strokeWidth: 3.0))
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
  LegendSymbol? symbolShape,
  ChartTheme? theme,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(multiSeriesNumericData)
        .mapping(x: 'x', y: 'y', color: 'series')
        .scale(x: LinearScale(), y: LinearScale())
        .geom(LineGeometry())
        .legend(
          LegendConfig(
            position: position,
            orientation: orientation,
            symbolShape: symbolShape,
          ),
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
        .scale(x: LinearScale(), y: LinearScale())
        .geom(AreaGeometry(alpha: 0.3))
        .geom(LineGeometry(strokeWidth: 2.0))
        .geom(PointGeometry(size: 6.0))
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
        .scale(
          x: OrdinalScale(title: 'Category'),
          y: LinearScale(title: 'Sales'),
          y2: LinearScale(title: 'Conversion Rate'),
        )
        .geom(BarGeometry(yAxis: YAxis.primary))
        .geom(LineGeometry(yAxis: YAxis.secondary, strokeWidth: 3.0))
        .legend(LegendConfig(position: LegendPosition.topRight))
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
        .scale(
          x: OrdinalScale(title: 'Product'),
          y: LinearScale(title: 'Revenue'),
        )
        .geom(
          BarGeometry(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        )
        .theme(theme ?? ChartTheme.dark())
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
        .scale(x: LinearScale(), y: LinearScale())
        .geom(PointGeometry())
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}
