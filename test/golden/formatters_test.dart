import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'helpers/chart_builders.dart';

void main() {
  group('Formatter Tests - Currency', () {
    goldenTest(
      'Currency formatting on Y-axis',
      fileName: 'formatter_currency',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'simple_currency',
            child: _buildFormattedBarChart(
              formatter: NumberFormat.simpleCurrency().format,
              title: 'Revenue (\$)',
            ),
          ),
          GoldenTestScenario(
            name: 'currency_with_symbol',
            child: _buildFormattedBarChart(
              formatter: (value) => '\$${value.round()}k',
              title: 'Sales',
            ),
          ),
        ],
      ),
    );
  });

  group('Formatter Tests - Compact Notation', () {
    goldenTest(
      'Compact number formatting',
      fileName: 'formatter_compact',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'compact_short',
            child: _buildFormattedScatterChart(
              xFormatter: NumberFormat.compact().format,
              yFormatter: NumberFormat.compact().format,
              xTitle: 'Users',
              yTitle: 'Revenue',
            ),
          ),
          GoldenTestScenario(
            name: 'compact_long',
            child: _buildFormattedScatterChart(
              xFormatter: NumberFormat.compactLong().format,
              yFormatter: NumberFormat.compactLong().format,
              xTitle: 'Population',
              yTitle: 'GDP',
            ),
          ),
        ],
      ),
    );
  });

  group('Formatter Tests - Percentage', () {
    goldenTest(
      'Percentage formatting',
      fileName: 'formatter_percentage',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'percentage_whole',
            child: _buildFormattedBarChart(
              formatter: (value) => '${value.round()}%',
              title: 'Completion Rate',
              data: [
                {'category': 'Q1', 'value': 45.0},
                {'category': 'Q2', 'value': 68.0},
                {'category': 'Q3', 'value': 82.0},
                {'category': 'Q4', 'value': 95.0},
              ],
            ),
          ),
          GoldenTestScenario(
            name: 'percentage_decimal',
            child: _buildFormattedBarChart(
              formatter: (value) => '${value.toStringAsFixed(1)}%',
              title: 'Growth Rate',
              data: [
                {'category': 'Q1', 'value': 12.5},
                {'category': 'Q2', 'value': 18.3},
                {'category': 'Q3', 'value': 22.7},
                {'category': 'Q4', 'value': 28.9},
              ],
            ),
          ),
        ],
      ),
    );
  });

  group('Formatter Tests - Custom Units', () {
    goldenTest(
      'Temperature formatting',
      fileName: 'formatter_temperature',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'celsius',
            child: _buildFormattedLineChart(
              formatter: (value) => '${value.toStringAsFixed(1)}°C',
              title: 'Temperature',
              data: [
                {'day': 'Mon', 'temp': 18.5},
                {'day': 'Tue', 'temp': 20.2},
                {'day': 'Wed', 'temp': 22.8},
                {'day': 'Thu', 'temp': 21.5},
                {'day': 'Fri', 'temp': 19.7},
              ],
            ),
          ),
          GoldenTestScenario(
            name: 'fahrenheit',
            child: _buildFormattedLineChart(
              formatter: (value) => '${value.round()}°F',
              title: 'Temperature',
              data: [
                {'day': 'Mon', 'temp': 65.0},
                {'day': 'Tue', 'temp': 68.0},
                {'day': 'Wed', 'temp': 73.0},
                {'day': 'Thu', 'temp': 71.0},
                {'day': 'Fri', 'temp': 67.0},
              ],
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Weight and distance formatting',
      fileName: 'formatter_units',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'kilograms',
            child: _buildFormattedBarChart(
              formatter: (value) => '${value.round()} kg',
              title: 'Weight',
              data: [
                {'category': 'Jan', 'value': 75.0},
                {'category': 'Feb', 'value': 73.0},
                {'category': 'Mar', 'value': 71.0},
                {'category': 'Apr', 'value': 69.0},
              ],
            ),
          ),
          GoldenTestScenario(
            name: 'kilometers',
            child: _buildFormattedLineChart(
              formatter: (value) => '${value.toStringAsFixed(1)} km',
              title: 'Distance',
              data: [
                {'day': 'Mon', 'temp': 5.2},
                {'day': 'Tue', 'temp': 6.8},
                {'day': 'Wed', 'temp': 4.5},
                {'day': 'Thu', 'temp': 7.3},
                {'day': 'Fri', 'temp': 8.1},
              ],
            ),
          ),
        ],
      ),
    );
  });

  group('Formatter Tests - Time and Duration', () {
    goldenTest(
      'Duration formatting',
      fileName: 'formatter_duration',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'minutes',
            child: _buildFormattedBarChart(
              formatter: (value) => '${value.round()}m',
              title: 'Duration',
              data: [
                {'category': 'Task 1', 'value': 15.0},
                {'category': 'Task 2', 'value': 28.0},
                {'category': 'Task 3', 'value': 42.0},
                {'category': 'Task 4', 'value': 35.0},
              ],
            ),
          ),
          GoldenTestScenario(
            name: 'hours_minutes',
            child: _buildFormattedBarChart(
              formatter: (value) {
                final hours = value ~/ 60;
                final minutes = (value % 60).round();
                return '${hours}h ${minutes}m';
              },
              title: 'Time Spent',
              data: [
                {'category': 'Mon', 'value': 125.0},
                {'category': 'Tue', 'value': 145.0},
                {'category': 'Wed', 'value': 98.0},
                {'category': 'Thu', 'value': 165.0},
              ],
            ),
          ),
        ],
      ),
    );
  });

  group('Formatter Tests - Scientific and Decimal', () {
    goldenTest(
      'Decimal precision formatting',
      fileName: 'formatter_decimal',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'one_decimal',
            child: _buildFormattedLineChart(
              formatter: (value) => value.toStringAsFixed(1),
              title: 'Score',
              data: [
                {'day': 'Mon', 'temp': 4.2},
                {'day': 'Tue', 'temp': 4.7},
                {'day': 'Wed', 'temp': 3.9},
                {'day': 'Thu', 'temp': 4.5},
                {'day': 'Fri', 'temp': 4.8},
              ],
            ),
          ),
          GoldenTestScenario(
            name: 'two_decimals',
            child: _buildFormattedLineChart(
              formatter: (value) => value.toStringAsFixed(2),
              title: 'Precision',
              data: [
                {'day': 'Mon', 'temp': 3.14},
                {'day': 'Tue', 'temp': 2.71},
                {'day': 'Wed', 'temp': 1.61},
                {'day': 'Thu', 'temp': 4.66},
                {'day': 'Fri', 'temp': 3.33},
              ],
            ),
          ),
        ],
      ),
    );
  });

  group('Formatter Tests - Multi-Axis', () {
    goldenTest(
      'Different formatters on dual Y-axis',
      fileName: 'formatter_dual_axis',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'currency_and_percentage',
            child: _buildDualAxisFormattedChart(),
          ),
        ],
      ),
    );
  });

  group('Formatter Tests - Heat Maps', () {
    goldenTest(
      'Heat map value formatters',
      fileName: 'formatter_heatmap',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'percentage_values',
            child: _buildFormattedHeatMap(
              formatter: (value) => '${value.toInt()}%',
            ),
          ),
          GoldenTestScenario(
            name: 'currency_values',
            child: _buildFormattedHeatMap(
              formatter: (value) => '\$${value.round()}k',
            ),
          ),
        ],
      ),
    );
  });
}

