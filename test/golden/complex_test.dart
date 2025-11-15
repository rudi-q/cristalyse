import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

/// Visual regression tests for complex chart combinations
void main() {
  group('Multi-Geometry Tests', () {
    goldenTest(
      'Charts with multiple geometry types',
      fileName: 'multi_geometry',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'area_line_points',
            child: buildComplexMultiGeometryChart(),
          ),
          GoldenTestScenario(
            name: 'area_line_points_dark',
            child: buildComplexMultiGeometryChart(theme: ChartTheme.darkTheme()),
          ),
        ],
      ),
    );
  });

  group('Dual Axis with Legend Tests', () {
    goldenTest(
      'Dual Y-axis charts with legends',
      fileName: 'dual_axis_legend',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default_theme',
            child: buildComplexDualAxisWithLegend(),
          ),
          GoldenTestScenario(
            name: 'dark_theme',
            child: buildComplexDualAxisWithLegend(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildComplexDualAxisWithLegend(
              theme: ChartTheme.solarizedLightTheme(),
            ),
          ),
        ],
      ),
    );
  });

  group('Themed with Customizations Tests', () {
    goldenTest(
      'Charts with custom styling and themes',
      fileName: 'themed_customizations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'dark_rounded_bars',
            child: buildComplexThemedWithCustomizations(),
          ),
          GoldenTestScenario(
            name: 'default_rounded_bars',
            child: buildComplexThemedWithCustomizations(
              theme: ChartTheme.defaultTheme(),
            ),
          ),
        ],
      ),
    );
  });

  group('Multi-Series with Styling Tests', () {
    goldenTest(
      'Multi-series charts with various styles',
      fileName: 'multi_series_styled',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'scatter_default',
            child: buildMultiSeriesScatterPlot(),
          ),
          GoldenTestScenario(
            name: 'scatter_dark',
            child: buildMultiSeriesScatterPlot(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'line_default',
            child: buildMultiSeriesLineChart(),
          ),
          GoldenTestScenario(
            name: 'line_solarized',
            child: buildMultiSeriesLineChart(
              theme: ChartTheme.solarizedLightTheme(),
            ),
          ),
          GoldenTestScenario(
            name: 'bars_grouped',
            child: buildMultiSeriesBarChart(style: BarStyle.grouped),
          ),
          GoldenTestScenario(
            name: 'bars_stacked',
            child: buildMultiSeriesBarChart(style: BarStyle.stacked),
          ),
        ],
      ),
    );
  });

  group('Comprehensive Feature Combination Tests', () {
    goldenTest(
      'Charts combining multiple advanced features',
      fileName: 'comprehensive_combinations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'bar_all_features',
            child: buildBarChart(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderWidth: 1.0,
              alpha: 0.8,
              xAxisTitle: 'Category',
              yAxisTitle: 'Value',
              theme: ChartTheme.darkTheme(),
            ),
          ),
          GoldenTestScenario(
            name: 'scatter_all_features',
            child: buildScatterPlot(
              shape: PointShape.square,
              borderWidth: 2.0,
              alpha: 0.7,
              size: 8.0,
              xAxisTitle: 'X Axis',
              yAxisTitle: 'Y Axis',
              theme: ChartTheme.solarizedDarkTheme(),
            ),
          ),
          GoldenTestScenario(
            name: 'heat_map_all_features',
            child: buildHeatMap(
              colorScale: GradientColorScale.coolWarm(),
              cellBorderRadius: const BorderRadius.all(Radius.circular(4)),
              showValues: true,
              theme: ChartTheme.darkTheme(),
            ),
          ),
        ],
      ),
    );
  });
}
