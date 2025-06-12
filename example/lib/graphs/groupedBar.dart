import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildGroupedBarTab(
    ChartTheme currentTheme, List<Map<String, dynamic>> data) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grouped Bar Chart'),
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