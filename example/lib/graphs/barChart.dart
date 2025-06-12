import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildBarChartTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Animated Bar Chart'),
        const SizedBox(height: 16),
        Container(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'quarter', y: 'revenue')
              .geomBar(width: sliderValue.clamp(0.1, 1.0), alpha: 0.8)
              .scaleXOrdinal()
              .scaleYContinuous(min: 0)
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutBack)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Bars grow from bottom with staggered timing\n• Categorical X-axis with ordinal scale\n• Smooth back-ease animation'),
      ],
    ),
  );
}
