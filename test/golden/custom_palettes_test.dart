import 'package:alchemist/alchemist.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/chart_builders.dart';

void main() {
  group('Custom Palette Tests - Brand Colors', () {
    goldenTest(
      'Brand-specific color mapping',
      fileName: 'custom_palette_brand',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'platform_colors',
            child: _buildBrandPaletteChart(paletteType: 'platform'),
          ),
          GoldenTestScenario(
            name: 'product_colors',
            child: _buildBrandPaletteChart(paletteType: 'product'),
          ),
        ],
      ),
    );
  });

  group('Custom Palette Tests - Semantic Colors', () {
    goldenTest(
      'Status-based color mapping',
      fileName: 'custom_palette_status',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'success_warning_error',
            child: _buildSemanticPaletteChart(paletteType: 'status'),
          ),
          GoldenTestScenario(
            name: 'priority_levels',
            child: _buildSemanticPaletteChart(paletteType: 'priority'),
          ),
        ],
      ),
    );
  });

  group('Custom Palette Tests - with Legends', () {
    goldenTest(
      'Custom palette with auto-generated legends',
      fileName: 'custom_palette_with_legend',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'top_right_legend',
            child: _buildCustomPaletteWithLegend(
              position: LegendPosition.topRight,
            ),
          ),
          GoldenTestScenario(
            name: 'bottom_legend',
            child: _buildCustomPaletteWithLegend(
              position: LegendPosition.bottom,
              orientation: LegendOrientation.horizontal,
            ),
          ),
        ],
      ),
    );
  });

  group('Custom Palette Tests - Multi-Series Charts', () {
    goldenTest(
      'Custom colors on multi-series line charts',
      fileName: 'custom_palette_multi_series_lines',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom_line_colors',
            child: _buildMultiSeriesCustomPalette(chartType: 'line'),
          ),
        ],
      ),
    );

    goldenTest(
      'Custom colors on grouped bar charts',
      fileName: 'custom_palette_grouped_bars',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom_bar_colors',
            child: _buildMultiSeriesCustomPalette(chartType: 'bar'),
          ),
        ],
      ),
    );

    goldenTest(
      'Custom colors on stacked bar charts',
      fileName: 'custom_palette_stacked_bars',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'custom_stacked_colors',
            child: _buildMultiSeriesCustomPalette(chartType: 'stacked'),
          ),
        ],
      ),
    );
  });

  group('Custom Palette Tests - Scatter Plots', () {
    goldenTest(
      'Custom colors on scatter plots',
      fileName: 'custom_palette_scatter',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'category_colors',
            child: _buildCustomScatterPalette(),
          ),
        ],
      ),
    );
  });

  group('Custom Palette Tests - with Themes', () {
    goldenTest(
      'Custom palettes with different themes',
      fileName: 'custom_palette_themes',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'dark_theme',
            child: _buildBrandPaletteChart(
              paletteType: 'platform',
              theme: ChartTheme.darkTheme(),
            ),
          ),
          GoldenTestScenario(
            name: 'solarized_light',
            child: _buildBrandPaletteChart(
              paletteType: 'product',
              theme: ChartTheme.solarizedLightTheme(),
            ),
          ),
        ],
      ),
    );
  });

  // Note: Custom palettes don't work with pie charts since pie charts use
  // .mappingPie() instead of .mapping(), and customPalette requires a color
  // mapping. Pie charts use theme color palettes instead.
}

// Helper functions

Widget _buildBrandPaletteChart({
  required String paletteType,
  ChartTheme? theme,
}) {
  final data = paletteType == 'platform'
      ? [
          {'platform': 'iOS', 'users': 4500},
          {'platform': 'Android', 'users': 6200},
          {'platform': 'Web', 'users': 3800},
        ]
      : [
          {'product': 'Premium', 'revenue': 15000},
          {'product': 'Standard', 'revenue': 8500},
          {'product': 'Basic', 'revenue': 5200},
        ];

  final palette = _getPalette(paletteType);

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(
          x: paletteType == 'platform' ? 'platform' : 'product',
          y: paletteType == 'platform' ? 'users' : 'revenue',
          color: paletteType == 'platform' ? 'platform' : 'product',
        )
        .geomBar()
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryColors: palette)
        .theme(theme ?? ChartTheme.defaultTheme())
        .build(),
  );
}

Widget _buildSemanticPaletteChart({
  required String paletteType,
}) {
  final data = paletteType == 'status'
      ? [
          {'status': 'Success', 'count': 850},
          {'status': 'Warning', 'count': 120},
          {'status': 'Error', 'count': 45},
        ]
      : [
          {'priority': 'Critical', 'tasks': 12},
          {'priority': 'High', 'tasks': 28},
          {'priority': 'Medium', 'tasks': 45},
          {'priority': 'Low', 'tasks': 67},
        ];

  final palette = _getPalette(paletteType);

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(
          x: paletteType == 'status' ? 'status' : 'priority',
          y: paletteType == 'status' ? 'count' : 'tasks',
          color: paletteType == 'status' ? 'status' : 'priority',
        )
        .geomBar()
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryColors: palette)
        .build(),
  );
}

