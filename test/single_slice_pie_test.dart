import 'dart:ui' as ui;

import 'package:cristalyse/src/core/geometry.dart';
import 'package:cristalyse/src/themes/chart_theme.dart';
import 'package:cristalyse/src/widgets/animated_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for the single-slice pie/donut bug: a chart with one
/// category at 100% sweeps a full `2 * pi` at the final animation frame, and
/// `Path.arcTo` renders nothing for a full-circle sweep, so the slice used to
/// collapse to an empty path and disappear the instant the enter animation
/// completed.
///
/// The painter fills a solid background, so an opaque-pixel count can't tell a
/// drawn slice from an empty one. Instead we count pixels that differ from a
/// reference background pixel (one taken well outside the pie radius): a broken
/// build draws no slice, so almost every pixel matches the background; a correct
/// build fills the disc (pie) or ring (donut) with the slice colour, producing
/// tens of thousands of non-background pixels.
Future<int> _nonBackgroundPixelCount(CustomPainter painter, Size size) async {
  final width = size.width.toInt();
  final height = size.height.toInt();

  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  picture.dispose();

  final data = bytes!.buffer.asUint8List();

  // Reference background pixel: vertically centred, near the right edge — well
  // outside the pie/donut radius for a 400x400 canvas.
  final refIndex = (height ~/ 2 * width + (width - 20)) * 4;
  final r = data[refIndex], g = data[refIndex + 1];
  final b = data[refIndex + 2], a = data[refIndex + 3];

  var nonBackground = 0;
  for (var i = 0; i < data.length; i += 4) {
    if (data[i + 3] == 0) continue; // ignore fully transparent pixels
    if (data[i] == r && data[i + 1] == g && data[i + 2] == b && data[i + 3] == a) {
      continue; // ignore background-coloured pixels
    }
    nonBackground++;
  }
  return nonBackground;
}

void main() {
  const size = Size(400, 400);
  final singleSlice = <Map<String, dynamic>>[
    {'category': 'A', 'value': 100},
  ];

  AnimatedChartPainter buildPainter(double innerRadius) => AnimatedChartPainter(
        data: singleSlice,
        pieCategoryColumn: 'category',
        pieValueColumn: 'value',
        geometries: [PieGeometry(innerRadius: innerRadius)],
        theme: ChartTheme.defaultTheme(),
        animationProgress: 1.0,
      );

  testWidgets(
    'single-slice pie stays visible when the enter animation completes',
    (tester) async {
      await tester.runAsync(() async {
        final drawn = await _nonBackgroundPixelCount(buildPainter(0.0), size);
        expect(
          drawn,
          greaterThan(3000),
          reason: 'a single 100% pie slice must fill the disc at full animation '
              'progress, not collapse to an empty path',
        );
      });
    },
  );

  testWidgets(
    'single-slice donut stays visible when the enter animation completes',
    (tester) async {
      await tester.runAsync(() async {
        final drawn = await _nonBackgroundPixelCount(buildPainter(60.0), size);
        expect(
          drawn,
          greaterThan(3000),
          reason: 'a single 100% donut slice must fill the ring at full animation '
              'progress, not collapse to an empty path',
        );
      });
    },
  );
}
