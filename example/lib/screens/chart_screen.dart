import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../graphs/advanced_gradient_example.dart';
import '../graphs/area_chart.dart';
import '../graphs/bar_chart.dart';
import '../graphs/bubble_chart.dart';
import '../graphs/combo_bar_line_chart.dart';
import '../graphs/debug_gradient.dart';
import '../graphs/dual_axis_chart.dart';
import '../graphs/export_demo.dart';
import '../graphs/grouped_bar.dart';
import '../graphs/heatmap_chart.dart';
import '../graphs/horizontal_bar_chart.dart';
import '../graphs/interactive_scatter.dart';
import '../graphs/legend_example.dart';
import '../graphs/line_chart.dart';
import '../graphs/multi_series_line_chart.dart';
import '../graphs/pan_example.dart';
import '../graphs/pie_chart.dart';
import '../graphs/progress_bars.dart';
import '../graphs/scatter_plot.dart';
import '../graphs/stacked_bar_chart.dart';
import '../graphs/time_based_line_chart.dart';
import '../graphs/zoom_example.dart';
import '../router/app_router.dart';
import '../utils/chart_feature_list.dart';

class ChartScreen extends StatefulWidget {
  final int chartIndex;

  const ChartScreen({super.key, required this.chartIndex});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with SingleTickerProviderStateMixin {
  bool _hasSetDefaults = false;
  int _currentThemeIndex = 0;
  final List<({String name, ChartTheme theme})> _themeData = [
    (name: 'Light (default)', theme: ChartTheme.defaultTheme()),
    (name: 'Dark', theme: ChartTheme.darkTheme()),
    (
      name: 'High Contrast',
      theme: const ChartTheme(
        backgroundColor: Colors.white,
        plotBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        borderColor: Colors.black,
        gridColor: Color(0xFFBDBDBD),
        axisColor: Colors.black,
        gridWidth: 0.8,
        axisWidth: 1.5,
        pointSizeDefault: 5.0,
        pointSizeMin: 3.0,
        pointSizeMax: 14.0,
        colorPalette: [
          Color(0xFF0000CC),
          Color(0xFFCC0000),
          Color(0xFF007700),
          Color(0xFFCC6600),
          Color(0xFF6600CC),
          Color(0xFF006666),
        ],
        padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 8),
        axisTextStyle: TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        axisLabelStyle: TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    (name: 'Solarized Light', theme: ChartTheme.solarizedLightTheme()),
    (name: 'Solarized Dark', theme: ChartTheme.solarizedDarkTheme()),
  ];

  int _currentPaletteIndex = 0;
  final List<({String name, List<Color> colors})> _paletteData = [
    (name: 'Default', colors: ChartTheme.defaultTheme().colorPalette),
    (
      name: 'Warm',
      colors: const [
        Color(0xFFDC2626),
        Color(0xFFEA580C),
        Color(0xFFD97706),
        Color(0xFFCA8A04),
        Color(0xFF92400E),
      ],
    ),
    (
      name: 'Cool',
      colors: const [
        Color(0xff2196f3),
        Color(0xff00bcd4),
        Color(0xff009688),
        Color(0xff4caf50),
      ],
    ),
    (
      name: 'Pastel',
      colors: const [
        Color(0xffffb74d),
        Color(0xffff8a65),
        Color(0xffdce775),
        Color(0xffaed581),
      ],
    ),
    (
      name: 'Soft',
      colors: const [
        Color(0xFF93C5FD),
        Color(0xFFF9A8D4),
        Color(0xFFA5B4FC),
        Color(0xFF86EFAC),
        Color(0xFFFDE68A),
      ],
    ),
    (
      name: 'Ocean',
      colors: const [
        Color(0xFF0077B6),
        Color(0xFF00B4D8),
        Color(0xFF90E0EF),
        Color(0xFF023E8A),
        Color(0xFF48CAE4),
      ],
    ),
    (
      name: 'Earth',
      colors: const [
        Color(0xFF606C38),
        Color(0xFFDDA15E),
        Color(0xFFBC6C25),
        Color(0xFF283618),
        Color(0xFFFEFAE0),
      ],
    ),
    (
      name: 'Neon',
      colors: const [
        Color(0xFFFF006E),
        Color(0xFF8338EC),
        Color(0xFF3A86FF),
        Color(0xFFFB5607),
        Color(0xFFFFBE0B),
      ],
    ),
    (
      name: 'Monochrome',
      colors: const [
        Color(0xFF212529),
        Color(0xFF495057),
        Color(0xFF6C757D),
        Color(0xFFADB5BD),
        Color(0xFFDEE2E6),
      ],
    ),
    (
      name: 'Tropical',
      colors: const [
        Color(0xFFFF6B6B),
        Color(0xFF4ECDC4),
        Color(0xFFFFE66D),
        Color(0xFF45B7D1),
        Color(0xFFF7DC6F),
      ],
    ),
    (
      name: 'Jewel',
      colors: const [
        Color(0xFF1A5276),
        Color(0xFF922B21),
        Color(0xFF196F3D),
        Color(0xFF6C3483),
        Color(0xFFB9770E),
      ],
    ),
    (
      name: 'Forest',
      colors: const [
        Color(0xFF2D6A4F),
        Color(0xFF40916C),
        Color(0xFF52B788),
        Color(0xFF74C69D),
        Color(0xFF1B4332),
      ],
    ),
    (
      name: 'Slate',
      colors: const [
        Color(0xFF334155),
        Color(0xFF475569),
        Color(0xFF64748B),
        Color(0xFF94A3B8),
        Color(0xFFCBD5E1),
      ],
    ),
  ];

  double _sliderValue = 0.5;
  bool _showControls = false;

  late final List<Map<String, dynamic>> _scatterPlotData;
  late final List<Map<String, dynamic>> _lineChartData;
  late final List<Map<String, dynamic>> _barChartData;
  late final List<Map<String, dynamic>> _groupedBarData;
  late final List<Map<String, dynamic>> _horizontalBarData;
  late final List<Map<String, dynamic>> _stackedBarData;
  late final List<Map<String, dynamic>> _dualAxisData;

  @override
  void initState() {
    super.initState();

    _generateSampleData();
    _generateStackedBarData();
    _generateDualAxisData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasSetDefaults) {
      _hasSetDefaults = true;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      if (isDark) {
        _currentThemeIndex = 1; // Dark theme
        _currentPaletteIndex = 5; // Ocean palette
      } else {
        _currentThemeIndex = 0; // Default (light) theme
        _currentPaletteIndex = 1; // Warm palette
      }
    }
  }

  void _generateSampleData() {
    // More realistic scatter plot data - Sales Performance
    _scatterPlotData = List.generate(60, (i) {
      final x = i.toDouble();
      final baseY = 20 + x * 0.8 + math.sin(x * 0.1) * 15;
      final noise = (math.Random().nextDouble() - 0.5) * 12;
      final y = math.max(5, baseY + noise);
      final categories = ['Enterprise', 'SMB', 'Startup'];
      final category = categories[i % 3];
      final size = 1.0 + (y / 10).clamp(0, 8);
      return {'x': x, 'y': y, 'category': category, 'size': size};
    });

    // Realistic line chart - User Growth
    _lineChartData = List.generate(24, (i) {
      final x = i.toDouble();
      final baseGrowth = 50 + i * 3.2;
      final seasonal = math.sin(x * 0.5) * 8;
      final y = baseGrowth + seasonal + (math.Random().nextDouble() - 0.5) * 6;
      return {'x': x, 'y': y, 'category': 'Monthly Active Users (k)'};
    });

    // Realistic bar chart - Quarterly Revenue
    final quarters = [
      'Q1 2023',
      'Q2 2023',
      'Q3 2023',
      'Q4 2023',
      'Q1 2024',
      'Q2 2024',
      'Q3 2024',
      'Q4 2024',
      'Q1 2025',
      'Q2 2025',
      'Q3 2025',
      'Q4 2025',
    ];
    _barChartData =
        quarters.asMap().entries.map((entry) {
          final revenue =
              120 + entry.key * 25 + math.Random().nextDouble() * 20;
          return {'quarter': entry.value, 'revenue': revenue, 'bar': 'Bar 1'};
        }).toList();
    _barChartData.addAll(
      quarters
          .map(
            (e) => {
              'quarter': e,
              'revenue': 120 + math.Random().nextDouble() * 20,
              'bar': 'Bar 2',
            },
          )
          .toList(),
    );

    // Realistic grouped bar data - Product Performance
    final products = ['Mobile App', 'Web Platform', 'API Services'];
    final groupedQuarters = ['Q1', 'Q2', 'Q3', 'Q4'];
    _groupedBarData = <Map<String, dynamic>>[];
    for (final quarter in groupedQuarters) {
      for (int i = 0; i < products.length; i++) {
        final baseRevenue = 30 + groupedQuarters.indexOf(quarter) * 8;
        final productMultiplier = [1.2, 0.9, 0.7][i];
        final revenue =
            baseRevenue * productMultiplier + math.Random().nextDouble() * 15;
        _groupedBarData.add({
          'quarter': quarter,
          'product': products[i],
          'revenue': revenue,
        });
      }
    }

    // Realistic horizontal bar data - Team Performance
    final departments = [
      'Engineering',
      'Product',
      'Sales',
      'Marketing',
      'Customer Success',
    ];
    _horizontalBarData =
        departments.asMap().entries.map((entry) {
          final multipliers = [1.0, 0.8, 0.9, 0.7, 0.6];
          final headcount =
              25 + (entry.key * 8) + math.Random().nextDouble() * 12;
          return {
            'department': entry.value,
            'headcount': headcount * multipliers[entry.key],
          };
        }).toList();
  }

  void _generateDualAxisData() {
    // Realistic dual-axis data - Revenue vs Conversion Rate
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    _dualAxisData = <Map<String, dynamic>>[];

    for (int i = 0; i < months.length; i++) {
      final month = months[i];

      // Revenue data (left Y-axis) - ranges from ~100k to ~200k
      final baseRevenue = 120 + i * 5; // Growing trend
      final seasonalRevenue = math.sin(i * 0.5) * 20; // Seasonal variation
      final revenue =
          baseRevenue +
          seasonalRevenue +
          (math.Random().nextDouble() - 0.5) * 15;

      // Conversion rate data (right Y-axis) - ranges from ~15% to ~25%
      final baseConversion = 18 + i * 0.3; // Slow improvement over time
      final seasonalConversion =
          math.cos(i * 0.4) * 3; // Different seasonal pattern
      final conversionRate =
          baseConversion +
          seasonalConversion +
          (math.Random().nextDouble() - 0.5) * 2;

      final revenuePoint = {
        'month': month,
        'revenue': math.max(80.0, revenue), // Ensure positive revenue
        'product': 'Product Sales',
      };

      final conversionPoint = {
        'month': month,
        'conversion_rate': math.max(
          10.0,
          math.min(30.0, conversionRate),
        ), // Keep conversion rate reasonable
        'product': 'Conversion Rate',
      };

      _dualAxisData.add(revenuePoint);
      _dualAxisData.add(conversionPoint);
    }
  }

  void _generateStackedBarData() {
    // Realistic stacked bar data - Revenue by Category per Quarter
    final categories = ['Product Sales', 'Services', 'Subscriptions'];
    final quarters = ['Q1 2024', 'Q2 2024', 'Q3 2024', 'Q4 2024'];
    _stackedBarData = <Map<String, dynamic>>[];

    for (final quarter in quarters) {
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        // Different base values for each category to make stacking interesting
        final baseValues = [
          40.0,
          25.0,
          30.0,
        ]; // Product Sales highest, Services middle, Subscriptions lowest
        final quarterMultiplier =
            quarters.indexOf(quarter) * 0.2 + 1.0; // Growth over quarters
        final categoryMultiplier =
            [1.0, 0.8, 1.2][i]; // Different growth rates per category

        final revenue =
            baseValues[i] * quarterMultiplier * categoryMultiplier +
            (math.Random().nextDouble() - 0.5) * 10; // Add some variance

        _stackedBarData.add({
          'quarter': quarter,
          'category': category,
          'revenue': math.max(5, revenue), // Ensure positive values
        });
      }
    }
  }

