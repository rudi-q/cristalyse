import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class DebugGradientExample extends StatelessWidget {
  const DebugGradientExample({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'quarter': 'Q1', 'revenue': 120},
      {'quarter': 'Q2', 'revenue': 150},
    ];

    final quarterlyGradients = {
      'Q1': const LinearGradient(
        colors: [Colors.red, Colors.blue],
      ),
      'Q2': const LinearGradient(
        colors: [Colors.green, Colors.yellow],
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
