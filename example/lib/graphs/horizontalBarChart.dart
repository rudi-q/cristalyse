import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildHorizontalBarTab(
    ChartTheme currentTheme, List<Map<String, dynamic>> data) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Horizontal Bar Chart'),
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