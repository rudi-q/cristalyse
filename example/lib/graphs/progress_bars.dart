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
          child:
              CristalyseChart()
                  .data(_generateProgressData())
                  .mappingProgress(
                    value: 'completion',
                    label: 'task',
                    category: 'department',
                  )
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
                    curve: Curves.easeOutBack,
                  )
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
          child:
              CristalyseChart()
                  .data(_generateProgressData())
                  .mappingProgress(
                    value: 'completion',
                    label: 'task',
                    category: 'department',
                  )
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
                    curve: Curves.easeOutCubic,
                  )
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
          child:
              CristalyseChart()
                  .data(_generateProgressData())
                  .mappingProgress(
                    value: 'completion',
                    label: 'task',
                    category: 'department',
                  )
                  .geomProgress(
                    orientation: ProgressOrientation.circular,
                    thickness: 25.0 + (sliderValue * 25.0), // 25-50px radius
                    showLabel: true,
                    style: ProgressStyle.filled,
                  )
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.elasticOut,
                  )
                  .build(),
        ),
        const SizedBox(height: 24),

        // Stacked Progress Bars
        Text(
          'Stacked Progress Bars',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child:
              CristalyseChart()
                  .data(_generateStackedProgressData())
                  .mappingProgress(
                    value: 'completion',
                    label: 'project',
                    category: 'phase',
                  )
                  .geomProgress(
                    orientation: ProgressOrientation.horizontal,
                    style: ProgressStyle.stacked,
                    thickness: 25.0 + (sliderValue * 15.0),
                    cornerRadius: 6.0,
                    showLabel: true,
                    segments: [30.0, 45.0, 25.0], // Three segments
                    segmentColors: [
                      Colors.red.shade400,
                      Colors.orange.shade400,
                      Colors.green.shade400,
                    ],
                  )
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutQuart,
                  )
                  .build(),
        ),
        const SizedBox(height: 24),

        // Grouped Progress Bars
        Text(
          'Grouped Progress Bars',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child:
              CristalyseChart()
                  .data(_generateProgressData())
                  .mappingProgress(
                    value: 'completion',
                    label: 'task',
                    category: 'department',
                  )
                  .geomProgress(
                    orientation: ProgressOrientation.horizontal,
                    style: ProgressStyle.grouped,
                    thickness: 20.0 + (sliderValue * 15.0),
                    cornerRadius: 4.0,
                    showLabel: true,
                    groupCount: 4,
                    groupSpacing: 6.0,
                  )
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 1600),
                    curve: Curves.bounceOut,
                  )
                  .build(),
        ),
        const SizedBox(height: 24),

        // Gauge Progress Bars
        Text(
          'Gauge/Speedometer Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child:
              CristalyseChart()
                  .data(_generateGaugeData())
                  .mappingProgress(
                    value: 'completion',
                    label: 'metric',
                    category: 'type',
                  )
                  .geomProgress(
                    orientation: ProgressOrientation.circular,
                    style: ProgressStyle.gauge,
                    thickness: 30.0 + (sliderValue * 20.0),
                    showLabel: true,
                    showTicks: true,
                    tickCount: 8,
                    startAngle: -2.356, // -3π/4 (225 degrees)
                    sweepAngle: 4.712, // 3π/2 (270 degrees)
                    gaugeRadius: 80.0, // Required for gauge style
                  )
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.elasticOut,
                  )
                  .build(),
        ),
        const SizedBox(height: 24),

        // Concentric Progress Bars
        Text(
          'Concentric Ring Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 320,
          child:
              CristalyseChart()
                  .data(_generateConcentricData())
                  .mappingProgress(
                    value: 'completion',
                    label: 'system',
                    category: 'priority',
                  )
                  .geomProgress(
                    orientation: ProgressOrientation.circular,
                    style: ProgressStyle.concentric,
                    thickness: 25.0 + (sliderValue * 15.0),
                    showLabel: true,
                    concentricRadii: [30.0, 50.0, 70.0, 90.0],
                    concentricThicknesses: [8.0, 10.0, 12.0, 14.0],
                  )
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 1800),
                    curve: Curves.easeInOutCubic,
                  )
                  .build(),
        ),
        const SizedBox(height: 16),

        const Text(
          '• Horizontal bars grow from left to right with gradient fill\n'
          '• Vertical bars grow from bottom to top with solid colors\n'
          '• Circular progress shows completion as arcs from 12 o\'clock\n'
          '• Stacked bars show multiple segments in a single bar\n'
          '• Grouped bars display multiple progress bars side by side\n'
          '• Gauge style creates speedometer-like indicators with ticks\n'
          '• Concentric rings show nested progress levels\n'
          '• All progress bars support custom colors, gradients, and labels\n'
          '• Animations are staggered for visual appeal',
        ),
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
      'department': 'Marketing',
    },
  ];
}

// Generate stacked progress data
List<Map<String, dynamic>> _generateStackedProgressData() {
  return [
    {'project': 'Mobile App', 'completion': 100.0, 'phase': 'Development'},
    {'project': 'Web Platform', 'completion': 75.0, 'phase': 'Development'},
    {'project': 'API Gateway', 'completion': 60.0, 'phase': 'Development'},
  ];
}

// Generate gauge data
List<Map<String, dynamic>> _generateGaugeData() {
  return [
    {'metric': 'CPU Usage', 'completion': 65.0, 'type': 'System'},
    {'metric': 'Memory', 'completion': 42.0, 'type': 'System'},
    {'metric': 'Network', 'completion': 78.0, 'type': 'System'},
    {'metric': 'Storage', 'completion': 35.0, 'type': 'System'},
  ];
}

// Generate concentric data
List<Map<String, dynamic>> _generateConcentricData() {
  return [
    {'system': 'Database', 'completion': 88.0, 'priority': 'High'},
    {'system': 'Cache', 'completion': 95.0, 'priority': 'High'},
    {'system': 'Queue', 'completion': 73.0, 'priority': 'Medium'},
  ];
}
