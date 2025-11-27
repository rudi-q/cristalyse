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
            child: buildScatterPlot(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildScatterPlot(theme: ChartTheme.solarizedLightTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildScatterPlot(theme: ChartTheme.solarizedDarkTheme()),
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
            child: buildBarChart(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildBarChart(theme: ChartTheme.solarizedLightTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildBarChart(theme: ChartTheme.solarizedDarkTheme()),
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
            child: buildLineChart(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildLineChart(theme: ChartTheme.solarizedLightTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildLineChart(theme: ChartTheme.solarizedDarkTheme()),
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
            child: buildPieChart(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildPieChart(theme: ChartTheme.solarizedLightTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildPieChart(theme: ChartTheme.solarizedDarkTheme()),
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
            child: buildHeatMap(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildHeatMap(theme: ChartTheme.solarizedLightTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildHeatMap(theme: ChartTheme.solarizedDarkTheme()),
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
            child: buildMultiSeriesLineChart(theme: ChartTheme.darkTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildMultiSeriesLineChart(
                theme: ChartTheme.solarizedLightTheme()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildMultiSeriesLineChart(
                theme: ChartTheme.solarizedDarkTheme()),
          ),
        ],
      ),
    );
  });
}
