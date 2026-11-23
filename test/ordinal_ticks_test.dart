import 'package:cristalyse/cristalyse.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for #101: when an ordinal axis has more categories than
/// fit, the forced last label must not land right next to the previous label.
void main() {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<dynamic> ticksFor(List<dynamic> domain, double width) {
    final scale = OrdinalScale()
      ..domain = domain
      ..range = [0, width];
    return scale.getTicks();
  }

  /// Index gaps between consecutive ticks, e.g. [2, 2, 2, 1] for M1, M3, ...
  List<int> gaps(List<dynamic> domain, List<dynamic> ticks) => [
        for (var i = 1; i < ticks.length; i++)
          domain.indexOf(ticks[i]) - domain.indexOf(ticks[i - 1]),
      ];

  test('12 months at ~370px: last label does not crowd the previous one', () {
    final ticks = ticksFor(months, 370);

    expect(ticks.first, 'Jan');
    expect(ticks.last, 'Dec');
    expect(ticks, isNot(contains('Nov')),
        reason: 'Nov would sit right next to Dec and overlap it');

    final g = gaps(months, ticks);
    expect(g.last, greaterThanOrEqualTo(g.first),
        reason: 'the last gap must be at least one full step, got $g');
  });

  test('labels never get closer than one step, across sizes and widths', () {
    for (var length = 2; length <= 60; length++) {
      final domain = [for (var i = 0; i < length; i++) 'C$i'];
      for (var width = 80.0; width <= 1200; width += 37) {
        final ticks = ticksFor(domain, width);
        final context = 'length=$length width=$width ticks=$ticks';

        expect(ticks, isNotEmpty, reason: context);
        expect(ticks.first, domain.first, reason: context);
        expect(ticks.toSet().length, ticks.length,
            reason: 'no duplicate ticks: $context');

        final g = gaps(domain, ticks);
        if (g.length >= 2) {
          final step = g.first;
          expect(g.every((gap) => gap >= step), isTrue,
              reason: 'gaps $g must all be >= step: $context');
        }
      }
    }
  });

  test('shows every category when they all fit', () {
    expect(ticksFor(months, 2000), months);
  });

  test('still ends on the last category when it lines up with the step', () {
    // 13 categories, every 2nd shown: C0, C2, ..., C12 lands on the last one.
    final domain = [for (var i = 0; i < 13; i++) 'C$i'];
    final ticks = ticksFor(domain, 420);
    expect(ticks.last, 'C12');
  });
}
