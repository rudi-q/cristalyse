import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildPanExampleTab(ChartTheme theme, double sliderValue) {
  return _PanExampleWidget(theme: theme, sliderValue: sliderValue);
}

class _PanExampleWidget extends StatefulWidget {
  final ChartTheme theme;
  final double sliderValue;

  const _PanExampleWidget({
    required this.theme,
    required this.sliderValue,
  });

  @override
  State<_PanExampleWidget> createState() => _PanExampleWidgetState();
}

class _PanExampleWidgetState extends State<_PanExampleWidget> {
  List<Map<String, dynamic>> currentData = [];
  double? visibleMinX;
  double? visibleMaxX;
  String panStatus = "Ready to pan";
  int totalPanEvents = 0;
  int activeDataPoints = 0;

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
        'y': 50 +
            math.sin(i * 0.02) * 30 +
            (math.Random().nextDouble() - 0.5) * 20,
        'category': 'Series${i % 3 + 1}',
      };
    });
    activeDataPoints = currentData.length;
  }

  void _handlePanUpdate(PanInfo info) {
    setState(() {
      visibleMinX = info.visibleMinX;
      visibleMaxX = info.visibleMaxX;
      totalPanEvents++;
      panStatus =
          "Range: ${info.visibleMinX?.toStringAsFixed(1)} - ${info.visibleMaxX?.toStringAsFixed(1)}";
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
      panStatus = "Pan completed";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Visible Range Display Card - Compact Version
        if (visibleMinX != null && visibleMaxX != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  Theme.of(context).primaryColor.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Range: ${visibleMinX!.toStringAsFixed(1)} → ${visibleMaxX!.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Width: ${(visibleMaxX! - visibleMinX!).toStringAsFixed(1)} • Events: $totalPanEvents',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Chart Container - Expanded to fill remaining space
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.theme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CristalyseChart()
                  .data(currentData)
                  .mapping(x: 'x', y: 'y', color: 'category')
                  .geomLine(
                    strokeWidth: 1.0 + widget.sliderValue * 4.0,
                    alpha: 0.8,
                  )
                  .geomPoint(
                    size: 2.0 + widget.sliderValue * 4.0,
                    alpha: 0.7,
                  )
                  .scaleXContinuous()
                  .scaleYContinuous()
                  .interaction(
                    pan: PanConfig(
                      enabled: true,
                      onPanStart: _handlePanStart,
                      onPanUpdate: _handlePanUpdate,
                      onPanEnd: _handlePanEnd,
                      throttle: const Duration(milliseconds: 50),
                    ),
                  )
                  .theme(widget.theme)
                  .build(),
            ),
          ),
        ),
      ],
    );
  }
}

// Keep the old class for backward compatibility if needed
class PanExamplePage extends StatelessWidget {
  const PanExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildPanExampleTab(ChartTheme.defaultTheme(), 0.5);
  }
}
