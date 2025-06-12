import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

import 'graphs/barChart.dart';
import 'graphs/groupedBar.dart';
import 'graphs/horizontalBarChart.dart';
import 'graphs/lineChart.dart';
import 'graphs/scatterPlot.dart';

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
          buildScatterPlotTab(currentTheme),
          buildLineChartTab(currentTheme),
          buildBarChartTab(currentTheme),
          buildGroupedBarTab(currentTheme),
          buildHorizontalBarTab(currentTheme)
        ],
      ),
    );
  }
}