import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

/// Visual regression tests for special chart features
void main() {
  group('Axis Title Tests', () {
    goldenTest(
      'Charts with axis titles',
      fileName: 'axis_titles',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'scatter_with_titles',
            child: buildScatterPlot(
              xAxisTitle: 'Time (hours)',
              yAxisTitle: 'Revenue (\$)',
            ),
          ),
          GoldenTestScenario(
            name: 'bar_with_titles',
            child: buildBarChart(
              xAxisTitle: 'Product Category',
              yAxisTitle: 'Sales Count',
            ),
          ),
        ],
      ),
    );
  });

  group('Custom Bounds Tests', () {
    goldenTest(
      'Charts with custom Y-axis bounds',
      fileName: 'custom_bounds',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'scatter_negative_to_positive',
            child: buildScatterPlot(yMin: -10.0, yMax: 100.0),
          ),
          GoldenTestScenario(
            name: 'bar_non_zero_baseline',
            child: buildBarChart(yMin: 20.0, yMax: 80.0),
          ),
        ],
      ),
    );
  });

  group('Transparency (Alpha) Tests', () {
    goldenTest(
      'Charts with different alpha values',
      fileName: 'transparency',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'points_25_percent',
            child: buildScatterPlot(alpha: 0.25),
          ),
          GoldenTestScenario(
            name: 'points_50_percent',
            child: buildScatterPlot(alpha: 0.5),
          ),
          GoldenTestScenario(
            name: 'points_75_percent',
            child: buildScatterPlot(alpha: 0.75),
          ),
          GoldenTestScenario(
            name: 'area_30_percent',
            child: buildAreaChart(alpha: 0.3),
          ),
          GoldenTestScenario(
            name: 'bars_60_percent',
            child: buildBarChart(alpha: 0.6),
          ),
        ],
      ),
    );
  });

  group('Coordinate Flipping Tests', () {
    goldenTest(
      'Charts with flipped coordinates',
      fileName: 'coord_flip',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'scatter_normal',
            child: buildScatterPlot(coordFlipped: false),
          ),
          GoldenTestScenario(
            name: 'scatter_flipped',
            child: buildScatterPlot(coordFlipped: true),
          ),
          GoldenTestScenario(
            name: 'line_normal',
            child: buildLineChart(coordFlipped: false),
          ),
          GoldenTestScenario(
            name: 'line_flipped',
            child: buildLineChart(coordFlipped: true),
          ),
        ],
      ),
    );
  });

  group('Border Effects Tests', () {
    goldenTest(
      'Charts with borders',
      fileName: 'borders',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'points_thin_border',
            child: buildScatterPlot(borderWidth: 1.0),
          ),
          GoldenTestScenario(
            name: 'points_thick_border',
            child: buildScatterPlot(borderWidth: 3.0),
          ),
          GoldenTestScenario(
            name: 'bars_with_border',
            child: buildBarChart(borderWidth: 2.0),
          ),
        ],
      ),
    );
  });

  group('Border Radius Tests', () {
    goldenTest(
      'Charts with rounded corners',
      fileName: 'border_radius',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'bars_slight_radius',
            child: buildBarChart(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
          GoldenTestScenario(
            name: 'bars_medium_radius',
            child: buildBarChart(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          GoldenTestScenario(
            name: 'bars_large_radius',
            child: buildBarChart(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ],
      ),
    );
  });
}