Widget _buildCustomPaletteWithLegend({
  required LegendPosition position,
  LegendOrientation? orientation,
}) {
  final data = [
    {'quarter': 'Q1', 'revenue': 1200, 'product': 'Product A'},
    {'quarter': 'Q1', 'revenue': 1000, 'product': 'Product B'},
    {'quarter': 'Q2', 'revenue': 1500, 'product': 'Product A'},
    {'quarter': 'Q2', 'revenue': 1300, 'product': 'Product B'},
    {'quarter': 'Q3', 'revenue': 1100, 'product': 'Product A'},
    {'quarter': 'Q3', 'revenue': 1400, 'product': 'Product B'},
  ];

  final palette = {
    'Product A': const Color(0xFF2196F3), // Blue
    'Product B': const Color(0xFF4CAF50), // Green
  };

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'quarter', y: 'revenue', color: 'product')
        .geomBar(style: BarStyle.grouped)
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryColors: palette)
        .legend(
          position: position,
          orientation: orientation,
        )
        .build(),
  );
}

Widget _buildMultiSeriesCustomPalette({required String chartType}) {
  final data = [
    {'month': 'Jan', 'value': 45, 'series': 'Sales'},
    {'month': 'Jan', 'value': 35, 'series': 'Marketing'},
    {'month': 'Jan', 'value': 25, 'series': 'Operations'},
    {'month': 'Feb', 'value': 52, 'series': 'Sales'},
    {'month': 'Feb', 'value': 38, 'series': 'Marketing'},
    {'month': 'Feb', 'value': 28, 'series': 'Operations'},
    {'month': 'Mar', 'value': 48, 'series': 'Sales'},
    {'month': 'Mar', 'value': 42, 'series': 'Marketing'},
    {'month': 'Mar', 'value': 32, 'series': 'Operations'},
  ];

  final palette = {
    'Sales': const Color(0xFF00BCD4), // Cyan
    'Marketing': const Color(0xFFFF9800), // Orange
    'Operations': const Color(0xFF9C27B0), // Purple
  };

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'month', y: 'value', color: 'series')
        .conditional(
          chartType == 'line',
          (chart) => chart.geomLine(strokeWidth: 2.0).geomPoint(size: 5.0),
        )
        .conditional(
          chartType == 'bar',
          (chart) => chart.geomBar(style: BarStyle.grouped),
        )
        .conditional(
          chartType == 'stacked',
          (chart) => chart.geomBar(style: BarStyle.stacked),
        )
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .customPalette(categoryColors: palette)
        .legend(position: LegendPosition.topRight)
        .build(),
  );
}

Widget _buildCustomScatterPalette() {
  final data = [
    {'x': 1.0, 'y': 2.0, 'type': 'Type A'},
    {'x': 2.0, 'y': 3.5, 'type': 'Type B'},
    {'x': 3.0, 'y': 1.5, 'type': 'Type C'},
    {'x': 1.5, 'y': 3.0, 'type': 'Type A'},
    {'x': 2.5, 'y': 2.5, 'type': 'Type B'},
    {'x': 3.5, 'y': 3.5, 'type': 'Type C'},
    {'x': 4.0, 'y': 4.0, 'type': 'Type A'},
    {'x': 4.5, 'y': 2.0, 'type': 'Type B'},
  ];

  final palette = {
    'Type A': const Color(0xFFE91E63), // Pink
    'Type B': const Color(0xFF3F51B5), // Indigo
    'Type C': const Color(0xFFCDDC39), // Lime
  };

  return SizedBox(
    width: 400,
    height: 300,
    child: CristalyseChart()
        .data(data)
        .mapping(x: 'x', y: 'y', color: 'type')
        .geomPoint(size: 8.0)
        .scaleXContinuous()
        .scaleYContinuous()
        .customPalette(categoryColors: palette)
        .legend(position: LegendPosition.topRight)
        .build(),
  );
}

Map<String, Color> _getPalette(String type) {
  switch (type) {
    case 'platform':
      return {
        'iOS': const Color(0xFF007AFF), // Apple Blue
        'Android': const Color(0xFF3DDC84), // Android Green
        'Web': const Color(0xFFFF6B35), // Web Orange
      };
    case 'product':
      return {
        'Premium': const Color(0xFFFFD700), // Gold
        'Standard': const Color(0xFFC0C0C0), // Silver
        'Basic': const Color(0xFFCD7F32), // Bronze
      };
    case 'status':
      return {
        'Success': const Color(0xFF4CAF50), // Green
        'Warning': const Color(0xFFFF9800), // Orange
        'Error': const Color(0xFFF44336), // Red
      };
    case 'priority':
      return {
        'Critical': const Color(0xFFD32F2F), // Dark Red
        'High': const Color(0xFFFF5722), // Orange Red
        'Medium': const Color(0xFFFFC107), // Amber
        'Low': const Color(0xFF8BC34A), // Light Green
      };
    default:
      throw ArgumentError('Unknown palette type: $type');
  }
}
