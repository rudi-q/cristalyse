import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class GradientBarExample extends StatelessWidget {
  const GradientBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final data = [
      {'quarter': 'Q1', 'revenue': 120},
      {'quarter': 'Q2', 'revenue': 150},
      {'quarter': 'Q3', 'revenue': 110},
      {'quarter': 'Q4', 'revenue': 180},
    ];

    // Define gradients for each quarter
    final Map<String, Gradient> quarterlyGradients = <String, Gradient>{
      'Q1': const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFF4FC3F7), // Light blue
          Color(0xFF1976D2), // Deep blue
        ],
      ),
      'Q2': const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFF81C784), // Light green
          Color(0xFF388E3C), // Deep green
        ],
      ),
      'Q3': const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFFFFB74D), // Light orange
          Color(0xFFF57C00), // Deep orange
        ],
      ),
      'Q4': const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFFE57373), // Light red
          Color(0xFFD32F2F), // Deep red
        ],
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradient Bar Chart Example'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quarterly Revenue with Gradient Bars',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Each bar features a gradient from light to dark, showing depth and visual appeal.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'quarter', y: 'revenue', color: 'quarter')
                  .geomBar(
                    width: 0.7,
                    borderRadius: BorderRadius.circular(8),
                  )
                  .scaleXOrdinal()
                  .scaleYContinuous(
                    min: 0,
                    labels: (value) => '\$${value.round()}k',
                  )
                  .customPalette(categoryGradients: quarterlyGradients)
                  .animate(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutBack,
                  )
                  .build(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Features demonstrated:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Linear gradients from bottom to top'),
                Text('• Custom gradient colors for each category'),
                Text('• Rounded corners with BorderRadius'),
                Text('• Smooth back-ease animation'),
                Text('• Custom Y-axis labels with currency formatting'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
