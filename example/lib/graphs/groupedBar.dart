import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildGroupedBarTab(ChartTheme currentTheme) {
  // Generate grouped bar data
  final quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
  final products = ['Product A', 'Product B', 'Product C'];
  final data = <Map<String, dynamic>>[];

  for (final quarter in quarters) {
    for (final product in products) {
      final revenue = 20 + math.Random().nextDouble() * 40;
      data.add({'quarter': quarter, 'product': product, 'revenue': revenue});
    }
  }

  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
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