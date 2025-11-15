import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

/// Visual regression tests for legend functionality
void main() {
  group('Legend Position Tests', () {
    goldenTest(
      'Legend corner positions',
      fileName: 'legend_corners',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'top_left',
            child: buildChartWithLegend(position: LegendPosition.topLeft),
          ),
          GoldenTestScenario(
            name: 'top_right',
            child: buildChartWithLegend(position: LegendPosition.topRight),
          ),
          GoldenTestScenario(
            name: 'bottom_left',
            child: buildChartWithLegend(position: LegendPosition.bottomLeft),
          ),
          GoldenTestScenario(
            name: 'bottom_right',
            child: buildChartWithLegend(position: LegendPosition.bottomRight),
          ),
        ],
      ),
    );

    goldenTest(
      'Legend edge positions',
      fileName: 'legend_edges',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'top',
            child: buildChartWithLegend(position: LegendPosition.top),
          ),
          GoldenTestScenario(
            name: 'bottom',
            child: buildChartWithLegend(position: LegendPosition.bottom),
          ),
          GoldenTestScenario(
            name: 'left',
            child: buildChartWithLegend(position: LegendPosition.left),
          ),
          GoldenTestScenario(
            name: 'right',
            child: buildChartWithLegend(position: LegendPosition.right),
          ),
        ],
      ),
    );
  });

  group('Legend Orientation Tests', () {
    goldenTest(
      'Legend orientations',
      fileName: 'legend_orientations',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'horizontal',
            child: buildChartWithLegend(
              position: LegendPosition.bottom,
              orientation: LegendOrientation.horizontal,
            ),
          ),
          GoldenTestScenario(
            name: 'vertical',
            child: buildChartWithLegend(
              position: LegendPosition.right,
              orientation: LegendOrientation.vertical,
            ),
          ),
          GoldenTestScenario(
            name: 'auto',
            child: buildChartWithLegend(
              position: LegendPosition.topRight,
              orientation: LegendOrientation.auto,
            ),
          ),
        ],
      ),
    );
  });

  group('Legend Symbol Tests', () {
    goldenTest(
      'Legend symbol shapes',
      fileName: 'legend_symbols',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'auto',
            child: buildChartWithLegend(symbolShape: LegendSymbol.auto),
          ),
          GoldenTestScenario(
            name: 'circle',
            child: buildChartWithLegend(symbolShape: LegendSymbol.circle),
          ),
          GoldenTestScenario(
            name: 'square',
            child: buildChartWithLegend(symbolShape: LegendSymbol.square),
          ),
          GoldenTestScenario(
            name: 'line',
            child: buildChartWithLegend(symbolShape: LegendSymbol.line),
          ),
        ],
      ),
    );
  });

  group('Legend with Different Themes', () {
    goldenTest(
      'Legend themes',
      fileName: 'legend_themes',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default',
            child: buildChartWithLegend(theme: ChartTheme.defaultTheme()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: buildChartWithLegend(theme: ChartTheme.dark()),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: buildChartWithLegend(theme: ChartTheme.solarizedLight()),
          ),
          GoldenTestScenario(
            name: 'solarized_dark',
            child: buildChartWithLegend(theme: ChartTheme.solarizedDark()),
          ),
        ],
      ),
    );
  });
}