  ChartTheme get currentTheme {
    final baseTheme = _themeData[_currentThemeIndex].theme;
    return baseTheme.copyWith(
      colorPalette: _paletteData[_currentPaletteIndex].colors,
    );
  }

  String _getDisplayedValue() {
    final index = widget.chartIndex;
    switch (index) {
      case 0:
      case 1: // Both scatter plots (regular and interactive)
        final value = 2.0 + _sliderValue * 20.0;
        return 'Point Size: ${value.toStringAsFixed(1)}px';
      case 2:
        final value = 1.0 + _sliderValue * 9.0;
        return 'Line Width: ${value.toStringAsFixed(1)}px';
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 22:
        final value = _sliderValue.clamp(0.1, 1.0);
        return 'Bar Width: ${(value * 100).toStringAsFixed(0)}%';
      case 9: // Pie chart
        final value = 100.0 + _sliderValue * 50.0;
        return 'Pie Radius: ${value.toStringAsFixed(0)}px';
      case 14: // Progress bars
        final value = 15.0 + _sliderValue * 25.0;
        return 'Thickness: ${value.toStringAsFixed(1)}px';
      default:
        return _sliderValue.toStringAsFixed(2);
    }
  }

  List<String> _getChartTitles() {
    return [
      'Sales Performance Analysis',
      'Interactive Sales Dashboard',
      'Interactive Panning Demo',
      'User Growth Trends',
      'Website Traffic Analytics',
      'Market Performance Analysis',
      'Quarterly Revenue',
      'Product Performance by Quarter',
      'Team Size by Department',
      'Revenue Breakdown by Category',
      'Platform Revenue Distribution',
      'Revenue vs Conversion Performance',
      'Weekly Activity Heatmap',
      'Developer Contributions',
      'Progress Bars Showcase',
      'Multi Series Line Chart Demo',
      'Chart Export Demo',
      'Gradient Bar Charts',
      'Advanced Gradient Effects',
      'Legend Examples',
      'Time-Based Line Chart',
      'Zoom & Navigation Demo',
      'Combo Chart (Bar + Line)',
    ];
  }

