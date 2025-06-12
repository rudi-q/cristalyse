import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildScatterPlotTab(var currentTheme) {
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
        Text('Animated Scatter Plot'),
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