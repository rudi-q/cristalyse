import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildHorizontalBarTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Horizontal Bar Chart'),
        const SizedBox(height: 8),
        const Text(
          'Team headcount by department',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'department', y: 'headcount')
              .geomBar(width: sliderValue.clamp(0.1, 1.0))
              .coordFlip()
              .scaleXOrdinal()
              .scaleYContinuous(
                min: 0,
                labels: (value) =>
                    '${value.round()}', // Clean whole numbers for headcount
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutQuart)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Bars grow from left to right\n• Categorical Y-axis for departments\n• Clean whole number formatting for headcount\n• Great for ranking data'),
      ],
    ),
  );
}
