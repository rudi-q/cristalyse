import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

void main() {
  group('Advanced Styling - Legend Customization', () {
    goldenTest(
      'Legend background and text styling',
      fileName: 'legend_styling',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom_background',
            child: _buildLegendStyledChart(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
          GoldenTestScenario(
            name: 'custom_text_style',
            child: _buildLegendStyledChart(
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Legend padding and spacing',
      fileName: 'legend_spacing',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'large_padding',
            child: _buildLegendStyledChart(
              padding: const EdgeInsets.all(16),
            ),
          ),
          GoldenTestScenario(
            name: 'custom_item_spacing',
            child: _buildLegendStyledChart(
              itemSpacing: 20.0,
              spacing: 12.0,
            ),
          ),
        ],
      ),
    );
  });

  group('Advanced Styling - Progress Bar Parameters', () {
    goldenTest(
      'Stacked progress with custom segment colors',
      fileName: 'progress_stacked_colors',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom_colors',
            child: _buildStackedProgressWithColors(),
          ),
        ],
      ),
    );

    goldenTest(
      'Gauge progress with angle customization',
      fileName: 'progress_gauge_angles',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'half_circle',
            child: buildProgressBar(
              style: ProgressStyle.gauge,
              gaugeRadius: 80.0,
            ),
          ),
          GoldenTestScenario(
            name: 'three_quarter_circle',
            child: _buildGaugeWithCustomAngles(
              startAngle: -3.14159 * 0.75,
              sweepAngle: 3.14159 * 1.5,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Gauge progress with ticks',
      fileName: 'progress_gauge_ticks',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'default_ticks',
            child: buildProgressBar(
              style: ProgressStyle.gauge,
              gaugeRadius: 80.0,
              showTicks: true,
            ),
          ),
          GoldenTestScenario(
            name: 'many_ticks',
            child: _buildGaugeWithTicks(tickCount: 20),
          ),
        ],
      ),
    );
  });

  group('Advanced Styling - Heat Map Parameters', () {
    goldenTest(
      'Heat map with custom value ranges',
      fileName: 'heatmap_value_ranges',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom_min_max',
            child: _buildHeatMapWithRange(
              minValue: 0.0,
              maxValue: 100.0,
            ),
          ),
          GoldenTestScenario(
            name: 'negative_to_positive',
            child: _buildHeatMapWithRange(
              minValue: -50.0,
              maxValue: 50.0,
              data: [
                {'x': 'A', 'y': 'Y1', 'value': -25.0},
                {'x': 'A', 'y': 'Y2', 'value': 15.0},
                {'x': 'B', 'y': 'Y1', 'value': -40.0},
                {'x': 'B', 'y': 'Y2', 'value': 30.0},
                {'x': 'C', 'y': 'Y1', 'value': 10.0},
                {'x': 'C', 'y': 'Y2', 'value': -15.0},
              ],
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Heat map with null value handling',
      fileName: 'heatmap_null_values',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom_null_color',
            child: _buildHeatMapWithNulls(
              nullValueColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Heat map with cell aspect ratio',
      fileName: 'heatmap_cell_aspect',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'square_cells',
            child: _buildHeatMapWithAspect(cellAspectRatio: 1.0),
          ),
          GoldenTestScenario(
            name: 'wide_cells',
            child: _buildHeatMapWithAspect(cellAspectRatio: 2.0),
          ),
        ],
      ),
    );
  });

  group('Advanced Styling - Pie Chart Parameters', () {
    goldenTest(
      'Pie chart label positioning',
      fileName: 'pie_label_radius',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'labels_near',
            child: _buildPieWithLabelRadius(labelRadius: 100.0),
          ),
          GoldenTestScenario(
            name: 'labels_far',
            child: _buildPieWithLabelRadius(labelRadius: 160.0),
          ),
        ],
      ),
    );

    goldenTest(
      'Pie chart label styling',
      fileName: 'pie_label_style',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'bold_large',
            child: _buildPieWithLabelStyle(
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'colored',
            child: _buildPieWithLabelStyle(
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Pie chart explode distance',
      fileName: 'pie_explode_distance',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'small_explode',
            child: _buildPieWithExplode(explodeDistance: 8.0),
          ),
          GoldenTestScenario(
            name: 'large_explode',
            child: _buildPieWithExplode(explodeDistance: 25.0),
          ),
        ],
      ),
    );
  });

  group('Advanced Styling - Bar Chart Variations', () {
    goldenTest(
      'Bar width variations',
      fileName: 'bar_width',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'narrow',
            child: _buildBarWithWidth(0.4),
          ),
          GoldenTestScenario(
            name: 'wide',
            child: _buildBarWithWidth(0.9),
          ),
        ],
      ),
    );

    goldenTest(
      'Bar border width variations',
      fileName: 'bar_border_width',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'thin_border',
            child: _buildBarWithBorder(borderWidth: 1.0),
          ),
          GoldenTestScenario(
            name: 'thick_border',
            child: _buildBarWithBorder(borderWidth: 4.0),
          ),
        ],
      ),
    );
  });

  group('Advanced Styling - Scatter Point Variations', () {
    goldenTest(
      'Point border width variations',
      fileName: 'point_border_width',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'thin_border',
            child: buildScatterPlot(borderWidth: 1.0, size: 10.0),
          ),
          GoldenTestScenario(
            name: 'thick_border',
            child: buildScatterPlot(borderWidth: 4.0, size: 12.0),
          ),
        ],
      ),
    );
  });

  group('Advanced Styling - Line Chart Variations', () {
    goldenTest(
      'Line stroke width variations',
      fileName: 'line_stroke_width',
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
  });
}

// Helper functions