  List<String> _getChartDescriptions() {
    return [
      'Enterprise clients show higher deal values with consistent growth patterns',
      'Hover and tap for detailed insights • Rich tooltips and custom interactions',
      'Real-time pan detection with visible range callbacks • Perfect for large datasets',
      'Steady monthly growth with seasonal variations in user acquisition',
      'Smooth area fills with progressive animation • Multi-series support with transparency',
      'Three-dimensional visualization showing revenue, customer count, and market share',
      'Strong Q4 performance driven by holiday sales and new partnerships',
      'Mobile app leading growth, API services showing steady adoption',
      'Engineering team expansion supporting our product development goals',
      'Product sales continue to drive growth, with subscriptions showing strong momentum',
      'Mobile dominates with 45% share, desktop and tablet showing steady growth',
      'Revenue growth correlates with improved conversion optimization',
      'Visualize user engagement patterns throughout the week with color-coded intensity',
      'GitHub-style contribution graph showing code activity over the last 12 weeks',
      'Horizontal, vertical, and circular progress indicators • Task completion and KPI tracking',
      'Platform analytics with brand-specific colors • iOS Blue, Android Green, Web Orange',
      'Export your charts as scalable SVG vector graphics for reports and presentations',
      'Beautiful gradient fills for enhanced visual appeal • Linear gradients from light to dark',
      'Multiple gradient types: Linear, Radial, Sweep • Works with bars and points',
      'Comprehensive legend showcase • 9 positioning options including new floating legends',
      'Line chart with time-based data on x-axis',
      'Pinch, scroll, and button-based zoom controls with live callbacks',
      'Bar correctly colored by categorical variable with a single continuous overlaid line.',
    ];
  }

