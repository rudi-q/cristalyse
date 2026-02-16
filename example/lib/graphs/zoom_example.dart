import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildZoomExampleTab(ChartTheme theme, double sliderValue) {
  return _ZoomExampleWidget(theme: theme, sliderValue: sliderValue);
}

class _ZoomExampleWidget extends StatefulWidget {
  const _ZoomExampleWidget({required this.theme, required this.sliderValue});

  final ChartTheme theme;
  final double sliderValue;

  @override
  State<_ZoomExampleWidget> createState() => _ZoomExampleWidgetState();
}

class _ZoomExampleWidgetState extends State<_ZoomExampleWidget> {
  late final List<Map<String, dynamic>> _data;
  final ValueNotifier<_ZoomUiState> _zoomUiNotifier = ValueNotifier(
    const _ZoomUiState(),
  );
  ZoomAxis _axis = ZoomAxis.x;
  bool _showButtons = true;
  double _wheelSensitivity = 0.0015;
  double _buttonStep = 1.35;

  @override
  void initState() {
    super.initState();
    _data = _generateData();
  }

  @override
  void dispose() {
    _zoomUiNotifier.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _generateData() {
    final rand = math.Random(42);
    final regions = ['North America', 'EMEA', 'APAC'];
    final offsets = [18.0, -6.0, 10.0];
    final data = <Map<String, dynamic>>[];

    for (var day = 0; day < 360; day++) {
      final base = 120 + math.sin(day / 12) * 14 + math.cos(day / 30) * 9;
      final trend = day * 0.22;
      for (var i = 0; i < regions.length; i++) {
        final noise = (rand.nextDouble() - 0.5) * 6;
        data.add({
          'day': day.toDouble(),
          'revenue': base + offsets[i] + trend + noise,
          'region': regions[i],
        });
      }
    }
    return data;
  }

  void _handleZoomEvent(ZoomInfo info) {
    final previous = _zoomUiNotifier.value;
    String status;
    switch (info.state) {
      case ZoomState.start:
        status = 'Zoom activated';
        break;
      case ZoomState.update:
        status = 'Zooming…';
        break;
      case ZoomState.end:
        status = 'Zoom settled';
        break;
    }
    _zoomUiNotifier.value = previous.copyWith(
      info: info,
      status: status,
      events: previous.events + 1,
    );
  }

  String _formatRange(double? min, double? max) {
    if (min == null || max == null) {
      return 'Full domain';
    }
    return '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)}';
  }

  String _formatScale(ZoomInfo? info) {
    final scaleLabel = (info?.scaleX ?? 1).toStringAsFixed(2);
    final scaleY = info?.scaleY;
    if (scaleY == null) {
      return '${scaleLabel}x';
    }
    return '${scaleLabel}x / ${scaleY.toStringAsFixed(2)}x';
  }

  Widget _buildInfoCards() {
    return ValueListenableBuilder<_ZoomUiState>(
      valueListenable: _zoomUiNotifier,
      builder: (context, state, _) {
        final info = state.info;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoTile(
              icon: Icons.pinch,
              label: 'Status',
              value: state.status,
              accent: Colors.indigo,
            ),
            _InfoTile(
              icon: Icons.timeline,
              label: 'X Range',
              value: _formatRange(info?.visibleMinX, info?.visibleMaxX),
              accent: Colors.blue,
            ),
            _InfoTile(
              icon: Icons.auto_graph,
              label: 'Y Range',
              value: _formatRange(info?.visibleMinY, info?.visibleMaxY),
              accent: Colors.green,
            ),
            _InfoTile(
              icon: Icons.analytics_outlined,
              label: 'Scale',
              value: _formatScale(info),
              accent: Colors.orange,
            ),
            _InfoTile(
              icon: Icons.ssid_chart,
              label: 'Events',
              value: state.events.toString(),
              accent: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(ThemeData themeData) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeData.dividerColor.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ZoomAxis>(
                  decoration: const InputDecoration(
                    labelText: 'Zoom axes',
                    isDense: true,
                  ),
                  initialValue: _axis,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _axis = value);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ZoomAxis.x,
                      child: Text('X axis (default)'),
                    ),
                    DropdownMenuItem(value: ZoomAxis.y, child: Text('Y axis')),
                    DropdownMenuItem(
                      value: ZoomAxis.both,
                      child: Text('Both axes'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Button step ${_buttonStep.toStringAsFixed(2)}x',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      min: 1.1,
                      max: 1.8,
                      divisions: 7,
                      value: _buttonStep,
                      label: '${_buttonStep.toStringAsFixed(2)}x',
                      onChanged: (value) => setState(() => _buttonStep = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Scroll sensitivity ${(1000 * _wheelSensitivity).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: _wheelSensitivity,
            min: 0.0005,
            max: 0.0035,
            divisions: 6,
            label: _wheelSensitivity.toStringAsFixed(4),
            onChanged: (value) => setState(() => _wheelSensitivity = value),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Switch(
                value: _showButtons,
                onChanged: (value) => setState(() => _showButtons = value),
              ),
              const Text('Show floating zoom buttons'),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _InstructionChip(icon: Icons.touch_app, label: 'Pinch to zoom'),
              _InstructionChip(
                icon: Icons.mouse,
                label: 'Scroll wheel supported',
              ),
              _InstructionChip(
                icon: Icons.add_circle_outline,
                label: 'Use the +/- buttons',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing =
            constraints.maxHeight.isFinite && constraints.maxHeight < 520
                ? 10.0
                : 16.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: EdgeInsets.only(bottom: spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCards(),
                    SizedBox(height: spacing),
                    _buildControls(themeData),
                  ],
                ),
              ),
            ),
            Expanded(flex: 3, child: _buildChart()),
          ],
        );
      },
    );
  }

  Widget _buildChart() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            CristalyseChart()
                .data(_data)
                .mapping(x: 'day', y: 'revenue', color: 'region')
                .geomLine(strokeWidth: 1.5 + widget.sliderValue * 3, alpha: 0.9)
                .geomPoint(size: 2.0 + widget.sliderValue * 3, alpha: 0.6)
                .scaleXContinuous()
                .scaleYContinuous()
                .legend(
                  position: LegendPosition.bottom,
                  orientation: LegendOrientation.horizontal,
                )
                .interaction(
                  tooltip: TooltipConfig(
                    builder: DefaultTooltips.multi({
                      'day': 'Day',
                      'region': 'Region',
                      'revenue': 'Revenue',
                    }),
                  ),
                  hover: HoverConfig(hitTestRadius: 18),
                  zoom: ZoomConfig(
                    enabled: true,
                    axes: _axis,
                    maxScale: 16,
                    minScale: 1,
                    wheelSensitivity: _wheelSensitivity,
                    buttonStep: _buttonStep,
                    showButtons: _showButtons,
                    buttonPadding: const EdgeInsets.all(20),
                    buttonAlignment: Alignment.bottomRight,
                    onZoomStart: _handleZoomEvent,
                    onZoomUpdate: _handleZoomEvent,
                    onZoomEnd: _handleZoomEvent,
                  ),
                  pan: PanConfig(
                    enabled: true,
                    updateXDomain:
                        _axis == ZoomAxis.x || _axis == ZoomAxis.both,
                    updateYDomain:
                        _axis == ZoomAxis.y || _axis == ZoomAxis.both,
                    throttle: const Duration(milliseconds: 32),
                  ),
                )
                .theme(widget.theme)
                .animate(duration: const Duration(milliseconds: 450))
                .build(),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: accent.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: accent.withValues(alpha: 0.95),
                      fontWeight: FontWeight.bold,
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

class _InstructionChip extends StatelessWidget {
  const _InstructionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      side: BorderSide(color: Theme.of(context).dividerColor),
    );
  }
}

class _ZoomUiState {
  final ZoomInfo? info;
  final String status;
  final int events;

  const _ZoomUiState({
    this.info,
    this.status = 'Pinch, scroll, or tap the buttons to zoom',
    this.events = 0,
  });

  _ZoomUiState copyWith({ZoomInfo? info, String? status, int? events}) {
    return _ZoomUiState(
      info: info ?? this.info,
      status: status ?? this.status,
      events: events ?? this.events,
    );
  }
}
