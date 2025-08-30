import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class ExportDemo extends StatefulWidget {
  final ChartTheme theme;
  final List<Color> colorPalette;

  const ExportDemo({
    super.key,
    required this.theme,
    required this.colorPalette,
  });

  @override
  State<ExportDemo> createState() => _ExportDemoState();
}

class _ExportDemoState extends State<ExportDemo> {
  late List<Map<String, dynamic>> _chartData;
  late CristalyseChart _chart;
  ExportResult? _lastExportResult;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _generateSampleData();
    _createChart();
  }

  void _generateSampleData() {
    _chartData = List.generate(12, (i) {
      final month = [
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
        'Dec'
      ][i];

      final revenue = 50 +
          i * 8 +
          math.sin(i * 0.5) * 15 +
          (math.Random().nextDouble() - 0.5) * 10;
      final users = 1000 +
          i * 120 +
          math.cos(i * 0.4) * 200 +
          (math.Random().nextDouble() - 0.5) * 100;

      return {
        'month': month,
        'revenue': revenue.round().toDouble(),
        'users': users.round().toDouble(),
      };
    });
  }

  void _createChart() {
    _chart = CristalyseChart()
        .data(_chartData)
        .mapping(x: 'month', y: 'revenue')
        .mappingY2('users')
        .geomBar(
          yAxis: YAxis.primary,
          alpha: 0.8,
          color: widget.colorPalette[0],
        )
        .geomLine(
          yAxis: YAxis.secondary,
          strokeWidth: 3.0,
          color: widget.colorPalette[1],
        )
        .geomPoint(
          yAxis: YAxis.secondary,
          size: 6.0,
          color: widget.colorPalette[1],
        )
        .scaleXOrdinal()
        .scaleYContinuous(min: 0)
        .scaleY2Continuous(min: 0)
        .theme(widget.theme)
        .animate(duration: const Duration(milliseconds: 1200))
        .interaction(
          tooltip: TooltipConfig(
            builder: (point) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(204),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    point.getDisplayValue('month'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Revenue: \$${point.getDisplayValue('revenue')}k',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Users: ${point.getDisplayValue('users')}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Future<void> _exportAsSvg() async {
    setState(() {
      _isExporting = true;
      _lastExportResult = null;
    });

    try {
      final result = await _chart.exportAsSvg(
        width: 1200,
        height: 800,
        filename:
            'revenue_users_chart_${DateTime.now().millisecondsSinceEpoch}',
      );

      setState(() {
        _lastExportResult = result;
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Chart exported successfully!\nSaved to: ${result.filePath}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chart Export Demo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.theme.axisColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Export your charts as scalable SVG vector graphics for reports and presentations.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Chart Container
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: widget.theme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.theme.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _chart.build(),
            ),
          ),

          const SizedBox(height: 24),

          // Export Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Export Buttons - SVG Only
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportAsSvg,
                      icon: const Icon(Icons.photo_filter),
                      label: const Text('Export as SVG'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.colorPalette[1],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  if (_isExporting) ...[
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Exporting chart...'),
                      ],
                    ),
                  ],

                  if (_lastExportResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withAlpha(77)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last Export Result:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Format: ${_lastExportResult!.format.name.toUpperCase()}'),
                          Text(
                              'Dimensions: ${_lastExportResult!.dimensions.width.toInt()} × ${_lastExportResult!.dimensions.height.toInt()}'),
                          Text(
                              'File Size: ${(_lastExportResult!.fileSizeBytes / 1024).toStringAsFixed(1)} KB'),
                          Text(
                            'Path: ${_lastExportResult!.filePath}',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Usage Examples
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usage Examples',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simple SVG Export:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'final result = await chart.exportAsSvg(\\n'
                          '  width: 1200,\\n'
                          '  height: 800,\\n'
                          '  filename: "my_chart",\\n'
                          ');',
                          style:
                              TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'SVG Benefits:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Scalable vector graphics\\n'
                          '• Small file sizes\\n'
                          '• Perfect for presentations\\n'
                          '• Editable in design software\\n'
                          '• Professional quality output',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
