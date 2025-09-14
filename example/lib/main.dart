import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:cristalyse_example/utils/chart_feature_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'graphs/advanced_gradient_example.dart';
import 'graphs/area_chart.dart';
import 'graphs/bar_chart.dart';
import 'graphs/bubble_chart.dart';
import 'graphs/debug_gradient.dart';
import 'graphs/dual_axis_chart.dart';
import 'graphs/export_demo.dart';
import 'graphs/grouped_bar.dart';
import 'graphs/heatmap_chart.dart';
import 'graphs/horizontal_bar_chart.dart';
import 'graphs/interactive_scatter.dart';
import 'graphs/line_chart.dart';
import 'graphs/multi_series_line_chart.dart';
import 'graphs/pan_example.dart';
import 'graphs/pie_chart.dart';
import 'graphs/progress_bars.dart';
import 'graphs/scatter_plot.dart';
import 'graphs/stacked_bar_chart.dart';

void main() {
  runApp(const CristalyseExampleApp());
}

class CristalyseExampleApp extends StatelessWidget {
  const CristalyseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cristalyse - Grammar of Graphics for Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
      ),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  int _currentThemeIndex = 0;
  final _themes = [
    ChartTheme.defaultTheme(),
    ChartTheme.darkTheme(),
    ChartTheme.solarizedLightTheme(),
    ChartTheme.solarizedDarkTheme(),
  ];

  final _themeNames = ['Default', 'Dark', 'Solarized Light', 'Solarized Dark'];

  int _currentPaletteIndex = 0;
  final _colorPalettes = [
    ChartTheme.defaultTheme().colorPalette,
    const [
      Color(0xfff44336),
      Color(0xffe91e63),
      Color(0xff9c27b0),
      Color(0xff673ab7)
    ],
    const [
      Color(0xff2196f3),
      Color(0xff00bcd4),
      Color(0xff009688),
      Color(0xff4caf50)
    ],
    const [
      Color(0xffffb74d),
      Color(0xffff8a65),
      Color(0xffdce775),
      Color(0xffaed581)
    ],
  ];

  final _paletteNames = ['Default', 'Warm', 'Cool', 'Pastel'];

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
    _tabController = TabController(length: 19, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _generateSampleData();
    _generateStackedBarData();
    _generateDualAxisData();
    _fabAnimationController.forward();
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
    final quarters = ['Q1 2024', 'Q2 2024', 'Q3 2024', 'Q4 2024'];
    _barChartData = quarters.asMap().entries.map((entry) {
      final revenue = 120 + entry.key * 25 + math.Random().nextDouble() * 20;
      return {'quarter': entry.value, 'revenue': revenue};
    }).toList();

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
      'Customer Success'
    ];
    _horizontalBarData = departments.asMap().entries.map((entry) {
      final multipliers = [1.0, 0.8, 0.9, 0.7, 0.6];
      final headcount = 25 + (entry.key * 8) + math.Random().nextDouble() * 12;
      return {
        'department': entry.value,
        'headcount': headcount * multipliers[entry.key]
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
      'Dec'
    ];
    _dualAxisData = <Map<String, dynamic>>[];

    for (int i = 0; i < months.length; i++) {
      final month = months[i];

      // Revenue data (left Y-axis) - ranges from ~100k to ~200k
      final baseRevenue = 120 + i * 5; // Growing trend
      final seasonalRevenue = math.sin(i * 0.5) * 20; // Seasonal variation
      final revenue = baseRevenue +
          seasonalRevenue +
          (math.Random().nextDouble() - 0.5) * 15;

      // Conversion rate data (right Y-axis) - ranges from ~15% to ~25%
      final baseConversion = 18 + i * 0.3; // Slow improvement over time
      final seasonalConversion =
          math.cos(i * 0.4) * 3; // Different seasonal pattern
      final conversionRate = baseConversion +
          seasonalConversion +
          (math.Random().nextDouble() - 0.5) * 2;

      final dataPoint = {
        'month': month,
        'revenue': math.max(80.0, revenue), // Ensure positive revenue
        'conversion_rate': math.max(10.0,
            math.min(30.0, conversionRate)), // Keep conversion rate reasonable
      };

      _dualAxisData.add(dataPoint);
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
          30.0
        ]; // Product Sales highest, Services middle, Subscriptions lowest
        final quarterMultiplier =
            quarters.indexOf(quarter) * 0.2 + 1.0; // Growth over quarters
        final categoryMultiplier =
            [1.0, 0.8, 1.2][i]; // Different growth rates per category

        final revenue = baseValues[i] * quarterMultiplier * categoryMultiplier +
            (math.Random().nextDouble() - 0.5) * 10; // Add some variance

        _stackedBarData.add({
          'quarter': quarter,
          'category': category,
          'revenue': math.max(5, revenue), // Ensure positive values
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  ChartTheme get currentTheme {
    final baseTheme = _themes[_currentThemeIndex];
    return baseTheme.copyWith(
      colorPalette: _colorPalettes[_currentPaletteIndex],
    );
  }

  String _getDisplayedValue() {
    final index = _tabController.index;
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
        final value = _sliderValue.clamp(0.1, 1.0);
        return 'Bar Width: ${(value * 100).toStringAsFixed(0)}%';
      case 9: // Pie chart
        final value = 100.0 + _sliderValue * 50.0;
        return 'Pie Radius: ${value.toStringAsFixed(0)}px';
      case 13: // Progress bars
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
      'Quarterly Revenue',
      'Product Performance by Quarter',
      'Team Size by Department',
      'Revenue Breakdown by Category',
      'Platform Revenue Distribution',
      'Revenue vs Conversion Performance',
      'Weekly Activity Heatmap',
      'Developer Contributions',
      'Progress Bars Showcase',
      'Gradient Bar Charts',
      'Advanced Gradient Effects',
    ];
  }

  List<String> _getChartDescriptions() {
    return [
      'Enterprise clients show higher deal values with consistent growth patterns',
      'Hover and tap for detailed insights • Rich tooltips and custom interactions',
      'Real-time pan detection with visible range callbacks • Perfect for large datasets',
      'Steady monthly growth with seasonal variations in user acquisition',
      'Smooth area fills with progressive animation • Multi-series support with transparency',
      'Strong Q4 performance driven by holiday sales and new partnerships',
      'Mobile app leading growth, API services showing steady adoption',
      'Engineering team expansion supporting our product development goals',
      'Product sales continue to drive growth, with subscriptions showing strong momentum',
      'Mobile dominates with 45% share, desktop and tablet showing steady growth',
      'Revenue growth correlates with improved conversion optimization',
      'Visualize user engagement patterns throughout the week with color-coded intensity',
      'GitHub-style contribution graph showing code activity over the last 12 weeks',
      'Horizontal, vertical, and circular progress indicators • Task completion and KPI tracking',
      'Beautiful gradient fills for enhanced visual appeal • Linear gradients from light to dark',
      'Multiple gradient types: Linear, Radial, Sweep • Works with bars and points',
    ];
  }

  Widget _buildStatsCard(
      String title, String value, String change, Color color) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 9,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showControls ? null : 0,
      child: _showControls
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
                      Icon(Icons.tune,
                          color: Theme.of(context).primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Chart Controls',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => _showControls = false),
                        icon: const Icon(Icons.keyboard_arrow_up),
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
                            Text(
                              _getDisplayedValue(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
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
                                onChanged: (value) =>
                                    setState(() => _sliderValue = value),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_themeNames[_currentThemeIndex]} • ${_paletteNames[_currentPaletteIndex]}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: _colorPalettes[_currentPaletteIndex]
                                .take(4)
                                .map((color) => Container(
                                      width: 16,
                                      height: 16,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartTitles = _getChartTitles();
    final chartDescriptions = _getChartDescriptions();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 32,
              width: 160,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Jump to Chart',
            onSelected: (index) {
              _tabController.animateTo(index);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.scatter_plot, size: 20),
                  title: Text('Scatter Plot'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.touch_app, size: 20),
                  title: Text('Interactive'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.pan_tool, size: 20),
                  title: Text('Panning'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: ListTile(
                  leading: Icon(Icons.show_chart, size: 20),
                  title: Text('Line Chart'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 4,
                child: ListTile(
                  leading: Icon(Icons.area_chart, size: 20),
                  title: Text('Area Chart'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 5,
                child: ListTile(
                  leading: Icon(Icons.bubble_chart, size: 20),
                  title: Text('Bubble Chart'),
                  subtitle: Text('New!',
                      style: TextStyle(color: Colors.green, fontSize: 10)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 6,
                child: ListTile(
                  leading: Icon(Icons.bar_chart, size: 20),
                  title: Text('Bar Chart'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 7,
                child: ListTile(
                  leading: Icon(Icons.stacked_bar_chart, size: 20),
                  title: Text('Grouped Bars'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 8,
                child: ListTile(
                  leading: Icon(Icons.horizontal_rule, size: 20),
                  title: Text('Horizontal Bars'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 9,
                child: ListTile(
                  leading: Icon(Icons.stacked_line_chart, size: 20),
                  title: Text('Stacked Bars'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 10,
                child: ListTile(
                  leading: Icon(Icons.pie_chart, size: 20),
                  title: Text('Pie Chart'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 11,
                child: ListTile(
                  leading: Icon(Icons.analytics, size: 20),
                  title: Text('Dual Y-Axis'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 12,
                child: ListTile(
                  leading: Icon(Icons.grid_on, size: 20),
                  title: Text('Heatmap'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 13,
                child: ListTile(
                  leading: Icon(Icons.calendar_view_day, size: 20),
                  title: Text('Contributions'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 14,
                child: ListTile(
                  leading: Icon(Icons.linear_scale, size: 20),
                  title: Text('Progress Bars'),
                  subtitle: Text('New!',
                      style: TextStyle(color: Colors.green, fontSize: 10)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 15,
                child: ListTile(
                  leading: Icon(Icons.timeline, size: 20),
                  title: Text('Multi-Series Lines'),
                  subtitle: Text('New!',
                      style: TextStyle(color: Colors.green, fontSize: 10)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 16,
                child: ListTile(
                  leading: Icon(Icons.file_download, size: 20),
                  title: Text('Export'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 17,
                child: ListTile(
                  leading: Icon(Icons.gradient, size: 20),
                  title: Text('Gradient Bars'),
                  subtitle: Text('Experimental',
                      style: TextStyle(color: Colors.green, fontSize: 10)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 18,
                child: ListTile(
                  leading: Icon(Icons.auto_awesome, size: 20),
                  title: Text('Advanced Gradients'),
                  subtitle: Text('Experimental',
                      style: TextStyle(color: Colors.green, fontSize: 10)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _showControls = !_showControls),
            icon: Icon(_showControls ? Icons.visibility_off : Icons.visibility),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Scatter Plot'),
            Tab(text: 'Interactive'),
            Tab(text: 'Panning'), // New panning tab
            Tab(text: 'Line Chart'),
            Tab(text: 'Area Chart'), // New area chart tab
            Tab(text: 'Bubble Chart'), // New bubble chart tab
            Tab(text: 'Bar Chart'),
            Tab(text: 'Grouped Bars'),
            Tab(text: 'Horizontal Bars'),
            Tab(text: 'Stacked Bars'),
            Tab(text: 'Pie Chart'), // New pie chart tab
            Tab(text: 'Dual Y-Axis'),
            Tab(text: 'Heatmap'), // New heatmap tab
            Tab(text: 'Contributions'), // New contributions heatmap tab
            Tab(text: 'Progress Bars'), // New progress bars tab
            Tab(text: 'Multi-Series'), // New multi-series line chart tab
            Tab(text: 'Export'), // New export tab
            Tab(text: 'Gradient Bars'), // New gradient bars tab
            Tab(text: 'Advanced Gradients'), // New advanced gradients tab
          ],
        ),
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartPage(
                  chartTitles[0],
                  chartDescriptions[0],
                  buildScatterPlotTab(
                      currentTheme, _scatterPlotData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Avg Deal Size', '\$47.2k', '+12.3%', Colors.blue),
                    _buildStatsCard(
                        'Conversion Rate', '23.4%', '+2.1%', Colors.green),
                    _buildStatsCard(
                        'Total Deals', '156', '+8.9%', Colors.orange),
                  ],
                ),
                _buildChartPage(
                  // New interactive tab
                  chartTitles[1],
                  chartDescriptions[1],
                  buildInteractiveScatterTab(
                      currentTheme, _scatterPlotData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Hover Events', '234', '+45%', Colors.purple),
                    _buildStatsCard(
                        'Click Events', '89', '+12%', Colors.indigo),
                    _buildStatsCard(
                        'Tooltip Views', '1.2k', '+67%', Colors.teal),
                  ],
                ),
                _buildChartPage(
                  chartTitles[2],
                  chartDescriptions[2],
                  buildPanExampleTab(currentTheme, _sliderValue),
                  [
                    _buildStatsCard(
                        'Pan Events', '0', 'Real-time', Colors.blue),
                    _buildStatsCard('Data Points', '1.0k', '+0%', Colors.green),
                    _buildStatsCard(
                        'Range Updates', 'Live', 'Active', Colors.orange),
                  ],
                ),
                _buildChartPage(
                  chartTitles[3],
                  chartDescriptions[3],
                  buildLineChartTab(currentTheme, _lineChartData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Q4 Revenue', '\$1.2M', '+24.7%', Colors.green),
                    _buildStatsCard(
                        'YoY Growth', '31.5%', '+5.2%', Colors.blue),
                    _buildStatsCard(
                        'Profit Margin', '18.3%', '+2.1%', Colors.orange),
                  ],
                ),
                _buildChartPage(
                  chartTitles[4],
                  chartDescriptions[4],
                  AreaChartExample(
                    theme: currentTheme,
                    colorPalette: _colorPalettes[_currentPaletteIndex],
                  ),
                  [
                    _buildStatsCard(
                        'Total Traffic', '68.2k', '+15.3%', Colors.blue),
                    _buildStatsCard(
                        'Mobile Share', '62%', '+4.1%', Colors.green),
                    _buildStatsCard(
                        'Avg Session', '4:32', '+12s', Colors.orange),
                  ],
                ),
                _buildChartPage(
                  'Market Performance Analysis',
                  'Three-dimensional visualization showing revenue, customer count, and market share',
                  buildBubbleChartTab(currentTheme, _sliderValue),
                  [
                    _buildStatsCard(
                        'Market Leaders', '4', 'Enterprise', Colors.blue),
                    _buildStatsCard(
                        'Growth Rate', '23.5%', '+5.2%', Colors.green),
                    _buildStatsCard(
                        'Market Cap', '\$2.1B', '+12%', Colors.purple),
                  ],
                ),
                _buildChartPage(
                  chartTitles[5],
                  chartDescriptions[5],
                  buildBarChartTab(currentTheme, _barChartData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Mobile Revenue', '\$450k', '+18.2%', Colors.blue),
                    _buildStatsCard(
                        'Web Platform', '\$320k', '+12.4%', Colors.green),
                    _buildStatsCard(
                        'API Services', '\$180k', '+8.7%', Colors.orange),
                  ],
                ),
                _buildChartPage(
                  chartTitles[5],
                  chartDescriptions[5],
                  buildGroupedBarTab(
                      currentTheme, _groupedBarData, _sliderValue),
                  [
                    _buildStatsCard('Total Team', '127', '+12', Colors.blue),
                    _buildStatsCard(
                        'Eng Growth', '23.5%', '+3.2%', Colors.green),
                    _buildStatsCard(
                        'Avg Tenure', '2.8y', '+0.3y', Colors.purple),
                  ],
                ),
                _buildChartPage(
                  chartTitles[6],
                  chartDescriptions[6],
                  buildHorizontalBarTab(
                      currentTheme, _horizontalBarData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Total Revenue', '\$385k', '+18.2%', Colors.green),
                    _buildStatsCard('Product Mix', '52%', '+3.1%', Colors.blue),
                    _buildStatsCard(
                        'Growth Rate', '23.4%', '+5.7%', Colors.orange),
                  ],
                ),
                _buildChartPage(
                  chartTitles[7],
                  chartDescriptions[7],
                  buildStackedBarTab(
                      currentTheme, _stackedBarData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Avg Revenue', '\$156k', '+12.8%', Colors.blue),
                    _buildStatsCard(
                        'Avg Conversion', '19.2%', '+2.4%', Colors.green),
                    _buildStatsCard(
                        'Correlation', '0.73', '+0.12', Colors.purple),
                  ],
                ),
                _buildChartPage(
                  chartTitles[9],
                  chartDescriptions[9],
                  buildPieChartTab(
                      currentTheme, _scatterPlotData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Mobile Share', '45.2%', '+2.3%', Colors.blue),
                    _buildStatsCard(
                        'Desktop Share', '32.8%', '+1.1%', Colors.green),
                    _buildStatsCard(
                        'Tablet Share', '22.0%', '+0.8%', Colors.orange),
                  ],
                ),
                _buildChartPage(
                  chartTitles[10],
                  chartDescriptions[10],
                  buildDualAxisTab(currentTheme, _dualAxisData, _sliderValue),
                  [
                    _buildStatsCard(
                        'Avg Revenue', '\$156k', '+12.8%', Colors.blue),
                    _buildStatsCard(
                        'Avg Conversion', '19.2%', '+2.4%', Colors.green),
                    _buildStatsCard(
                        'Correlation', '0.73', '+0.12', Colors.purple),
                  ],
                ),
                _buildChartPage(
                  chartTitles[11],
                  chartDescriptions[11],
                  buildHeatMapTab(
                      currentTheme, _colorPalettes[_currentPaletteIndex]),
                  [
                    _buildStatsCard(
                        'Peak Hours', '8am-6pm', 'Weekdays', Colors.orange),
                    _buildStatsCard(
                        'Activity Rate', '68%', '+5.2%', Colors.red),
                    _buildStatsCard(
                        'Data Points', '84', '7x12 Grid', Colors.blue),
                  ],
                ),
                _buildChartPage(
                  chartTitles[12],
                  chartDescriptions[12],
                  buildContributionHeatMapTab(currentTheme),
                  [
                    _buildStatsCard(
                        'Total Commits', '523', '+89', Colors.green),
                    _buildStatsCard(
                        'Streak Days', '47', 'Current', Colors.blue),
                    _buildStatsCard('Active Days', '73%', '+8%', Colors.purple),
                  ],
                ),
                // Progress Bars Example (Index 13)
                _buildChartPage(
                  chartTitles[13],
                  chartDescriptions[13],
                  buildProgressBarsTab(currentTheme, _sliderValue),
                  [
                    _buildStatsCard('Orientations', '3',
                        'Horizontal, Vertical, Circular', Colors.blue),
                    _buildStatsCard('Styles', '4',
                        'Filled, Striped, Gradient, Custom', Colors.green),
                    _buildStatsCard('Animations', 'Smooth',
                        'Customizable Duration', Colors.purple),
                  ],
                ),
                _buildChartPage(
                  'Multi Series Line Chart with Custom Category Colors Demo',
                  'Platform analytics with brand-specific colors • iOS Blue, Android Green, Web Orange • NEW in v1.4.0',
                  buildMultiSeriesLineChartTab(currentTheme, _sliderValue),
                  [
                    _buildStatsCard('iOS Growth', '1,890', '+19.2%',
                        const Color(0xFF007ACC)),
                    _buildStatsCard('Android Users', '1,580', '+15.8%',
                        const Color(0xFF3DDC84)),
                    _buildStatsCard('Web Platform', '1,280', '+25.6%',
                        const Color(0xFFFF6B35)),
                  ],
                ),
                _buildChartPage(
                  'Chart Export Demo',
                  'Export your charts as scalable SVG vector graphics for reports and presentations',
                  ExportDemo(
                    theme: currentTheme,
                    colorPalette: _colorPalettes[_currentPaletteIndex],
                  ),
                  [
                    _buildStatsCard(
                        'Export Format', 'SVG', 'Vector Graphics', Colors.blue),
                    _buildStatsCard(
                        'Scalability', '∞', 'Infinite Zoom', Colors.green),
                    _buildStatsCard(
                        'File Size', 'Small', 'Compact', Colors.purple),
                  ],
                ),
                // Gradient Bar Example
                _buildChartPage(
                  'Gradient Bar Charts',
                  'Beautiful gradient fills for enhanced visual appeal • Linear gradients from light to dark',
                  const DebugGradientExample(),
                  [
                    _buildStatsCard(
                        'Gradient Types', '4', 'Linear', Colors.blue),
                    _buildStatsCard(
                        'Visual Appeal', '100%', 'Enhanced', Colors.green),
                    _buildStatsCard(
                        'Animation', 'Smooth', 'Back-ease', Colors.purple),
                  ],
                ),
                // Advanced Gradient Example
                _buildChartPage(
                  'Advanced Gradient Effects',
                  'Multiple gradient types: Linear, Radial, Sweep • Works with bars and points',
                  const AdvancedGradientExample(),
                  [
                    _buildStatsCard(
                        'Gradient Types', 'Mixed', 'All Types', Colors.blue),
                    _buildStatsCard(
                        'Chart Types', '2', 'Bars + Points', Colors.green),
                    _buildStatsCard(
                        'Creativity', '∞', 'Unlimited', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      _currentThemeIndex =
                          (_currentThemeIndex + 1) % _themes.length;
                    });
                  },
                  icon: const Icon(Icons.palette),
                  label: Text(_themeNames[_currentThemeIndex]),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _currentPaletteIndex =
                          (_currentPaletteIndex + 1) % _colorPalettes.length;
                    });
                  },
                  backgroundColor: _colorPalettes[_currentPaletteIndex].first,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.color_lens),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartPage(
      String title, String description, Widget chart, List<Widget> stats) {
    // Determine chart height based on chart type
    double chartHeight = 380; // Default height
    if (title.contains('Market Performance Analysis') ||
        title.contains('Bubble')) {
      chartHeight = 500; // Larger height for bubble charts to prevent cutoff
    } else if (title.contains('Heatmap') || title.contains('Contributions')) {
      chartHeight = 450; // Slightly larger for heatmaps
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: stats
                .map((stat) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: stat,
                      ),
                    ))
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
              child: chart,
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
                      Icons.auto_awesome,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
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
    );
  }

  Widget _buildFeatureList() {
    final features = getChartFeatures(_tabController.index);
    return Column(
      children: features
          .map((feature) => Padding(
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
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
