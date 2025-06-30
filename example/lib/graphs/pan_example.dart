import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class PanExamplePage extends StatefulWidget {
  const PanExamplePage({super.key});

  @override
  State<PanExamplePage> createState() => _PanExamplePageState();
}

class _PanExamplePageState extends State<PanExamplePage> {
  List<Map<String, dynamic>> currentData = [];
  double? visibleMinX;
  double? visibleMaxX;
  String panStatus = "Ready to pan";
  
  @override
  void initState() {
    super.initState();
    _generateInitialData();
  }
  
  void _generateInitialData() {
    // Generate initial dataset with 1000 points
    currentData = List.generate(1000, (i) {
      return {
        'x': i.toDouble(),
        'y': 50 + math.sin(i * 0.02) * 30 + (math.Random().nextDouble() - 0.5) * 20,
        'category': 'Series${i % 3 + 1}',
      };
    });
  }
  
  void _handlePanUpdate(PanInfo info) {
    setState(() {
      visibleMinX = info.visibleMinX;
      visibleMaxX = info.visibleMaxX;
      panStatus = "Panning: X range ${info.visibleMinX?.toStringAsFixed(1)} - ${info.visibleMaxX?.toStringAsFixed(1)}";
    });
    
    // Simulate fetching data for visible range
    debugPrint('Visible X range: ${info.visibleMinX} - ${info.visibleMaxX}');
    
    // In a real app, you might do something like:
    // fetchDataForRange(info.visibleMinX, info.visibleMaxX);
  }
  
  void _handlePanStart(PanInfo info) {
    setState(() {
      panStatus = "Pan started";
    });
  }
  
  void _handlePanEnd(PanInfo info) {
    setState(() {
      panStatus = "Pan ended - Final range: ${info.visibleMinX?.toStringAsFixed(1)} - ${info.visibleMaxX?.toStringAsFixed(1)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Panning Example'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pan Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    panStatus,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (visibleMinX != null && visibleMaxX != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Visible Range: ${visibleMinX!.toStringAsFixed(1)} to ${visibleMaxX!.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Range Width: ${(visibleMaxX! - visibleMinX!).toStringAsFixed(1)} units',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 How to Pan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Drag horizontally across the chart to pan'),
                  Text('• Watch the visible X range update in real-time'),
                  Text('• In a real app, you could fetch new data during panning'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Chart
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CristalyseChart()
                      .data(currentData)
                      .mapping(x: 'x', y: 'y', color: 'category')
                      .geomLine(strokeWidth: 2.0, alpha: 0.8)
                      .geomPoint(size: 3.0, alpha: 0.7)
                      .scaleXContinuous()
                      .scaleYContinuous()
                      .interaction(
                        pan: PanConfig(
                          enabled: true,
                          onPanStart: _handlePanStart,
                          onPanUpdate: _handlePanUpdate,
                          onPanEnd: _handlePanEnd,
                          throttle: const Duration(milliseconds: 50), // Fast updates
                        ),
                        tooltip: TooltipConfig(
                          builder: (point) => Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'X: ${point.getDisplayValue('x')}, Y: ${point.getDisplayValue('y')}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      )
                      .theme(ChartTheme.defaultTheme())
                      .build(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // API Example
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💻 Code Example:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '''CristalyseChart()
  .data(myData)
  .mapping(x: 'time', y: 'value')
  .geomLine()
  .interaction(
    pan: PanConfig(
      enabled: true,
      onPanUpdate: (info) {
        // Fetch data for visible range
        fetchData(info.visibleMinX, info.visibleMaxX);
      },
      throttle: Duration(milliseconds: 100),
    ),
  )
  .build()''',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