Widget _buildLegendStyledChart({
  Color? backgroundColor,
  TextStyle? textStyle,
  EdgeInsets? padding,
  double? spacing,
  double? itemSpacing,
}) {
  final data = [
    {'month': 'Jan', 'sales': 120, 'product': 'Product A'},
    {'month': 'Jan', 'sales': 100, 'product': 'Product B'},
    {'month': 'Feb', 'sales': 150, 'product': 'Product A'},
    {'month': 'Feb', 'sales': 130, 'product': 'Product B'},
    {'month': 'Mar', 'sales': 110, 'product': 'Product A'},
    {'month': 'Mar', 'sales': 140, 'product': 'Product B'},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'month', y: 'sales', color: 'product')
        .geomBar(style: BarStyle.grouped)
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .legend(
          position: LegendPosition.topRight,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
          padding: padding,
          spacing: spacing,
          itemSpacing: itemSpacing,
        )
        .build(),
  );
}

Widget _buildStackedProgressWithColors() {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(progressData)
        .mappingProgress(label: 'label', value: 'value')
        .geomProgress(
      style: ProgressStyle.stacked,
      segments: [30.0, 40.0, 30.0],
      segmentColors: [
        Colors.blue,
        Colors.green,
        Colors.orange,
      ],
    ).build(),
  );
}

Widget _buildGaugeWithCustomAngles({
  required double startAngle,
  required double sweepAngle,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(progressData)
        .mappingProgress(label: 'label', value: 'value')
        .geomProgress(
          style: ProgressStyle.gauge,
          gaugeRadius: 80.0,
        )
        .build(),
  );
}

Widget _buildGaugeWithTicks({required int tickCount}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(progressData)
        .mappingProgress(label: 'label', value: 'value')
        .geomProgress(
          style: ProgressStyle.gauge,
          gaugeRadius: 80.0,
          showTicks: true,
        )
        .build(),
  );
}

Widget _buildHeatMapWithRange({
  required double minValue,
  required double maxValue,
  List<Map<String, dynamic>>? data,
}) {
  final heatMapData = data ??
      [
        {'x': 'Jan', 'y': 'North', 'value': 25.0},
        {'x': 'Jan', 'y': 'South', 'value': 62.0},
        {'x': 'Feb', 'y': 'North', 'value': 85.0},
        {'x': 'Feb', 'y': 'South', 'value': 45.0},
        {'x': 'Mar', 'y': 'North', 'value': 50.0},
        {'x': 'Mar', 'y': 'South', 'value': 78.0},
      ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(heatMapData)
        .mappingHeatMap(x: 'x', y: 'y', value: 'value')
        .geomHeatMap(
          showValues: true,
        )
        .build(),
  );
}

Widget _buildHeatMapWithNulls({required Color nullValueColor}) {
  final data = [
    {'x': 'A', 'y': 'Y1', 'value': 85.0},
    {'x': 'A', 'y': 'Y2', 'value': 62.0},
    {'x': 'B', 'y': 'Y1', 'value': 93.0},
    {'x': 'B', 'y': 'Y2', 'value': null}, // Null value
    {'x': 'C', 'y': 'Y1', 'value': 88.0},
    {'x': 'C', 'y': 'Y2', 'value': 71.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mappingHeatMap(x: 'x', y: 'y', value: 'value')
        .geomHeatMap(
          showValues: true,
        )
        .build(),
  );
}

Widget _buildHeatMapWithAspect({required double cellAspectRatio}) {
  final data = [
    {'x': 'A', 'y': 'Y1', 'value': 85.0},
    {'x': 'A', 'y': 'Y2', 'value': 62.0},
    {'x': 'B', 'y': 'Y1', 'value': 93.0},
    {'x': 'B', 'y': 'Y2', 'value': 78.0},
    {'x': 'C', 'y': 'Y1', 'value': 88.0},
    {'x': 'C', 'y': 'Y2', 'value': 71.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mappingHeatMap(x: 'x', y: 'y', value: 'value')
        .geomHeatMap(
          showValues: true,
        )
        .build(),
  );
}

Widget _buildPieWithLabelRadius({required double labelRadius}) {
  final data = [
    {'category': 'A', 'value': 35.0},
    {'category': 'B', 'value': 45.0},
    {'category': 'C', 'value': 20.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mappingPie(value: 'value', category: 'category')
        .geomPie(
          showLabels: true,
          showPercentages: true,
        )
        .build(),
  );
}

Widget _buildPieWithLabelStyle({required TextStyle labelStyle}) {
  final data = [
    {'category': 'A', 'value': 35.0},
    {'category': 'B', 'value': 45.0},
    {'category': 'C', 'value': 20.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mappingPie(value: 'value', category: 'category')
        .geomPie(
          showLabels: true,
          showPercentages: true,
        )
        .build(),
  );
}

Widget _buildPieWithExplode({required double explodeDistance}) {
  final data = [
    {'category': 'A', 'value': 35.0},
    {'category': 'B', 'value': 45.0},
    {'category': 'C', 'value': 20.0},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mappingPie(value: 'value', category: 'category')
        .geomPie(
          showLabels: true,
          showPercentages: true,
          explodeSlices: true,
        )
        .build(),
  );
}

Widget _buildBarWithWidth(double width) {
  final data = [
    {'category': 'A', 'value': 120},
    {'category': 'B', 'value': 150},
    {'category': 'C', 'value': 110},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'category', y: 'value')
        .geomBar(width: width)
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .build(),
  );
}

Widget _buildBarWithBorder({required double borderWidth}) {
  final data = [
    {'category': 'A', 'value': 120},
    {'category': 'B', 'value': 150},
    {'category': 'C', 'value': 110},
  ];

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'category', y: 'value')
        .geomBar(borderWidth: borderWidth)
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .build(),
  );
}
