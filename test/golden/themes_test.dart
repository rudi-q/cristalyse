import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

/// Visual regression tests for all theme variations
void main() {
  group('Theme Tests - Scatter Plots', () {
    goldenTest(
      'Scatter plot themes',
      fileName: 'themes_scatter',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default',
            child: buildScatterPlot(theme: ChartTheme.defaultTheme()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: buildScatterPlot(theme: ChartTheme.dark()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildScatterPlot(theme: ChartTheme.solarizedLight()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildScatterPlot(theme: ChartTheme.solarizedDark()),
          ),
        ],
      ),
    );
  });

  group('Theme Tests - Bar Charts', () {
    goldenTest(
      'Bar chart themes',
      fileName: 'themes_bar',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default',
            child: buildBarChart(theme: ChartTheme.defaultTheme()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: buildBarChart(theme: ChartTheme.dark()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildBarChart(theme: ChartTheme.solarizedLight()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildBarChart(theme: ChartTheme.solarizedDark()),
          ),
        ],
      ),
    );
  });

  group('Theme Tests - Line Charts', () {
    goldenTest(
      'Line chart themes',
      fileName: 'themes_line',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default',
            child: buildLineChart(theme: ChartTheme.defaultTheme()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: buildLineChart(theme: ChartTheme.dark()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildLineChart(theme: ChartTheme.solarizedLight()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildLineChart(theme: ChartTheme.solarizedDark()),
          ),
        ],
      ),
    );
  });

  group('Theme Tests - Pie Charts', () {
    goldenTest(
      'Pie chart themes',
      fileName: 'themes_pie',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default',
            child: buildPieChart(theme: ChartTheme.defaultTheme()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: buildPieChart(theme: ChartTheme.dark()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildPieChart(theme: ChartTheme.solarizedLight()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildPieChart(theme: ChartTheme.solarizedDark()),
          ),
        ],
      ),
    );
  });

  group('Theme Tests - Heat Maps', () {
    goldenTest(
      'Heat map themes',
      fileName: 'themes_heat_map',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default',
            child: buildHeatMap(theme: ChartTheme.defaultTheme()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: buildHeatMap(theme: ChartTheme.dark()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildHeatMap(theme: ChartTheme.solarizedLight()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildHeatMap(theme: ChartTheme.solarizedDark()),
          ),
        ],
      ),
    );
  });

  group('Theme Tests - Multi-Series', () {
    goldenTest(
      'Multi-series line chart themes',
      fileName: 'themes_multi_series',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default',
            child: buildMultiSeriesLineChart(theme: ChartTheme.defaultTheme()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: buildMultiSeriesLineChart(theme: ChartTheme.dark()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildMultiSeriesLineChart(theme: ChartTheme.solarizedLight()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildMultiSeriesLineChart(theme: ChartTheme.solarizedDark()),
          ),
        ],
      ),
    );
  });
}
