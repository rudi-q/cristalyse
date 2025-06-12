import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

import 'graphs/barChart.dart';
import 'graphs/groupedBar.dart';
import 'graphs/horizontalBarChart.dart';
import 'graphs/lineChart.dart';
import 'graphs/scatterPlot.dart';

import 'dart:math' as math;

void main() {
  runApp(CristalyseExampleApp());
}

class CristalyseExampleApp extends StatelessWidget {
  const CristalyseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cristalyse Examples',
      debugShowCheckedModeBanner: false,
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
  int _currentThemeIndex = 0;
  final _themes = [
    ChartTheme.defaultTheme(),
    ChartTheme.darkTheme(),
    ChartTheme.solarizedLightTheme(),
    ChartTheme.solarizedDarkTheme(),
  ];

  late final List<Map<String, dynamic>> _scatterPlotData;
  late final List<Map<String, dynamic>> _lineChartData;
  late final List<Map<String, dynamic>> _barChartData;
  late final List<Map<String, dynamic>> _groupedBarData;
  late final List<Map<String, dynamic>> _horizontalBarData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _scatterPlotData = List.generate(50, (i) {
      final x = i.toDouble();
      final y =
          x * 0.5 + (i % 3) * 2 + (i % 7) * 0.3 + math.Random().nextDouble() * 2;
      final category = ['Alpha', 'Beta', 'Gamma'][i % 3];
      return {'x': x, 'y': y, 'category': category, 'size': (i % 5) + 1.0};
    });

    _lineChartData = List.generate(30, (i) {
      final x = i.toDouble();
      final y = 10 + 5 * math.sin(x * 0.3) + math.Random().nextDouble() * 2;
      return {'x': x, 'y': y, 'category': 'Time Series'};
    });

    final barCategories = ['Q1', 'Q2', 'Q3', 'Q4'];
    _barChartData = barCategories.map((quarter) {
      final revenue = 50 + math.Random().nextDouble() * 50;
      return {'quarter': quarter, 'revenue': revenue};
    }).toList();

    final groupedQuarters = ['Q1', 'Q2', 'Q3', 'Q4'];
    final groupedProducts = ['Product A', 'Product B', 'Product C'];
    _groupedBarData = <Map<String, dynamic>>[];
    for (final quarter in groupedQuarters) {
      for (final product in groupedProducts) {
        final revenue = 20 + math.Random().nextDouble() * 40;
        _groupedBarData
            .add({'quarter': quarter, 'product': product, 'revenue': revenue});
      }
    }

    final horizontalDepartments = [
      'Engineering',
      'Sales',
      'Marketing',
      'Support',
      'HR'
    ];
    _horizontalBarData = horizontalDepartments.map((dept) {
      final headcount = 5 + math.Random().nextDouble() * 45;
      return {'department': dept, 'headcount': headcount};
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ChartTheme get currentTheme => _themes[_currentThemeIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cristalyse Examples'),
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
          buildScatterPlotTab(currentTheme, _scatterPlotData),
          buildLineChartTab(currentTheme, _lineChartData),
          buildBarChartTab(currentTheme, _barChartData),
          buildGroupedBarTab(currentTheme, _groupedBarData),
          buildHorizontalBarTab(currentTheme, _horizontalBarData)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentThemeIndex = (_currentThemeIndex + 1) % _themes.length;
          });
        },
        tooltip: 'Change Theme',
        child: const Icon(Icons.palette),
      ),
    );
  }
}