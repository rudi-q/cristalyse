import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CristalyseExampleApp());
}

class CristalyseExampleApp extends StatelessWidget {
  const CristalyseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cristalyse Examples',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ChartTheme get currentTheme => _isDarkMode ? ChartTheme.darkTheme() : ChartTheme.defaultTheme();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cristalyse Examples'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Scatter Plot'),
            Tab(text: 'Line Chart'),
            Tab(text: 'Bar Chart'),
            Tab(text: 'Grouped Bars'),
            Tab(text: 'Horizontal Bars')
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScatterPlotTab(),
          _buildLineChartTab(),
          _buildBarChartTab(),
          _buildGroupedBarTab(),
          _buildHorizontalBarTab()
        ],
      ),
    );
  }

  Widget _buildScatterPlotTab() {
    // Generate scatter plot data
    final data = List.generate(50, (i) {
      final x = i.toDouble();
      final y = x * 0.5 + (i % 3) * 2 + (i % 7) * 0.3 + math.Random().nextDouble() * 2;
      final category = ['Alpha', 'Beta', 'Gamma'][i % 3];
      return {'x': x, 'y': y, 'category': category, 'size': (i % 5) + 1.0};
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Animated Scatter Plot', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Container(
            height: 400,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y', color: 'category', size: 'size')
                .geomPoint(alpha: 0.8)
                .scaleXContinuous(min: 0, max: 50)
                .scaleYContinuous()
                .theme(currentTheme)
                .animate(duration: Duration(milliseconds: 800), curve: Curves.elasticOut)
                .build(),
          ),
          SizedBox(height: 16),
          Text('• Points animate in with staggered timing\n• Size and color mapped to data\n• Smooth elastic animation curve'),
        ],
      ),
    );
  }

  Widget _buildLineChartTab() {
    // Generate time series data
    final data = List.generate(30, (i) {
      final x = i.toDouble();
      final y = 10 + 5 * math.sin(x * 0.3) + math.Random().nextDouble() * 2;
      return {'x': x, 'y': y, 'category': 'Time Series'};
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Animated Line Chart', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Container(
            height: 400,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y')
                .geomLine(strokeWidth: 3.0, alpha: 0.9)
                .scaleXContinuous()
                .scaleYContinuous()
                .theme(currentTheme)
                .animate(duration: Duration(milliseconds: 1200))
                .build(),
          ),
          SizedBox(height: 16),
          Text('• Line draws from left to right\n• Smooth animation with partial segments\n• Responsive to theme changes'),
        ],
      ),
    );
  }

  Widget _buildBarChartTab() {
    // Generate bar chart data
    final categories = ['Q1', 'Q2', 'Q3', 'Q4'];
    final data = categories.map((quarter) {
      final revenue = 50 + math.Random().nextDouble() * 50;
      return {'quarter': quarter, 'revenue': revenue};
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Animated Bar Chart', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Container(
            height: 400,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'quarter', y: 'revenue')
                .geomBar(width: 0.7, alpha: 0.8)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .theme(currentTheme)
                .animate(duration: Duration(milliseconds: 1000), curve: Curves.easeOutBack)
                .build(),
          ),
          SizedBox(height: 16),
          Text('• Bars grow from bottom with staggered timing\n• Categorical X-axis with ordinal scale\n• Smooth back-ease animation'),
        ],
      ),
    );
  }

  Widget _buildGroupedBarTab() {
    // Generate grouped bar data
    final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
    final products = ['Product A', 'Product B', 'Product C'];
    final data = <Map<String, dynamic>>[];

    for (final quarter in quarters) {
      for (final product in products) {
        final revenue = 20 + math.Random().nextDouble() * 40;
        data.add({'quarter': quarter, 'product': product, 'revenue': revenue});
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grouped Bar Chart', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Container(
            height: 400,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'quarter', y: 'revenue', color: 'product')
                .geomBar(width: 0.8, style: BarStyle.grouped, alpha: 0.9)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .theme(currentTheme)
                .animate(duration: Duration(milliseconds: 1200), curve: Curves.easeOutCubic)
                .build(),
          ),
          SizedBox(height: 16),
          Text('• Multiple series grouped side-by-side\n• Color mapping for different products\n• Coordinated group animation'),
        ],
      ),
    );
  }

  Widget _buildHorizontalBarTab() {
    // Generate horizontal bar data
    final departments = ['Engineering', 'Sales', 'Marketing', 'Support', 'HR'];
    final data = departments.map((dept) {
      final headcount = 5 + math.Random().nextDouble() * 45;
      return {'department': dept, 'headcount': headcount};
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horizontal Bar Chart', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Container(
            height: 400,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'department', y: 'headcount')
                .geomBar()
                .coordFlip()
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .theme(currentTheme)
                .animate(duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuart)
                .build(),
          ),
          SizedBox(height: 16),
          Text('• Bars grow from left to right\n• Categorical Y-axis for departments\n• Great for ranking data'),
        ],
      ),
    );
  }
}

// Extension to add copyWith method to ChartTheme
extension ChartThemeExtension on ChartTheme {
  ChartTheme copyWith({
    Color? backgroundColor,
    Color? plotBackgroundColor,
    Color? primaryColor,
    Color? borderColor,
    Color? gridColor,
    Color? axisColor,
    double? gridWidth,
    double? axisWidth,
    double? pointSizeDefault,
    double? pointSizeMin,
    double? pointSizeMax,
    List<Color>? colorPalette,
    EdgeInsets? padding,
    TextStyle? axisTextStyle,
  }) {
    return ChartTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      plotBackgroundColor: plotBackgroundColor ?? this.plotBackgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      borderColor: borderColor ?? this.borderColor,
      gridColor: gridColor ?? this.gridColor,
      axisColor: axisColor ?? this.axisColor,
      gridWidth: gridWidth ?? this.gridWidth,
      axisWidth: axisWidth ?? this.axisWidth,
      pointSizeDefault: pointSizeDefault ?? this.pointSizeDefault,
      pointSizeMin: pointSizeMin ?? this.pointSizeMin,
      pointSizeMax: pointSizeMax ?? this.pointSizeMax,
      colorPalette: colorPalette ?? this.colorPalette,
      padding: padding ?? this.padding,
      axisTextStyle: axisTextStyle ?? this.axisTextStyle,
    );
  }
}