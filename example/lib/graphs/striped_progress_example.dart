import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

/// Example demonstrating striped progress bars
Widget buildStripedProgressExample(ChartTheme currentTheme) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Striped Progress Bars',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Progress bars with diagonal stripe patterns for enhanced visual distinction',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Horizontal Striped Progress Bars
        Text(
          'Horizontal Striped Bars',
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
              .mappingProgress(
                  value: 'completion', label: 'task', category: 'department')
              .geomProgress(
                orientation: ProgressOrientation.horizontal,
                style: ProgressStyle.striped,
                thickness: 25.0,
                cornerRadius: 8.0,
                showLabel: true,
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic)
              .build(),
        ),
        const SizedBox(height: 24),

        // Vertical Striped Progress Bars
        Text(
          'Vertical Striped Bars',
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
              .mappingProgress(
                  value: 'completion', label: 'task', category: 'department')
              .geomProgress(
                orientation: ProgressOrientation.vertical,
                style: ProgressStyle.striped,
                thickness: 30.0,
                cornerRadius: 6.0,
                showLabel: true,
              )
              .theme(currentTheme)
              .animate(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic)
              .build(),
        ),
        const SizedBox(height: 16),

        const Text(
            '• Striped pattern creates visual distinction from solid fills\\n'
            '• Diagonal stripes at 45-degree angle\\n'
            '• Works with both horizontal and vertical orientations\\n'
            '• Maintains rounded corners and smooth animations\\n'
            '• Great for showing active/in-progress states'),
      ],
    ),
  );
}

// Generate sample progress data
List<Map<String, dynamic>> _generateProgressData() {
  return [
    {'task': 'Backend API', 'completion': 85.0, 'department': 'Engineering'},
    {'task': 'Frontend UI', 'completion': 70.0, 'department': 'Engineering'},
    {'task': 'User Testing', 'completion': 45.0, 'department': 'Product'},
    {'task': 'Documentation', 'completion': 30.0, 'department': 'Product'},
    {
      'task': 'Marketing Campaign',
      'completion': 90.0,
      'department': 'Marketing'
    },
  ];
}
