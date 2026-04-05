import 'package:flutter/material.dart';

import 'chart_interactions.dart';

/// Crosshair overlay widget for axis-based tooltips
///
/// Displays a vertical line indicator that follows the cursor's X position
/// when tooltips are in axis mode.
class CrosshairOverlay extends StatelessWidget {
  final Offset? position;
  final Rect plotArea;
  final TooltipConfig config;

  const CrosshairOverlay({
    super.key,
    required this.position,
    required this.plotArea,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if disabled or no position
    if (!config.showCrosshair || position == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _CrosshairPainter(
        position: position!,
        plotArea: plotArea,
        color: config.crosshairColor ?? Colors.grey.shade400,
        width: config.crosshairWidth,
        style: config.crosshairStyle,
      ),
    );
  }
}

/// Custom painter for drawing the crosshair line
class _CrosshairPainter extends CustomPainter {
  final Offset position;
  final Rect plotArea;
  final Color color;
  final double width;
  final StrokeStyle style;

  _CrosshairPainter({
    required this.position,
    required this.plotArea,
    required this.color,
    required this.width,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Only draw if position is within plot area
    if (!plotArea.contains(position)) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    // Apply line style
    switch (style) {
      case StrokeStyle.dashed:
        _drawDashedLine(canvas, paint);
        break;
      case StrokeStyle.dotted:
        _drawDottedLine(canvas, paint);
        break;
      case StrokeStyle.solid:
        _drawSolidLine(canvas, paint);
        break;
    }
  }

  void _drawSolidLine(Canvas canvas, Paint paint) {
    canvas.drawLine(
      Offset(position.dx, plotArea.top),
      Offset(position.dx, plotArea.bottom),
      paint,
    );
  }

  void _drawDashedLine(Canvas canvas, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startY = plotArea.top;

    while (startY < plotArea.bottom) {
      canvas.drawLine(
        Offset(position.dx, startY),
        Offset(position.dx, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  void _drawDottedLine(Canvas canvas, Paint paint) {
    const dotSpacing = 4.0;
    double startY = plotArea.top;

    paint.strokeCap = StrokeCap.round;
    paint.strokeWidth = width * 2; // Make dots more visible

    while (startY < plotArea.bottom) {
      canvas.drawCircle(
        Offset(position.dx, startY),
        width / 2,
        paint,
      );
      startY += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(_CrosshairPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.style != style;
  }
}
