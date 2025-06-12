import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildGroupedBarTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Grouped Bar Chart'),
        const SizedBox(height: 16),
        Container(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'quarter', y: 'revenue', color: 'product')
              .geomBar(
                  width: sliderValue.clamp(0.1, 1.0),
                  style: BarStyle.grouped,
                  alpha: 0.9)
              .scaleXOrdinal()
              .scaleYContinuous(min: 0)
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Multiple series grouped side-by-side\n• Color mapping for different products\n• Coordinated group animation'),
      ],
    ),
  );
}
