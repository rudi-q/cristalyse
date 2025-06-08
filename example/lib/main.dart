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
    _tabController = TabController(length: 4, vsync: this);
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
          tabs: [
            Tab(text: 'Scatter Plot'),
            Tab(text: 'Line Chart'),
            Tab(text: 'Combined'),
            Tab(text: 'Multi-Series'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScatterPlotTab(),
          _buildLineChartTab(),
          _buildCombinedTab(),
          _buildMultiSeriesTab(),
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
                .geom_point(alpha: 0.8)
                .scale_x_continuous(min: 0, max: 50)
                .scale_y_continuous()
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
                .geom_line(strokeWidth: 3.0, alpha: 0.9)
                .scale_x_continuous()
                .scale_y_continuous()
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

  Widget _buildCombinedTab() {
    // Generate data for combined chart
    final data = List.generate(25, (i) {
      final x = i.toDouble();
      final y = 5 + 3 * math.sin(x * 0.4) + math.Random().nextDouble();
      return {'x': x, 'y': y};
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Combined Line + Points', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Container(
            height: 400,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y')
                .geom_line(strokeWidth: 2.0, alpha: 0.7)
                .geom_point(size: 4.0, alpha: 0.9)
                .scale_x_continuous()
                .scale_y_continuous()
                .theme(currentTheme)
                .animate(duration: Duration(milliseconds: 1000), curve: Curves.easeInOutCubic)
                .build(),
          ),
          SizedBox(height: 16),
          Text('• Multiple geometries on same chart\n• Line appears first, then points\n• Coordinated animation timing'),
        ],
      ),
    );
  }

  Widget _buildMultiSeriesTab() {
    // Generate multi-series data
    final categories = ['Series A', 'Series B', 'Series C'];
    final data = <Map<String, dynamic>>[];

    for (final category in categories) {
      for (int i = 0; i < 20; i++) {
        final x = i.toDouble();
        final baseY = categories.indexOf(category) * 3;
        final y = baseY + 2 * math.sin(x * 0.5 + categories.indexOf(category)) +
            math.Random().nextDouble();
        data.add({'x': x, 'y': y, 'category': category});
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Multi-Series Line Chart', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          Container(
            height: 400,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geom_line(strokeWidth: 2.5, alpha: 0.8)
                .geom_point(size: 3.0, alpha: 0.6)
                .scale_x_continuous()
                .scale_y_continuous()
                .theme(currentTheme)
                .animate(duration: Duration(milliseconds: 1500), curve: Curves.easeOutQuart)
                .build(),
          ),
          SizedBox(height: 16),
          Text('• Multiple series with color mapping\n• Each series animates independently\n• Points and lines coordinated'),
        ],
      ),
    );
  }
}