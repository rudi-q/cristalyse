import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildPieChartTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  // Create pie chart specific data
  final pieData = [
    {'category': 'Mobile', 'revenue': 45.2, 'users': 1200},
    {'category': 'Desktop', 'revenue': 32.8, 'users': 800},
    {'category': 'Tablet', 'revenue': 22.0, 'users': 600},
  ];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Animated Pie Chart'),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(pieData)
              .mappingPie(value: 'revenue', category: 'category')
              .geomPie(
                outerRadius:
                    100.0 + sliderValue * 50.0, // Use slider for radius
                strokeWidth: 2.0,
                strokeColor: Colors.white,
                showLabels: true,
                showPercentages: true,
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Slices animate in with staggered timing\n• Percentages shown on labels\n• Smooth elastic animation curve'),
        const SizedBox(height: 32),
        const Text('Donut Chart Example'),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(pieData)
              .mappingPie(value: 'users', category: 'category')
              .geomPie(
                innerRadius: 60.0, // Creates larger donut hole
                outerRadius: 120.0,
                strokeWidth: 3.0,
                strokeColor: Colors.white,
                showLabels: true,
                showPercentages: false, // Show actual values instead
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutBack)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Donut chart with inner radius\n• Shows actual values instead of percentages\n• Different animation curve'),
      ],
    ),
  );
}
