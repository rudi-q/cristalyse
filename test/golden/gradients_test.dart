import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

void main() {
  group('Gradient Tests - Bar Charts', () {
    goldenTest(
      'Linear gradients on vertical bars',
      fileName: 'gradient_bars_linear',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'bottom_to_top',
            child: _buildGradientBarChart(
              gradientType: 'linear_vertical',
            ),
          ),
          GoldenTestScenario(
            name: 'top_to_bottom',
            child: _buildGradientBarChart(
              gradientType: 'linear_vertical_reverse',
            ),
          ),
          GoldenTestScenario(
            name: 'diagonal',
            child: _buildGradientBarChart(
              gradientType: 'linear_diagonal',
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Radial gradients on bars',
      fileName: 'gradient_bars_radial',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'centered',
            child: _buildGradientBarChart(
              gradientType: 'radial_center',
            ),
          ),
          GoldenTestScenario(
            name: 'with_border',
            child: _buildGradientBarChart(
              gradientType: 'radial_center',
              borderWidth: 2.0,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Sweep gradients on bars',
      fileName: 'gradient_bars_sweep',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'circular_sweep',
            child: _buildGradientBarChart(
              gradientType: 'sweep',
            ),
          ),
          GoldenTestScenario(
            name: 'with_rounded_corners',
            child: _buildGradientBarChart(
              gradientType: 'sweep',
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Mixed gradient types in single chart',
      fileName: 'gradient_bars_mixed',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'all_types',
            child: _buildMixedGradientBarChart(),
          ),
        ],
      ),
    );
  });

  group('Gradient Tests - Scatter Points', () {
    goldenTest(
      'Linear gradients on scatter points',
      fileName: 'gradient_points_linear',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'vertical_gradient',
            child: _buildGradientScatterChart(
              gradientType: 'linear_vertical',
            ),
          ),
          GoldenTestScenario(
            name: 'diagonal_gradient',
            child: _buildGradientScatterChart(
              gradientType: 'linear_diagonal',
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Radial gradients on scatter points',
      fileName: 'gradient_points_radial',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'centered',
            child: _buildGradientScatterChart(
              gradientType: 'radial_center',
            ),
          ),
          GoldenTestScenario(
            name: 'large_points',
            child: _buildGradientScatterChart(
              gradientType: 'radial_center',
              pointSize: 20.0,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'Sweep gradients on scatter points',
      fileName: 'gradient_points_sweep',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'circular_sweep',
            child: _buildGradientScatterChart(
              gradientType: 'sweep',
            ),
          ),
          GoldenTestScenario(
            name: 'with_border',
            child: _buildGradientScatterChart(
              gradientType: 'sweep',
              borderWidth: 2.0,
            ),
          ),
        ],
      ),
    );
  });

  group('Gradient Tests - Horizontal Bars', () {
    goldenTest(
      'Gradients on horizontal bars',
      fileName: 'gradient_horizontal_bars',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'linear_left_to_right',
            child: _buildGradientBarChart(
              gradientType: 'linear_vertical',
              flipped: true,
            ),
          ),
          GoldenTestScenario(
            name: 'radial_centered',
            child: _buildGradientBarChart(
              gradientType: 'radial_center',
              flipped: true,
            ),
          ),
        ],
      ),
    );
  });

  group('Gradient Tests - Grouped & Stacked Bars', () {
    goldenTest(
      'Gradients on grouped bars',
      fileName: 'gradient_grouped_bars',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'linear_gradients',
            child: _buildGroupedGradientBars(),
          ),
        ],
      ),
    );

    goldenTest(
      'Gradients on stacked bars',
      fileName: 'gradient_stacked_bars',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'linear_gradients',
            child: _buildStackedGradientBars(),
          ),
        ],
      ),
    );
  });

  group('Gradient Tests - With Themes', () {
    goldenTest(
      'Gradients with different themes',
      fileName: 'gradient_with_themes',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'dark_theme',
            child: _buildGradientBarChart(
              gradientType: 'linear_vertical',
              theme: ChartTheme.darkTheme(),
            ),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: _buildGradientBarChart(
              gradientType: 'radial_center',
              theme: ChartTheme.solarizedLightTheme(),
            ),
          ),
        ],
      ),
    );
  });
}

// Helper functions

