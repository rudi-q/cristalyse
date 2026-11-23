import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cristalyse/cristalyse.dart';
import 'package:cristalyse/src/widgets/animated_chart_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Regression coverage for #96: grid lines can be hidden per direction, and a
/// transparent grid color is actually transparent (it used to render black).
///
/// The grid is drawn in pure red so its pixels can be told apart from the
/// white background, the black axes and the green data points.
void main() {
  const size = Size(400, 300);
  const gridRed = Color(0xFFFF0000);
  final data = [
    for (var i = 0; i < 10; i++) {'x': i.toDouble(), 'y': (i * 3).toDouble()},
  ];

  Future<Uint8List> render(ChartTheme theme) async {
    final painter = AnimatedChartPainter(
      data: data,
      xColumn: 'x',
      yColumn: 'y',
      geometries: [PointGeometry(color: const Color(0xFF00AA00))],
      theme: theme,
      animationProgress: 1.0,
    );
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), size);
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    picture.dispose();
    return bytes!.buffer.asUint8List();
  }

  /// Distinct x and y coordinates of reddish (grid) pixels.
  ({Set<int> xs, Set<int> ys}) gridPixels(Uint8List rgba) {
    final xs = <int>{}, ys = <int>{};
    final width = size.width.toInt();
    for (var i = 0; i < rgba.length; i += 4) {
      final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
      if (r > 200 && r - g > 40 && r - b > 40) {
        final p = i ~/ 4;
        xs.add(p % width);
        ys.add(p ~/ width);
      }
    }
    return (xs: xs, ys: ys);
  }

  ChartTheme theme({
    Color gridColor = gridRed,
    bool vertical = true,
    bool horizontal = true,
  }) =>
      ChartTheme.defaultTheme().copyWith(
        gridColor: gridColor,
        gridWidth: 1.0,
        showVerticalGridLines: vertical,
        showHorizontalGridLines: horizontal,
      );

  testWidgets('both grid directions are drawn by default', (tester) async {
    await tester.runAsync(() async {
      expect(ChartTheme.defaultTheme().showVerticalGridLines, isTrue);
      expect(ChartTheme.defaultTheme().showHorizontalGridLines, isTrue);

      final grid = gridPixels(await render(theme()));
      expect(grid.xs.length, greaterThan(100),
          reason: 'horizontal lines span x');
      expect(grid.ys.length, greaterThan(100), reason: 'vertical lines span y');
    });
  });

  testWidgets('hiding horizontal lines keeps only vertical ones',
      (tester) async {
    await tester.runAsync(() async {
      final grid = gridPixels(await render(theme(horizontal: false)));
      expect(grid.ys.length, greaterThan(100), reason: 'vertical lines remain');
      expect(grid.xs.length, lessThan(40),
          reason: 'only a few x positions (the vertical lines), got '
              '${grid.xs.length}');
    });
  });

  testWidgets('hiding vertical lines keeps only horizontal ones',
      (tester) async {
    await tester.runAsync(() async {
      final grid = gridPixels(await render(theme(vertical: false)));
      expect(grid.xs.length, greaterThan(100),
          reason: 'horizontal lines remain');
      expect(grid.ys.length, lessThan(40),
          reason: 'only a few y positions (the horizontal lines), got '
              '${grid.ys.length}');
    });
  });

  testWidgets('hiding both removes the grid entirely', (tester) async {
    await tester.runAsync(() async {
      final grid =
          gridPixels(await render(theme(vertical: false, horizontal: false)));
      expect(grid.xs, isEmpty);
    });
  });

  testWidgets('a transparent grid color draws nothing', (tester) async {
    await tester.runAsync(() async {
      final transparent =
          await render(theme(gridColor: const Color(0x00000000)));
      final noGrid = await render(theme(vertical: false, horizontal: false));
      expect(transparent, equals(noGrid),
          reason: 'Colors.transparent must not render as black lines');
    });
  });

  test('copyWith keeps grid visibility unless overridden', () {
    final hidden = ChartTheme.defaultTheme()
        .copyWith(showVerticalGridLines: false, showHorizontalGridLines: false);
    final copy = hidden.copyWith(gridWidth: 2);
    expect(copy.showVerticalGridLines, isFalse);
    expect(copy.showHorizontalGridLines, isFalse);
  });
}
