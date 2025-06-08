import 'package:flutter/material.dart';

/// Base class for all scales
abstract class Scale {
  double scale(double value);
  List<double> getTicks(int count);
}

/// Linear scale for continuous data
class LinearScale extends Scale {
  List<double> domain = [0, 1];
  List<double> range = [0, 1];
  final double? min;
  final double? max;

  LinearScale({this.min, this.max});

  @override
  double scale(double value) {
    final domainSpan = domain[1] - domain[0];
    final rangeSpan = range[1] - range[0];
    if (domainSpan == 0) return range[0];
    return range[0] + (value - domain[0]) / domainSpan * rangeSpan;
  }

  @override
  List<double> getTicks(int count) {
    if (count <= 1) return [domain[0]];
    final step = (domain[1] - domain[0]) / (count - 1);
    return List.generate(count, (i) => domain[0] + i * step);
  }
}

/// Color scale for categorical or continuous color mapping
class ColorScale {
  final List<dynamic> values;
  final List<Color> colors;

  ColorScale({this.values = const [], this.colors = const []});

  Color scale(dynamic value) {
    if (values.isEmpty || colors.isEmpty) return Colors.blue;
    final index = values.indexOf(value);
    return index >= 0 ? colors[index % colors.length] : colors[0];
  }
}

/// Size scale for point size mapping
class SizeScale {
  final List<double> domain;
  final List<double> range;

  SizeScale({this.domain = const [0, 1], this.range = const [3, 10]});

  double scale(double value) {
    final domainSpan = domain[1] - domain[0];
    final rangeSpan = range[1] - range[0];
    if (domainSpan == 0) return range[0];
    return range[0] + (value - domain[0]) / domainSpan * rangeSpan;
  }
}
