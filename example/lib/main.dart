import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:cristalyse_example/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'graphs/area_chart.dart';
import 'graphs/bar_chart.dart';
import 'graphs/bubble_chart.dart';
import 'graphs/dual_axis_chart.dart';
import 'graphs/export_demo.dart';
import 'graphs/grouped_bar.dart';
import 'graphs/heatmap_chart.dart';
import 'graphs/horizontal_bar_chart.dart';
import 'graphs/interactive_scatter.dart';
import 'graphs/line_chart.dart';
import 'graphs/pan_example.dart';
import 'graphs/pie_chart.dart';
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
    _tabController = TabController(
        length: 15, vsync: this); // Updated to 15 tabs (added bubble chart)
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
                  subtitle: Text('New!', style: TextStyle(color: Colors.green, fontSize: 10)),
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
                  leading: Icon(Icons.file_download, size: 20),
                  title: Text('Export'),
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
            Tab(text: 'Export'), // New export tab
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
                  buildBubbleChartTab(
                      currentTheme, _scatterPlotData, _sliderValue),
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
            height: 380,
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
    final features = _getChartFeatures();
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

  List<String> _getChartFeatures() {
    switch (_tabController.index) {
      case 0:
        return [
          'Grammar of graphics API with intuitive data mapping',
          'Smooth 60fps animations with elastic curves',
          'Size and color encoding for multi-dimensional data',
          'Responsive scaling and high-DPI support'
        ];
      case 1: // Interactive scatter plot
        return [
          'Rich tooltip system with customizable content and styling',
          'Hover detection with spatial indexing for smooth performance',
          'Click interactions for navigation and custom actions',
          'Mobile-optimized touch handling and gesture recognition'
        ];
      case 2: // Panning demo
        return [
          'Real-time pan detection with visible range callbacks',
          'Perfect for large datasets with efficient data loading',
          'Throttled updates to prevent overwhelming the database',
          'Coordinate transformation from screen pixels to data values'
        ];
      case 3: // Line chart
        return [
          'Progressive line drawing with smooth transitions',
          'Multi-series support with automatic color mapping',
          'Customizable stroke width and transparency',
          'Optimized for time-series and continuous data'
        ];
      case 4: // Area chart
        return [
          'Smooth area fills with customizable transparency',
          'Progressive animation revealing data over time',
          'Multi-series support with overlapping transparency',
          'Combined area + line + point visualizations'
        ];
      case 5: // Bar chart
        return [
          'Categorical data visualization with ordinal scales',
          'Staggered bar animations for visual impact',
          'Automatic baseline detection and scaling',
          'Customizable bar width and styling options'
        ];
      case 6: // Grouped bars
        return [
          'Side-by-side comparison of multiple data series',
          'Clean currency formatting for financial comparisons',
          'Coordinated group animations with smooth timing',
          'Automatic legend generation from color mappings',
          'Perfect for product or regional comparisons'
        ];
      case 7: // Horizontal bars
        return [
          'Coordinate system flipping for horizontal layouts',
          'Ideal for ranking and categorical comparisons',
          'Space-efficient labeling for long category names',
          'Consistent animation system across orientations'
        ];
      case 8: // Stacked bars
        return [
          'Segment-by-segment progressive stacking animation',
          'Automatic part-to-whole relationship visualization',
          'Consistent color mapping across all segments',
          'Perfect for budget breakdowns and composition analysis'
        ];
      case 9: // Pie charts
        return [
          'Smooth slice animations with staggered timing',
          'Donut chart support with configurable inner radius',
          'Smart label positioning with formatting',
          'Exploded slices for emphasis and visual impact'
        ];
      case 10: // Dual Y-axis
        return [
          'Dual Y-axis support for different data scales',
          'Independent left and right axis scaling',
          'Combined bar and line visualizations',
          'Perfect for correlating volume vs efficiency metrics'
        ];
      case 11: // Heatmap
        return [
          'Color-coded intensity visualization for multi-dimensional data',
          'Animated cell appearance with wave effect',
          'Customizable color gradients with interpolation support',
          'Value labels with automatic contrast for readability',
          'Null value support with customizable styling'
        ];
      case 12: // Contributions heatmap
        return [
          'GitHub-style contribution graph visualization',
          'Discrete color levels for activity intensity',
          'Weekly grid layout with day-based organization',
          'Animated cell scaling with elastic curves',
          'Perfect for activity tracking and habit visualization'
        ];
      case 13: // Export demo
        return [
          'Export charts as scalable SVG vector graphics',
          'Infinite zoom and professional quality output',
          'Small file sizes perfect for web and print',
          'Editable in design software and ideal for presentations'
        ];
      default:
        return [];
    }
  }
}
