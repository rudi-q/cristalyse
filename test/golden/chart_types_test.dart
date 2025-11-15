import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

/// Visual regression tests for all chart types and their variations
void main() {
  group('Scatter Plot Tests', () {
    goldenTest(
      'Scatter plot with different point shapes',
      fileName: 'scatter_shapes',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'circle_points',
            child: buildScatterPlot(shape: PointShape.circle),
          ),
          GoldenTestScenario(
            name: 'square_points',
            child: buildScatterPlot(shape: PointShape.square),
          ),
          GoldenTestScenario(
            name: 'triangle_points',
            child: buildScatterPlot(shape: PointShape.triangle),
          ),
        ],
      ),
    );

    goldenTest(
      'Scatter plot with different sizes and borders',
      fileName: 'scatter_variations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'small_points',
            child: buildScatterPlot(size: 3.0),
          ),
          GoldenTestScenario(
            name: 'large_points',
            child: buildScatterPlot(size: 10.0),
          ),
          GoldenTestScenario(
            name: 'with_borders',
            child: buildScatterPlot(borderWidth: 2.0),
          ),
        ],
      ),
    );

    goldenTest(
      'Multi-series scatter plot',
      fileName: 'scatter_multi_series',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'multi_series',
            child: buildMultiSeriesScatterPlot(),
          ),
        ],
      ),
    );
  });

  group('Line Chart Tests', () {
    goldenTest(
      'Line chart with different styles',
      fileName: 'line_styles',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'solid_line',
            child: buildLineChart(style: LineStyle.solid),
          ),
          GoldenTestScenario(
            name: 'dashed_line',
            child: buildLineChart(style: LineStyle.dashed),
          ),
          GoldenTestScenario(
            name: 'dotted_line',
            child: buildLineChart(style: LineStyle.dotted),
          ),
        ],
      ),
    );

    goldenTest(
      'Line chart with different stroke widths',
      fileName: 'line_widths',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'thin_line',
            child: buildLineChart(strokeWidth: 1.0),
          ),
          GoldenTestScenario(
            name: 'thick_line',
            child: buildLineChart(strokeWidth: 5.0),
          ),
        ],
      ),
    );

    goldenTest(
      'Multi-series line chart',
      fileName: 'line_multi_series',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'multi_series',
            child: buildMultiSeriesLineChart(),
          ),
        ],
      ),
    );
  });

  group('Bar Chart Tests', () {
    goldenTest(
      'Vertical bar charts',
      fileName: 'bar_vertical',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'basic',
            child: buildBarChart(orientation: BarOrientation.vertical),
          ),
          GoldenTestScenario(
            name: 'rounded',
            child: buildBarChart(
              orientation: BarOrientation.vertical,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          GoldenTestScenario(
            name: 'with_borders',
            child: buildBarChart(
              orientation: BarOrientation.vertical,
              borderWidth: 2.0,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Horizontal bar charts',
      fileName: 'bar_horizontal',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'basic',
            child: buildBarChart(orientation: BarOrientation.horizontal),
          ),
          GoldenTestScenario(
            name: 'rounded',
            child: buildBarChart(
              orientation: BarOrientation.horizontal,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Grouped vs Stacked bar charts',
      fileName: 'bar_styles',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'grouped',
            child: buildMultiSeriesBarChart(style: BarStyle.grouped),
          ),
          GoldenTestScenario(
            name: 'stacked',
            child: buildMultiSeriesBarChart(style: BarStyle.stacked),
          ),
        ],
      ),
    );
  });

  group('Area Chart Tests', () {
    goldenTest(
      'Area chart variations',
      fileName: 'area_variations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'filled',
            child: buildAreaChart(fillArea: true),
          ),
          GoldenTestScenario(
            name: 'outline_only',
            child: buildAreaChart(fillArea: false),
          ),
          GoldenTestScenario(
            name: 'semi_transparent',
            child: buildAreaChart(alpha: 0.5),
          ),
        ],
      ),
    );

    goldenTest(
      'Multi-series area chart',
      fileName: 'area_multi_series',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'multi_series',
            child: buildMultiSeriesAreaChart(),
          ),
        ],
      ),
    );
  });

  group('Pie Chart Tests', () {
    goldenTest(
      'Pie chart variations',
      fileName: 'pie_variations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'basic_pie',
            child: buildPieChart(),
          ),
          GoldenTestScenario(
            name: 'donut_chart',
            child: buildPieChart(innerRadius: 0.6),
          ),
          GoldenTestScenario(
            name: 'with_labels',
            child: buildPieChart(showLabels: true),
          ),
          GoldenTestScenario(
            name: 'with_percentages',
            child: buildPieChart(showPercentages: true),
          ),
          GoldenTestScenario(
            name: 'exploded_slices',
            child: buildPieChart(explodeSlices: true),
          ),
        ],
      ),
    );
  });

  group('Heat Map Tests', () {
    goldenTest(
      'Heat map with different color gradients',
      fileName: 'heat_map_gradients',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'viridis',
            child: buildHeatMap(colorScale: GradientColorScale.viridis()),
          ),
          GoldenTestScenario(
            name: 'cool_warm',
            child: buildHeatMap(colorScale: GradientColorScale.coolWarm()),
          ),
          GoldenTestScenario(
            name: 'heat_map',
            child: buildHeatMap(colorScale: GradientColorScale.heatMap()),
          ),
          GoldenTestScenario(
            name: 'green_red',
            child: buildHeatMap(colorScale: GradientColorScale.greenRed()),
          ),
        ],
      ),
    );

    goldenTest(
      'Heat map cell customizations',
      fileName: 'heat_map_cells',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'square_cells',
            child: buildHeatMap(),
          ),
          GoldenTestScenario(
            name: 'rounded_cells',
            child: buildHeatMap(
              cellBorderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          GoldenTestScenario(
            name: 'with_values',
            child: buildHeatMap(showValues: true),
          ),
        ],
      ),
    );
  });

  group('Bubble Chart Tests', () {
    goldenTest(
      'Bubble chart variations',
      fileName: 'bubble_variations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'basic',
            child: buildBubbleChart(),
          ),
          GoldenTestScenario(
            name: 'with_size_guide',
            child: buildBubbleChart(showSizeGuide: true),
          ),
          GoldenTestScenario(
            name: 'with_labels',
            child: buildBubbleChart(showLabels: true),
          ),
        ],
      ),
    );
  });

  group('Progress Bar Tests', () {
    goldenTest(
      'Progress bar orientations',
      fileName: 'progress_orientations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'horizontal',
            child:
                buildProgressBar(orientation: ProgressOrientation.horizontal),
          ),
          GoldenTestScenario(
            name: 'vertical',
            child: buildProgressBar(orientation: ProgressOrientation.vertical),
          ),
          GoldenTestScenario(
            name: 'circular',
            child: buildProgressBar(orientation: ProgressOrientation.circular),
          ),
        ],
      ),
    );

    goldenTest(
      'Progress bar styles',
      fileName: 'progress_styles',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'filled',
            child: buildProgressBar(style: ProgressStyle.filled),
          ),
          GoldenTestScenario(
            name: 'striped',
            child: buildProgressBar(style: ProgressStyle.striped),
          ),
          GoldenTestScenario(
            name: 'gradient',
            child: buildProgressBar(style: ProgressStyle.gradient),
          ),
          GoldenTestScenario(
            name: 'stacked',
            child: buildProgressBar(
              style: ProgressStyle.stacked,
              segments: [25.0, 30.0, 20.0],
            ),
          ),
          GoldenTestScenario(
            name: 'grouped',
            child: buildProgressBar(style: ProgressStyle.grouped),
          ),
          GoldenTestScenario(
            name: 'gauge',
            child: buildProgressBar(
              style: ProgressStyle.gauge,
              gaugeRadius: 80.0,
              showTicks: true,
            ),
          ),
          GoldenTestScenario(
            name: 'concentric',
            child: buildProgressBar(
              style: ProgressStyle.concentric,
              concentricRadii: [40.0, 60.0, 80.0],
              concentricThicknesses: [10.0, 10.0, 10.0],
            ),
          ),
        ],
      ),
    );
  });

  group('Dual Y-Axis Tests', () {
    goldenTest(
      'Dual Y-axis chart',
      fileName: 'dual_y_axis',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'bar_and_line',
            child: buildDualYAxisChart(),
          ),
        ],
      ),
    );
  });
}
