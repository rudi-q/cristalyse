import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class DebugGradientExample extends StatelessWidget {
  const DebugGradientExample({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'quarter': 'Q1', 'revenue': 120},
      {'quarter': 'Q2', 'revenue': 150},
      {'quarter': 'Q3', 'revenue': 180},
      {'quarter': 'Q4', 'revenue': 200},
    ];

    final Map<String, Gradient> quarterlyGradients = {
      'Q1': const LinearGradient(
        colors: [Colors.red, Colors.blue],
      ),
      'Q2': const LinearGradient(
        colors: [Colors.green, Colors.yellow],
      ),
      'Q3': const LinearGradient(
        colors: [Colors.orange, Colors.purple],
      ),
      'Q4': const LinearGradient(
        colors: [Colors.cyan, Colors.pink],
      ),
    };

    final builtWidget = CristalyseChart()
        .data(data)
        .mapping(x: 'quarter', y: 'revenue', color: 'quarter')
        .geomBar()
        .customPalette(categoryGradients: quarterlyGradients)
        .build();

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Gradient')),
      body: Center(
        child: SizedBox(
          height: 400,
          child: builtWidget,
        ),
      ),
    );
  }
}
