import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildBarChartTab(
    ChartTheme currentTheme, List<Map<String, dynamic>> data) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
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