  Widget _buildStatsCard(
    String title,
    String value,
    String change,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SelectableText(
            change,
            style: TextStyle(
              fontSize: 9,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.green[400]
                      : Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child:
          _showControls
              ? Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        SelectableText(
                          'Chart Controls',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed:
                              () => setState(() => _showControls = false),
                          icon: const Icon(CupertinoIcons.chevron_up),
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                _getDisplayedValue(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SliderTheme(
                                data: const SliderThemeData(
                                  trackHeight: 3,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                ),
                                child: Slider(
                                  value: _sliderValue,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 20,
                                  onChanged:
                                      (value) =>
                                          setState(() => _sliderValue = value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _getChartWidget() {
    switch (widget.chartIndex) {
      case 0:
        return buildScatterPlotTab(
          currentTheme,
          _scatterPlotData,
          _sliderValue,
        );
      case 1:
        return buildInteractiveScatterTab(
          currentTheme,
          _scatterPlotData,
          _sliderValue,
        );
      case 2:
        return buildPanExampleTab(currentTheme, _sliderValue);
      case 3:
        return buildLineChartTab(currentTheme, _lineChartData, _sliderValue);
      case 4:
        return AreaChartExample(
          theme: currentTheme,
          colorPalette: _paletteData[_currentPaletteIndex].colors,
        );
      case 5:
        return buildBubbleChartTab(context, currentTheme, _sliderValue);
      case 6:
        return buildBarChartTab(currentTheme, _barChartData, _sliderValue);
      case 7:
        return buildGroupedBarTab(currentTheme, _groupedBarData, _sliderValue);
      case 8:
        return buildHorizontalBarTab(
          currentTheme,
          _horizontalBarData,
          _sliderValue,
        );
      case 9:
        return buildStackedBarTab(currentTheme, _stackedBarData, _sliderValue);
      case 10:
        return buildPieChartTab(
          context,
          currentTheme,
          _scatterPlotData,
          _sliderValue,
        );
      case 11:
        return buildDualAxisTab(currentTheme, _dualAxisData, _sliderValue);
      case 12:
        return buildHeatMapTab(
          currentTheme,
          _paletteData[_currentPaletteIndex].colors,
        );
      case 13:
        return buildContributionHeatMapTab(currentTheme);
      case 14:
        return buildProgressBarsTab(currentTheme, _sliderValue);
      case 15:
        return buildMultiSeriesLineChartTab(currentTheme, _sliderValue);
      case 16:
        return ExportDemo(
          theme: currentTheme,
          colorPalette: _paletteData[_currentPaletteIndex].colors,
        );
      case 17:
        return const DebugGradientExample();
      case 18:
        return const AdvancedGradientExample();
      case 19:
        return buildLegendExampleTab(
          context,
          currentTheme,
          _groupedBarData,
          _sliderValue,
        );
      case 20:
        return buildTimeBasedLineChartTab(
          currentTheme,
          _lineChartData,
          _sliderValue,
        );
      case 21:
        return buildZoomExampleTab(currentTheme, _sliderValue);
      case 22:
        return buildComboBarLineTab(currentTheme, _sliderValue);
      default:
        return Container();
    }
  }

  List<Widget> _getStatsCards() {
    switch (widget.chartIndex) {
      case 0:
        return [
          _buildStatsCard('Avg Deal Size', '\$47.2k', '+12.3%', Colors.blue),
          _buildStatsCard('Conversion Rate', '23.4%', '+2.1%', Colors.green),
          _buildStatsCard('Total Deals', '156', '+8.9%', Colors.orange),
        ];
      case 1:
        return [
          _buildStatsCard('Hover Events', '234', '+45%', Colors.purple),
          _buildStatsCard('Click Events', '89', '+12%', Colors.indigo),
          _buildStatsCard('Tooltip Views', '1.2k', '+67%', Colors.teal),
        ];
      case 2:
        return [
          _buildStatsCard('Pan Events', '0', 'Real-time', Colors.blue),
          _buildStatsCard('Data Points', '1.0k', '+0%', Colors.green),
          _buildStatsCard('Range Updates', 'Live', 'Active', Colors.orange),
        ];
      case 3:
        return [
          _buildStatsCard('Q4 Revenue', '\$1.2M', '+24.7%', Colors.green),
          _buildStatsCard('YoY Growth', '31.5%', '+5.2%', Colors.blue),
          _buildStatsCard('Profit Margin', '18.3%', '+2.1%', Colors.orange),
        ];
      case 4:
        return [
          _buildStatsCard('Total Traffic', '68.2k', '+15.3%', Colors.blue),
          _buildStatsCard('Mobile Share', '62%', '+4.1%', Colors.green),
          _buildStatsCard('Avg Session', '4:32', '+12s', Colors.orange),
        ];
      case 5:
        return [
          _buildStatsCard('Market Leaders', '4', 'Enterprise', Colors.blue),
          _buildStatsCard('Growth Rate', '23.5%', '+5.2%', Colors.green),
          _buildStatsCard('Market Cap', '\$2.1B', '+12%', Colors.purple),
        ];
      case 6:
        return [
          _buildStatsCard('Mobile Revenue', '\$450k', '+18.2%', Colors.blue),
          _buildStatsCard('Web Platform', '\$320k', '+12.4%', Colors.green),
          _buildStatsCard('API Services', '\$180k', '+8.7%', Colors.orange),
        ];
      case 7:
        return [
          _buildStatsCard('Total Team', '127', '+12', Colors.blue),
          _buildStatsCard('Eng Growth', '23.5%', '+3.2%', Colors.green),
          _buildStatsCard('Avg Tenure', '2.8y', '+0.3y', Colors.purple),
        ];
      case 8:
        return [
          _buildStatsCard('Total Revenue', '\$385k', '+18.2%', Colors.green),
          _buildStatsCard('Product Mix', '52%', '+3.1%', Colors.blue),
          _buildStatsCard('Growth Rate', '23.4%', '+5.7%', Colors.orange),
        ];
      case 9:
        return [
          _buildStatsCard('Avg Revenue', '\$156k', '+12.8%', Colors.blue),
          _buildStatsCard('Avg Conversion', '19.2%', '+2.4%', Colors.green),
          _buildStatsCard('Correlation', '0.73', '+0.12', Colors.purple),
        ];
      case 10:
        return [
          _buildStatsCard('Mobile Share', '45.2%', '+2.3%', Colors.blue),
          _buildStatsCard('Desktop Share', '32.8%', '+1.1%', Colors.green),
          _buildStatsCard('Tablet Share', '22.0%', '+0.8%', Colors.orange),
        ];
      case 11:
        return [
          _buildStatsCard('Avg Revenue', '\$156k', '+12.8%', Colors.blue),
          _buildStatsCard('Avg Conversion', '19.2%', '+2.4%', Colors.green),
          _buildStatsCard('Correlation', '0.73', '+0.12', Colors.purple),
        ];
      case 12:
        return [
          _buildStatsCard('Peak Hours', '8am-6pm', 'Weekdays', Colors.orange),
          _buildStatsCard('Activity Rate', '68%', '+5.2%', Colors.red),
          _buildStatsCard('Data Points', '84', '7x12 Grid', Colors.blue),
        ];
      case 13:
        return [
          _buildStatsCard('Total Commits', '523', '+89', Colors.green),
          _buildStatsCard('Streak Days', '47', 'Current', Colors.blue),
          _buildStatsCard('Active Days', '73%', '+8%', Colors.purple),
        ];
      case 14:
        return [
          _buildStatsCard(
            'Orientations',
            '3',
            'Horizontal, Vertical, Circular',
            Colors.blue,
          ),
          _buildStatsCard(
            'Styles',
            '4',
            'Filled, Striped, Gradient, Custom',
            Colors.green,
          ),
          _buildStatsCard(
            'Animations',
            'Smooth',
            'Customizable Duration',
            Colors.purple,
          ),
        ];
      case 15:
        return [
          _buildStatsCard(
            'iOS Growth',
            '1,890',
            '+19.2%',
            const Color(0xFF007ACC),
          ),
          _buildStatsCard(
            'Android Users',
            '1,580',
            '+15.8%',
            const Color(0xFF3DDC84),
          ),
          _buildStatsCard(
            'Web Platform',
            '1,280',
            '+25.6%',
            const Color(0xFFFF6B35),
          ),
        ];
      case 16:
        return [
          _buildStatsCard(
            'Export Format',
            'SVG',
            'Vector Graphics',
            Colors.blue,
          ),
          _buildStatsCard('Scalability', '∞', 'Infinite Zoom', Colors.green),
          _buildStatsCard('File Size', 'Small', 'Compact', Colors.purple),
        ];
      case 17:
        return [
          _buildStatsCard('Gradient Types', '4', 'Linear', Colors.blue),
          _buildStatsCard('Visual Appeal', '100%', 'Enhanced', Colors.green),
          _buildStatsCard('Animation', 'Smooth', 'Back-ease', Colors.purple),
        ];
      case 18:
        return [
          _buildStatsCard('Gradient Types', 'Mixed', 'All Types', Colors.blue),
          _buildStatsCard('Chart Types', '2', 'Bars + Points', Colors.green),
          _buildStatsCard('Creativity', '∞', 'Unlimited', Colors.orange),
        ];
      case 19:
        return [
          _buildStatsCard('Positions', '9', 'Including Floating', Colors.blue),
          _buildStatsCard('Auto-Orient', 'Yes', 'Smart Layout', Colors.green),
          _buildStatsCard('Themes', 'All', 'Dark Mode Ready', Colors.purple),
        ];
      case 20:
        return [
          _buildStatsCard('Time Range', '12 mo', 'Daily cadence', Colors.blue),
          _buildStatsCard('Seasonality', 'High', 'Wave patterns', Colors.green),
          _buildStatsCard('Noise Level', 'Low', 'Smoothed', Colors.orange),
        ];
      case 21:
        return [
          _buildStatsCard('Zoom Modes', '3', 'X, Y or both', Colors.blue),
          _buildStatsCard(
            'Scroll Sens.',
            '0.0005-0.0035',
            'Wheel control',
            Colors.orange,
          ),
          _buildStatsCard(
            'Floating UI',
            'Buttons',
            '+/- helpers',
            Colors.purple,
          ),
        ];
      case 22:
        return [
          _buildStatsCard(
            'Color Bleed',
            'None',
            'No line slicing',
            Colors.green,
          ),
          _buildStatsCard('Bars', 'Categorical', 'Dodge spacing', Colors.blue),
          _buildStatsCard('Line', 'Solid', 'Continuous trend', Colors.purple),
        ];
      default:
        return [];
    }
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 32,
                  width: 160,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chart Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...AppRouter.routes.map((route) {
            final isSelected = GoRouterState.of(context).fullPath == route.path;
            return Container(
              decoration:
                  isSelected
                      ? BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 4,
                          ),
                        ),
                      )
                      : null,
              child: ListTile(
                leading: Icon(
                  route.icon,
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.title,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[400],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (route.isNew) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (route.isExperimental) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Exp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  route.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.grey[300] : Colors.grey[500],
                  ),
                ),
                onTap: () {
                  if (!isSelected) {
                    // Navigate directly - go_router handles drawer closing
                    context.go(route.path);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartTitles = _getChartTitles();
    final chartDescriptions = _getChartDescriptions();

    // Determine chart height based on chart type
    double chartHeight = 380; // Default height
    final title = chartTitles[widget.chartIndex];
    if (title.contains('Market Performance Analysis') ||
        title.contains('Bubble')) {
      chartHeight = 600; // Larger height for bubble charts to prevent cutoff
    } else if (title.contains('Heatmap') || title.contains('Contributions')) {
      chartHeight = 450; // Slightly larger for heatmaps
    } else if (widget.chartIndex == 21 || title.contains('Zoom & Navigation')) {
      chartHeight = 640; // Extra room for zoom demo controls + chart
    } else if (widget.chartIndex == 22) {
      chartHeight = 420; // Room for Combo Chart SizedBox
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            SvgPicture.asset('assets/images/logo.svg', height: 32, width: 160),
          ],
        ),
        actions: [
          // Theme Dropdown
          PopupMenuButton<int>(
            icon: const Icon(CupertinoIcons.sun_max),
            tooltip: 'Theme',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (int index) {
              setState(() {
                _currentThemeIndex = index;
              });
            },
            itemBuilder:
                (context) =>
                    _themeData
                        .asMap()
                        .entries
                        .map(
                          (entry) => PopupMenuItem<int>(
                            value: entry.key,
                            child: Row(
                              children: [
                                if (entry.key == _currentThemeIndex)
                                  const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 16,
                                  )
                                else
                                  const SizedBox(width: 16),
                                const SizedBox(width: 8),
                                Text(entry.value.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
          ),
          // Palette Dropdown
          PopupMenuButton<int>(
            icon: const Icon(CupertinoIcons.paintbrush),
            tooltip: 'Color Palette',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (int index) {
              setState(() {
                _currentPaletteIndex = index;
              });
            },
            itemBuilder:
                (context) =>
                    _paletteData
                        .asMap()
                        .entries
                        .map(
                          (entry) => PopupMenuItem<int>(
                            value: entry.key,
                            child: Row(
                              children: [
                                if (entry.key == _currentPaletteIndex)
                                  const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 16,
                                  )
                                else
                                  const SizedBox(width: 16),
                                const SizedBox(width: 8),
                                Text(entry.value.name),
                                const SizedBox(width: 12),
                                Row(
                                  children:
                                      _paletteData[entry.key].colors
                                          .take(3)
                                          .map(
                                            (c) => Container(
                                              width: 12,
                                              height: 12,
                                              margin: const EdgeInsets.only(
                                                right: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: c,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.grey[600]!
                                                          : Colors.grey[300]!,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
          ),
          IconButton(
            onPressed: () => setState(() => _showControls = !_showControls),
            icon: Icon(
              _showControls
                  ? CupertinoIcons.slider_horizontal_below_rectangle
                  : CupertinoIcons.slider_horizontal_3,
            ),
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              chartTitles[widget.chartIndex],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              chartDescriptions[widget.chartIndex],
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (AppRouter.routes[widget.chartIndex].docsUrl != null)
                        const SizedBox(width: 12),
                      if (AppRouter.routes[widget.chartIndex].docsUrl != null)
                        _buildViewDocsButton(
                          AppRouter.routes[widget.chartIndex].docsUrl!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children:
                        _getStatsCards()
                            .map(
                              (stat) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: stat,
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 16),

                  // Chart Container
                  Container(
                    height: chartHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: currentTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _getChartWidget(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Features section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withAlpha(26),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.sparkles,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            SelectableText(
                              'Chart Features',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = getChartFeatures(widget.chartIndex);
    return Column(
      children:
          features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SelectableText(
                          feature,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildViewDocsButton(String docsUrl) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: () => _launchUrl(docsUrl),
      icon: const Icon(CupertinoIcons.book, size: 18),
      label: const Text(
        'View Docs',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white70 : theme.primaryColor,
        backgroundColor:
            isDark
                ? Colors.white.withAlpha(20)
                : theme.primaryColor.withAlpha(26),
        side: BorderSide(
          color: isDark ? Colors.white24 : theme.primaryColor,
          width: isDark ? 1.0 : 2.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open documentation: $urlString'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