Widget _buildGradientBarChart({
  required String gradientType,
  double? borderWidth,
  BorderRadius? borderRadius,
  bool flipped = false,
  ChartTheme? theme,
}) {
  final data = [
    {'category': 'A', 'value': 120},
    {'category': 'B', 'value': 150},
    {'category': 'C', 'value': 110},
    {'category': 'D', 'value': 180},
  ];

  final gradients = _getGradientsForType(gradientType);

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'category', y: 'value', color: 'category')
        .geomBar(
          borderRadius: borderRadius,
          borderWidth: borderWidth,
        )
        .conditional(flipped, (chart) => chart.coordFlip())
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryGradients: gradients)
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget _buildGradientScatterChart({
  required String gradientType,
  double pointSize = 12.0,
  double? borderWidth,
  ChartTheme? theme,
}) {
  final data = [
    {'category': 'A', 'x': 1.0, 'y': 2.0},
    {'category': 'B', 'x': 2.0, 'y': 3.5},
    {'category': 'C', 'x': 3.0, 'y': 1.5},
    {'category': 'D', 'x': 4.0, 'y': 4.0},
    {'category': 'A', 'x': 1.5, 'y': 3.0},
    {'category': 'B', 'x': 2.5, 'y': 2.5},
    {'category': 'C', 'x': 3.5, 'y': 3.5},
    {'category': 'D', 'x': 4.5, 'y': 2.0},
  ];

  final gradients = _getGradientsForType(gradientType);

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'x', y: 'y', color: 'category')
        .geomPoint(
          size: pointSize,
          borderWidth: borderWidth,
        )
        .scaleXContinuous()
        .scaleYContinuous()
        .customPalette(categoryGradients: gradients)
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget _buildMixedGradientBarChart() {
  final data = [
    {'category': 'North', 'value': 250},
    {'category': 'South', 'value': 180},
    {'category': 'East', 'value': 220},
    {'category': 'West', 'value': 190},
  ];

  final mixedGradients = <String, Gradient>{
    'North': const RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [Color(0xFF64B5F6), Color(0xFF1565C0)],
    ),
    'South': const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFF176), Color(0xFFFF8F00)],
    ),
    'East': const SweepGradient(
      center: Alignment.center,
      colors: [Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFF2E7D32)],
    ),
    'West': const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
      stops: [0.0, 1.0],
    ),
  };

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'category', y: 'value', color: 'category')
        .geomBar(
          borderRadius: BorderRadius.circular(8),
          borderWidth: 2.0,
        )
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryGradients: mixedGradients)
        .build(),
  );
}

Widget _buildGroupedGradientBars() {
  final data = [
    {'quarter': 'Q1', 'value': 120, 'series': 'Product A'},
    {'quarter': 'Q1', 'value': 100, 'series': 'Product B'},
    {'quarter': 'Q2', 'value': 150, 'series': 'Product A'},
    {'quarter': 'Q2', 'value': 130, 'series': 'Product B'},
    {'quarter': 'Q3', 'value': 110, 'series': 'Product A'},
    {'quarter': 'Q3', 'value': 140, 'series': 'Product B'},
  ];

  final gradients = <String, Gradient>{
    'Product A': const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
    ),
    'Product B': const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF81C784), Color(0xFF388E3C)],
    ),
  };

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'quarter', y: 'value', color: 'series')
        .geomBar(style: BarStyle.grouped)
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryGradients: gradients)
        .legend(position: LegendPosition.topRight)
        .build(),
  );
}

Widget _buildStackedGradientBars() {
  final data = [
    {'quarter': 'Q1', 'value': 60, 'category': 'Revenue'},
    {'quarter': 'Q1', 'value': 40, 'category': 'Costs'},
    {'quarter': 'Q2', 'value': 80, 'category': 'Revenue'},
    {'quarter': 'Q2', 'value': 50, 'category': 'Costs'},
    {'quarter': 'Q3', 'value': 70, 'category': 'Revenue'},
    {'quarter': 'Q3', 'value': 45, 'category': 'Costs'},
  ];

  final gradients = <String, Gradient>{
    'Revenue': const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    ),
    'Costs': const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFFEF5350), Color(0xFFC62828)],
    ),
  };

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'quarter', y: 'value', color: 'category')
        .geomBar(style: BarStyle.stacked)
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryGradients: gradients)
        .legend(position: LegendPosition.topRight)
        .build(),
  );
}

Map<String, Gradient> _getGradientsForType(String type) {
  switch (type) {
    case 'linear_vertical':
      return {
        'A': const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
        ),
        'B': const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF81C784), Color(0xFF388E3C)],
        ),
        'C': const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
        ),
        'D': const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
        ),
      };
    case 'linear_vertical_reverse':
      return {
        'A': const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
        ),
        'B': const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81C784), Color(0xFF388E3C)],
        ),
        'C': const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
        ),
        'D': const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
        ),
      };
    case 'linear_diagonal':
      return {
        'A': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
        ),
        'B': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF81C784), Color(0xFF388E3C)],
        ),
        'C': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
        ),
        'D': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
        ),
      };
    case 'radial_center':
      return {
        'A': const RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
        ),
        'B': const RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [Color(0xFF81C784), Color(0xFF388E3C)],
        ),
        'C': const RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
        ),
        'D': const RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
        ),
      };
    case 'sweep':
      return {
        'A': const SweepGradient(
          center: Alignment.center,
          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2), Color(0xFF4FC3F7)],
        ),
        'B': const SweepGradient(
          center: Alignment.center,
          colors: [Color(0xFF81C784), Color(0xFF388E3C), Color(0xFF81C784)],
        ),
        'C': const SweepGradient(
          center: Alignment.center,
          colors: [Color(0xFFFFB74D), Color(0xFFF57C00), Color(0xFFFFB74D)],
        ),
        'D': const SweepGradient(
          center: Alignment.center,
          colors: [Color(0xFFE57373), Color(0xFFD32F2F), Color(0xFFE57373)],
        ),
      };
    default:
      throw ArgumentError('Unknown gradient type: $type');
  }
}
