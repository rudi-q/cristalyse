import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildStackedBarTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stacked Bar Chart'),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'quarter', y: 'revenue', color: 'category')
              .geomBar(
                  width: sliderValue.clamp(0.1, 1.0),
                  style: BarStyle.stacked, // This is the key!
                  alpha: 0.9)
              .scaleXOrdinal()
              .scaleYContinuous(min: 0)
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutQuart)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Segments stack on top of each other\n• Each color represents a different category\n• Great for showing part-to-whole relationships\n• Animated segment-by-segment building'),
      ],
    ),
  );
}
