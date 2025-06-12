import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildLineChartTab(ChartTheme currentTheme) {
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
        Text('Animated Line Chart'),
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