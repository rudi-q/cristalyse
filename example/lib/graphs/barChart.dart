import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildBarChartTab(ChartTheme currentTheme) {
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
        Text('Animated Bar Chart'),
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