import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class AreaChartExample extends StatefulWidget {
  final ChartTheme theme;
  final List<Color> colorPalette;

  const AreaChartExample({
    super.key,
    required this.theme,
    required this.colorPalette,
  });

  @override
  State<AreaChartExample> createState() => _AreaChartExampleState();
}

class _AreaChartExampleState extends State<AreaChartExample> {
  late List<Map<String, dynamic>> areaData;

  @override
  void initState() {
    super.initState();
    _generateAreaData();
  }

  void _generateAreaData() {
    // Generate realistic area chart data - Website Traffic
    areaData = List.generate(12, (i) {
      final month =
          [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ][i];

      // Simulate seasonal traffic with noise
      final baseTraffic = 5000 + i * 200;
      final seasonal = math.sin(i * 0.5) * 1000;
      final noise = (math.Random().nextDouble() - 0.5) * 500;
      final traffic = (baseTraffic + seasonal + noise).round();

      return {
        'month': month,
        'traffic': traffic.toDouble(),
        'mobile': (traffic * 0.6).round().toDouble(),
        'desktop': (traffic * 0.4).round().toDouble(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Area Chart - Website Traffic',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.theme.axisColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Showcasing area charts with smooth fills and stroke outlines',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Single Area Chart
          Container(
            height: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.theme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.theme.borderColor),
            ),
            child:
                CristalyseChart()
                    .data(areaData)
                    .mapping(x: 'month', y: 'traffic')
                    .geomArea(
                      strokeWidth: 2.0,
                      alpha: 0.3,
                      fillArea: true,
                      color: widget.colorPalette.first,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(min: 0)
                    .theme(
                      ChartTheme(
                        backgroundColor: widget.theme.backgroundColor,
                        primaryColor: widget.theme.primaryColor,
                        colorPalette: widget.colorPalette,
                        gridColor: widget.theme.gridColor,
                        borderColor: widget.theme.borderColor,
                        axisColor: widget.theme.axisColor,
                        axisLabelStyle: widget.theme.axisLabelStyle,
                        axisTextStyle: widget.theme.axisTextStyle,
                        pointSizeMin: widget.theme.pointSizeMin,
                        pointSizeMax: widget.theme.pointSizeMax,
                        pointSizeDefault: widget.theme.pointSizeDefault,
                        padding: widget.theme.padding,
                        plotBackgroundColor: widget.theme.plotBackgroundColor,
                        gridWidth: widget.theme.gridWidth,
                        axisWidth: widget.theme.axisWidth,
                      ),
                    )
                    .animate(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOutCubic,
                    )
                    .interaction(
                      tooltip: TooltipConfig(
                        builder:
                            (point) => Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${point.getDisplayValue('month')}: ${point.getDisplayValue('traffic')} visitors',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                      ),
                    )
                    .build(),
          ),

          const SizedBox(height: 24),

          // Multi-Series Stacked Areas
          Text(
            'Multi-Series Area Chart - Mobile vs Desktop',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.theme.axisColor,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            height: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.theme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.theme.borderColor),
            ),
            child:
                CristalyseChart()
                    .data(_createMultiSeriesData())
                    .mapping(x: 'month', y: 'visitors', color: 'platform')
                    .geomArea(strokeWidth: 1.5, alpha: 0.4, fillArea: true)
                    .scaleXOrdinal()
                    .scaleYContinuous(min: 0)
                    .theme(
                      ChartTheme(
                        backgroundColor: widget.theme.backgroundColor,
                        primaryColor: widget.theme.primaryColor,
                        colorPalette: widget.colorPalette,
                        gridColor: widget.theme.gridColor,
                        borderColor: widget.theme.borderColor,
                        axisColor: widget.theme.axisColor,
                        axisLabelStyle: widget.theme.axisLabelStyle,
                        axisTextStyle: widget.theme.axisTextStyle,
                        pointSizeMin: widget.theme.pointSizeMin,
                        pointSizeMax: widget.theme.pointSizeMax,
                        pointSizeDefault: widget.theme.pointSizeDefault,
                        padding: widget.theme.padding,
                        plotBackgroundColor: widget.theme.plotBackgroundColor,
                        gridWidth: widget.theme.gridWidth,
                        axisWidth: widget.theme.axisWidth,
                      ),
                    )
                    .legend(position: LegendPosition.topRight)
                    .animate(
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.easeInOutCubic,
                    )
                    .interaction(
                      tooltip: TooltipConfig(
                        builder:
                            (point) => Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${point.getDisplayValue('platform')} Traffic',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${point.getDisplayValue('month')}: ${point.getDisplayValue('visitors')} visitors',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                    )
                    .build(),
          ),

          const SizedBox(height: 24),

          // Combined Line + Area Chart
          const Text(
            'Combined Line + Area Chart',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          Container(
            height: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.theme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.theme.borderColor),
            ),
            child:
                CristalyseChart()
                    .data(areaData)
                    .mapping(x: 'month', y: 'traffic')
                    .geomArea(
                      strokeWidth: 0, // No stroke for background area
                      alpha: 0.2,
                      fillArea: true,
                      color: widget.colorPalette.first,
                    )
                    .geomLine(
                      strokeWidth: 3.0,
                      alpha: 1.0,
                      color: widget.colorPalette.first,
                    )
                    .geomPoint(
                      size: 6.0,
                      alpha: 1.0,
                      color: widget.colorPalette.first,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(min: 0)
                    .theme(
                      ChartTheme(
                        backgroundColor: widget.theme.backgroundColor,
                        primaryColor: widget.theme.primaryColor,
                        colorPalette: widget.colorPalette,
                        gridColor: widget.theme.gridColor,
                        borderColor: widget.theme.borderColor,
                        axisColor: widget.theme.axisColor,
                        axisLabelStyle: widget.theme.axisLabelStyle,
                        axisTextStyle: widget.theme.axisTextStyle,
                        pointSizeMin: widget.theme.pointSizeMin,
                        pointSizeMax: widget.theme.pointSizeMax,
                        pointSizeDefault: widget.theme.pointSizeDefault,
                        padding: widget.theme.padding,
                        plotBackgroundColor: widget.theme.plotBackgroundColor,
                        gridWidth: widget.theme.gridWidth,
                        axisWidth: widget.theme.axisWidth,
                      ),
                    )
                    .animate(
                      duration: const Duration(milliseconds: 1600),
                      curve: Curves.easeInOutCubic,
                    )
                    .interaction(
                      tooltip: TooltipConfig(
                        builder:
                            (point) => Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${point.getDisplayValue('month')}: ${point.getDisplayValue('traffic')} visitors',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                      ),
                    )
                    .build(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _createMultiSeriesData() {
    final result = <Map<String, dynamic>>[];

    for (final item in areaData) {
      // Add mobile data
      result.add({
        'month': item['month'],
        'visitors': item['mobile'],
        'platform': 'Mobile',
      });

      // Add desktop data
      result.add({
        'month': item['month'],
        'visitors': item['desktop'],
        'platform': 'Desktop',
      });
    }

    return result;
  }
}
