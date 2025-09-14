import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildProgressBarsTab(ChartTheme currentTheme, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Bars Showcase',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Horizontal, vertical, and circular progress bars with animations',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Horizontal Progress Bars
        Text(
          'Horizontal Progress Bars',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: CristalyseChart()
              .data(_generateProgressData())
              .mappingProgress(value: 'completion', label: 'task', category: 'department')
              .geomProgress(
                orientation: ProgressOrientation.horizontal,
                thickness: 20.0 + (sliderValue * 20.0), // 20-40px thickness
                cornerRadius: 8.0,
                showLabel: true,
                style: ProgressStyle.gradient,
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutBack)
              .build(),
        ),
        const SizedBox(height: 24),

        // Vertical Progress Bars
        Text(
          'Vertical Progress Bars',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: CristalyseChart()
              .data(_generateProgressData())
              .mappingProgress(value: 'completion', label: 'task', category: 'department')
              .geomProgress(
                orientation: ProgressOrientation.vertical,
                thickness: 15.0 + (sliderValue * 15.0), // 15-30px thickness
                cornerRadius: 6.0,
                showLabel: true,
                style: ProgressStyle.filled,
                backgroundColor: Colors.grey.shade200,
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic)
              .build(),
        ),
        const SizedBox(height: 24),

        // Circular Progress Bars
        Text(
          'Circular Progress Bars',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: CristalyseChart()
              .data(_generateProgressData())
              .mappingProgress(value: 'completion', label: 'task', category: 'department')
              .geomProgress(
                orientation: ProgressOrientation.circular,
                thickness: 25.0 + (sliderValue * 25.0), // 25-50px radius
                showLabel: true,
                style: ProgressStyle.filled,
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.elasticOut)
              .build(),
        ),
        const SizedBox(height: 16),
        
        const Text(
            '• Horizontal bars grow from left to right with gradient fill\n'
            '• Vertical bars grow from bottom to top with solid colors\n'
            '• Circular progress shows completion as arcs from 12 o\'clock\n'
            '• All progress bars support custom colors, gradients, and labels\n'
            '• Animations are staggered for visual appeal'),
      ],
    ),
  );
}

// Generate sample progress data
List<Map<String, dynamic>> _generateProgressData() {
  return [
    {
      'task': 'Backend API',
      'completion': 85.0,
      'department': 'Engineering'
    },
    {
      'task': 'Frontend UI',
      'completion': 70.0,
      'department': 'Engineering'
    },
    {
      'task': 'User Testing',
      'completion': 45.0,
      'department': 'Product'
    },
    {
      'task': 'Documentation',
      'completion': 30.0,
      'department': 'Product'
    },
    {
      'task': 'Marketing Campaign',
      'completion': 90.0,
      'department': 'Marketing'
    },
  ];
}