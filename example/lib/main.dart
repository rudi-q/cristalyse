import 'package:cristalyse/cristalyse.dart';
import 'package:cristalyse_example/chartTheme.dart';
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

  int _currentPaletteIndex = 0;
  final _colorPalettes = [
    ChartTheme.defaultTheme().colorPalette, // Default
    const [
      Color(0xfff44336),
      Color(0xffe91e63),
      Color(0xff9c27b0),
      Color(0xff673ab7),
    ], // Warm
    const [
      Color(0xff2196f3),
      Color(0xff00bcd4),
      Color(0xff009688),
      Color(0xff4caf50),
    ], // Cool
    const [
      Color(0xffffb74d),
      Color(0xffff8a65),
      Color(0xffdce775),
      Color(0xffaed581),
    ], // Pastel
  ];

  double _sliderValue = 0.5;

  late final List<Map<String, dynamic>> _scatterPlotData;
  late final List<Map<String, dynamic>> _lineChartData;
  late final List<Map<String, dynamic>> _barChartData;
  late final List<Map<String, dynamic>> _groupedBarData;
  late final List<Map<String, dynamic>> _horizontalBarData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      // Rebuild to update the displayed value when the tab changes
      if (mounted) {
        setState(() {});
      }
    });

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

  ChartTheme get currentTheme {
    final baseTheme = _themes[_currentThemeIndex];
    return baseTheme.copyWith(
      colorPalette: _colorPalettes[_currentPaletteIndex],
    );
  }

  String _getDisplayedValue() {
    final index = _tabController.index;
    switch (index) {
      case 0: // Scatter
        final value = 2.0 + _sliderValue * 20.0;
        return 'Size: ${value.toStringAsFixed(1)}';
      case 1: // Line
        final value = 1.0 + _sliderValue * 9.0;
        return 'Width: ${value.toStringAsFixed(1)}';
      case 2: // Bar
      case 3: // Grouped Bar
      case 4: // Horizontal Bar
        final value = _sliderValue.clamp(0.1, 1.0);
        return 'Width: ${value.toStringAsFixed(2)}';
      default:
        return _sliderValue.toStringAsFixed(2);
    }
  }

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
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Adjust Value'),
                Expanded(
                  child: Slider(
                    value: _sliderValue,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: _sliderValue.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(_getDisplayedValue(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildScatterPlotTab(currentTheme, _scatterPlotData, _sliderValue),
                buildLineChartTab(currentTheme, _lineChartData, _sliderValue),
                buildBarChartTab(currentTheme, _barChartData, _sliderValue),
                buildGroupedBarTab(currentTheme, _groupedBarData, _sliderValue),
                buildHorizontalBarTab(
                    currentTheme, _horizontalBarData, _sliderValue)
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _currentThemeIndex = (_currentThemeIndex + 1) % _themes.length;
              });
            },
            tooltip: 'Change Theme',
            child: const Icon(Icons.palette),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _currentPaletteIndex =
                    (_currentPaletteIndex + 1) % _colorPalettes.length;
              });
            },
            tooltip: 'Change Colors',
            child: const Icon(Icons.color_lens),
          ),
        ],
      ),
    );
  }
}