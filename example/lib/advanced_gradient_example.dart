import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class AdvancedGradientExample extends StatelessWidget {
  const AdvancedGradientExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for different chart types
    final salesData = [
      {'region': 'North', 'sales': 250, 'satisfaction': 4.2},
      {'region': 'South', 'sales': 180, 'satisfaction': 3.8},
      {'region': 'East', 'sales': 220, 'satisfaction': 4.5},
      {'region': 'West', 'sales': 190, 'satisfaction': 4.0},
    ];

    // Mixed gradient types
    final advancedGradients = {
      'North': const RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          Color(0xFF64B5F6), // Light blue center
          Color(0xFF1565C0), // Deep blue edges
        ],
      ),
      'South': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF176), // Light yellow
          Color(0xFFFF8F00), // Deep orange
        ],
      ),
      'East': const SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2 * 3.14159,
        colors: [
          Color(0xFF81C784), // Green
          Color(0xFF4CAF50), // Darker green
          Color(0xFF2E7D32), // Deep green
        ],
      ),
      'West': const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFFBA68C8), // Light purple
          Color(0xFF7B1FA2), // Deep purple
        ],
        stops: [0.0, 1.0],
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Gradient Examples'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Regional Sales with Advanced Gradients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Demonstrating different gradient types: Radial, Linear, Sweep, and custom stops.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Bar chart with mixed gradients
            SizedBox(
              height: 300,
              child: CristalyseChart()
                  .data(salesData)
                  .mapping(x: 'region', y: 'sales', color: 'region')
                  .geomBar(
                    width: 0.6,
                    borderRadius: BorderRadius.circular(12),
                    borderWidth: 2.0,
                  )
                  .scaleXOrdinal()
                  .scaleYContinuous(
                    min: 0,
                    labels: (value) => '${value.round()}k',
                  )
                  .theme(ChartTheme.defaultTheme().copyWith(
                    borderColor: Colors.white,
                  ))
                  .customPalette(categoryGradients: advancedGradients)
                  .animate(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.elasticOut,
                  )
                  .build(),
            ),

            const SizedBox(height: 32),

            const Text(
              'Customer Satisfaction Points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Point chart with gradients
            SizedBox(
              height: 250,
              child: CristalyseChart()
                  .data(salesData)
                  .mapping(x: 'region', y: 'satisfaction', color: 'region')
                  .geomPoint(
                    size: 15.0,
                    borderWidth: 3.0,
                  )
                  .scaleXOrdinal()
                  .scaleYContinuous(
                    min: 3.0,
                    max: 5.0,
                    labels: (value) => '${value.toStringAsFixed(1)} ★',
                  )
                  .theme(ChartTheme.defaultTheme().copyWith(
                    borderColor: Colors.grey[800]!,
                  ))
                  .customPalette(categoryGradients: advancedGradients)
                  .animate(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.bounceOut,
                  )
                  .build(),
            ),

            const SizedBox(height: 24),
            const Text(
              'Gradient Types Used:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• North: RadialGradient (center to edges)'),
                Text('• South: LinearGradient (diagonal)'),
                Text('• East: SweepGradient (circular sweep)'),
                Text('• West: LinearGradient (with custom stops)'),
                Text('• Works with both bars and points'),
                Text('• Borders and rounded corners supported'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
