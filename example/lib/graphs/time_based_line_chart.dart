import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeBasedLineChartWidget extends StatefulWidget {
  final ChartTheme currentTheme;
  final List<Map<String, dynamic>> data;
  final double sliderValue;

  const TimeBasedLineChartWidget({
    super.key,
    required this.currentTheme,
    required this.data,
    required this.sliderValue,
  });

  @override
  State<TimeBasedLineChartWidget> createState() =>
      _TimeBasedLineChartWidgetState();
}

class _TimeBasedLineChartWidgetState extends State<TimeBasedLineChartWidget> {
  bool _simpleLinear = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animated Line Chart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.currentTheme.axisColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child:
                CristalyseChart()
                    .data(_data)
                    .mapping(x: 'x', y: 'y')
                    .geomLine(
                      strokeWidth: 1.0 + widget.sliderValue * 9.0,
                      alpha: 0.9,
                    )
                    .scaleXContinuous(
                      title: 'Timestamp',
                      tickConfig: TickConfig(simpleLinear: _simpleLinear),
                      labels: (value) {
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          value.toInt(),
                        );
                        return DateFormat('MM/dd HH:mm:ss').format(date);
                      },
                    )
                    .scaleYContinuous(
                      title: 'Value (units)',
                      tickConfig: TickConfig(simpleLinear: _simpleLinear),
                    )
                    .theme(widget.currentTheme)
                    .build(),
          ),
          // toggle switch
          SwitchListTile(
            title: const Text('Use simple linear ticks'),
            value: _simpleLinear,
            onChanged: (value) {
              setState(() {
                _simpleLinear = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

// Keep the original function for backward compatibility
Widget buildTimeBasedLineChartTab(
  ChartTheme currentTheme,
  List<Map<String, dynamic>> data,
  double sliderValue,
) {
  return TimeBasedLineChartWidget(
    currentTheme: currentTheme,
    data: data,
    sliderValue: sliderValue,
  );
}

const _data = [
  {'x': 1761421958320.0, 'y': 4.900000095367432, 's': 'cooler.temp.avg'},
  {'x': 1761421959321.0, 'y': 5.0, 's': 'cooler.temp.avg'},
  {'x': 1761421960320.0, 'y': 5.0, 's': 'cooler.temp.avg'},
  {'x': 1761421961320.0, 'y': 4.900000095367432, 's': 'cooler.temp.avg'},
];
