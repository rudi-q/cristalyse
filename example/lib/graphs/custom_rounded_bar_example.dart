import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class CustomRoundedBarExample extends StatelessWidget {
  const CustomRoundedBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'category': 'A', 'value': 25},
      {'category': 'B', 'value': -15},
      {'category': 'C', 'value': 40},
      {'category': 'D', 'value': -30},
      {'category': 'E', 'value': 10},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Rounded Bars')),
      body: Center(
        child: SizedBox(
          height: 400,
          child:
              CristalyseChart()
                  .data(data)
                  .mapping(x: 'category', y: 'value')
                  .geomBar(
                    color: Colors.blueAccent,
                    width: 0.6,
                    borderRadius: BorderRadius.circular(15),
                    roundOutwardEdges: true, // This is the new feature
                  )
                  .build(),
        ),
      ),
    );
  }
}