// Helper functions

Widget _buildFormattedBarChart({
  required String Function(num) formatter,
  required String title,
  List<Map<String, dynamic>>? data,
}) {
  final chartData = data ??
      [
        {'category': 'Q1', 'value': 1250.0},
        {'category': 'Q2', 'value': 1850.0},
        {'category': 'Q3', 'value': 2100.0},
        {'category': 'Q4', 'value': 2750.0},
      ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(chartData)
        .mapping(x: 'category', y: 'value')
        .geomBar()
        .scaleXOrdinal()
        .scaleYContinuous(
          min: 0,
          labels: formatter,
          title: title,
        )
        .theme(ChartTheme.defaultTheme())
        .build(),
  );
}

Widget _buildFormattedLineChart({
  required String Function(num) formatter,
  required String title,
  required List<Map<String, dynamic>> data,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'day', y: 'temp')
        .geomLine(strokeWidth: 2.0)
        .geomPoint(size: 5.0)
        .scaleXOrdinal()
        .scaleYContinuous(
          labels: formatter,
          title: title,
        )
        .theme(ChartTheme.defaultTheme())
        .build(),
  );
}

Widget _buildFormattedScatterChart({
  required String Function(num) xFormatter,
  required String Function(num) yFormatter,
  required String xTitle,
  required String yTitle,
}) {
  final data = [
    {'x': 1200.0, 'y': 45000.0},
    {'x': 2500.0, 'y': 78000.0},
    {'x': 4200.0, 'y': 125000.0},
    {'x': 6800.0, 'y': 198000.0},
    {'x': 9500.0, 'y': 285000.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'x', y: 'y')
        .geomPoint(size: 8.0)
        .scaleXContinuous(
          labels: xFormatter,
          title: xTitle,
        )
        .scaleYContinuous(
          labels: yFormatter,
          title: yTitle,
        )
        .theme(ChartTheme.defaultTheme())
        .build(),
  );
}

Widget _buildDualAxisFormattedChart() {
  final data = [
    {'month': 'Jan', 'revenue': 12500.0, 'margin': 15.5},
    {'month': 'Feb', 'revenue': 18500.0, 'margin': 18.2},
    {'month': 'Mar', 'revenue': 21000.0, 'margin': 22.8},
    {'month': 'Apr', 'revenue': 27500.0, 'margin': 25.3},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'month', y: 'revenue')
        .mappingY2('margin')
        .geomBar(yAxis: YAxis.primary)
        .geomLine(yAxis: YAxis.secondary, strokeWidth: 3.0)
        .geomPoint(yAxis: YAxis.secondary, size: 6.0)
        .scaleXOrdinal()
        .scaleYContinuous(
          min: 0,
          labels: NumberFormat.simpleCurrency().format,
          title: 'Revenue',
        )
        .scaleY2Continuous(
          min: 0,
          labels: (value) => '${value.toStringAsFixed(1)}%',
          title: 'Margin',
        )
        .theme(ChartTheme.defaultTheme())
        .build(),
  );
}

Widget _buildFormattedHeatMap({
  required String Function(num) formatter,
}) {
  final data = [
    {'month': 'Jan', 'region': 'North', 'value': 85.0},
    {'month': 'Jan', 'region': 'South', 'value': 62.0},
    {'month': 'Feb', 'region': 'North', 'value': 93.0},
    {'month': 'Feb', 'region': 'South', 'value': 78.0},
    {'month': 'Mar', 'region': 'North', 'value': 88.0},
    {'month': 'Mar', 'region': 'South', 'value': 71.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mappingHeatMap(x: 'month', y: 'region', value: 'value')
        .geomHeatMap(
          showValues: true,
          valueFormatter: formatter,
        )
        .theme(ChartTheme.defaultTheme())
        .build(),
  );
}
