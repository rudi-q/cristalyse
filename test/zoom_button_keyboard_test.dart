import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Regression coverage for the zoom buttons: they must stay reachable and
/// usable from the keyboard (Tab to focus, Enter/Space to press), not only
/// by pointer taps.
void main() {
  final data = [
    for (var i = 0; i < 10; i++) {'x': i.toDouble(), 'y': (i * i).toDouble()},
  ];

  Future<List<ZoomInfo>> pumpZoomChart(WidgetTester tester) async {
    final events = <ZoomInfo>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .scaleXContinuous()
                .scaleYContinuous()
                .onZoom(events.add)
                .build(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return events;
  }

  testWidgets('zoom in button can be focused with Tab and pressed with Enter',
      (tester) async {
    final events = await pumpZoomChart(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(events, isNotEmpty, reason: 'Enter on the focused button zooms');
    expect(events.last.scaleX, greaterThan(1.0));
  });

  testWidgets('zoom in button can be pressed with Space', (tester) async {
    final events = await pumpZoomChart(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(events, isNotEmpty, reason: 'Space on the focused button zooms');
    expect(events.last.scaleX, greaterThan(1.0));
  });

  testWidgets('zoom buttons still respond to pointer taps', (tester) async {
    final events = await pumpZoomChart(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(events, isNotEmpty);
    expect(events.last.scaleX, greaterThan(1.0));
  });
}
