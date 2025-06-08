import 'package:flutter/material.dart';
import 'package:cristalyse/cristalyse.dart';

void main() {
  runApp(CristalyseExampleApp());
}

class CristalyseExampleApp extends StatelessWidget {
  const CristalyseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cristalyse Examples',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScatterPlotExample(),
    );
  }
}

class ScatterPlotExample extends StatelessWidget {
  const ScatterPlotExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample dataset
    final data = List.generate(50, (i) {
      final x = i.toDouble();
      final y = x * 0.5 + (i % 3) * 2 + (i % 7) * 0.3;
      final category = ['Alpha', 'Beta', 'Gamma'][i % 3];
      return {'x': x, 'y': y, 'category': category, 'size': (i % 5) + 1.0};
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Cristalyse Scatter Plot'),
        actions: [
          IconButton(
            icon: Icon(Icons.dark_mode),
            onPressed: () {
              // Toggle theme example
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Scatter Plot',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y', color: 'category')
                  .geom_point(size: 5.0, alpha: 0.7)
                  .scale_x_continuous(min: 0, max: 50)
                  .scale_y_continuous()
                  .theme(ChartTheme.defaultTheme())
                  .build(),
            ),
            SizedBox(height: 32),
            Text(
              'Dark Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: CristalyseChart()
                  .data(data.take(20).toList())
                  .mapping(x: 'x', y: 'y', color: 'category', size: 'size')
                  .geom_point(alpha: 0.8)
                  .theme(ChartTheme.darkTheme())
                  .build(),
            ),
          ],
        ),
      ),
    );
  }
}