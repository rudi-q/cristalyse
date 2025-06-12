import 'package:flutter/material.dart';

/// Visual theme configuration for charts
class ChartTheme {
  final Color backgroundColor;
  final Color plotBackgroundColor;
  final Color primaryColor;
  final Color borderColor;
  final Color gridColor;
  final Color axisColor;
  final double gridWidth;
  final double axisWidth;
  final double pointSizeDefault;
  final double pointSizeMin;
  final double pointSizeMax;
  final List<Color> colorPalette;
  final EdgeInsets padding;
  final TextStyle axisTextStyle;
  final TextStyle? axisLabelStyle;

  const ChartTheme({
    required this.backgroundColor,
    required this.plotBackgroundColor,
    required this.primaryColor,
    required this.borderColor,
    required this.gridColor,
    required this.axisColor,
    required this.gridWidth,
    required this.axisWidth,
    required this.pointSizeDefault,
    required this.pointSizeMin,
    required this.pointSizeMax,
    required this.colorPalette,
    required this.padding,
    required this.axisTextStyle,
    this.axisLabelStyle,
  });

  /// Default light theme
  static ChartTheme defaultTheme() {
    return const ChartTheme(
      backgroundColor: Colors.white,
      plotBackgroundColor: Colors.white,
      primaryColor: Colors.blue,
      borderColor: Colors.grey,
      gridColor: Color(0xFFE0E0E0),
      axisColor: Colors.black87,
      gridWidth: 0.5,
      axisWidth: 1.0,
      pointSizeDefault: 4.0,
      pointSizeMin: 2.0,
      pointSizeMax: 12.0,
      colorPalette: [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.brown,
        Colors.pink,
        Colors.grey,
        Colors.cyan,
        Colors.lime,
      ],
      padding: const EdgeInsets.only(left: 80, right: 20, top: 20, bottom: 40),
      axisTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
      axisLabelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
    );
  }

  /// Dark theme variant
  static ChartTheme darkTheme() {
    return const ChartTheme(
      backgroundColor: Color(0xFF121212),
      plotBackgroundColor: Color(0xFF1E1E1E),
      primaryColor: Colors.lightBlue,
      borderColor: Colors.grey,
      gridColor: Color(0xFF404040),
      axisColor: Colors.white70,
      gridWidth: 0.5,
      axisWidth: 1.0,
      pointSizeDefault: 4.0,
      pointSizeMin: 2.0,
      pointSizeMax: 12.0,
      colorPalette: [
        Colors.lightBlue,
        Colors.redAccent,
        Colors.lightGreen,
        Colors.orangeAccent,
        Colors.purpleAccent,
        Colors.brown,
        Colors.pinkAccent,
        Colors.grey,
        Colors.cyanAccent,
        Colors.limeAccent,
      ],
      padding: const EdgeInsets.only(left: 80, right: 20, top: 20, bottom: 40),
      axisTextStyle: const TextStyle(fontSize: 12, color: Colors.white70),
      axisLabelStyle: const TextStyle(fontSize: 12, color: Colors.white70),
    );
  }

  /// Solarized Light theme variant
  static ChartTheme solarizedLightTheme() {
    return const ChartTheme(
      backgroundColor: Color(0xFFfdf6e3), // base3
      plotBackgroundColor: Color(0xFFeee8d5), // base2
      primaryColor: Color(0xFF268bd2), // blue
      borderColor: Color(0xFF93a1a1), // base1
      gridColor: Color(0xFFeee8d5), // base2
      axisColor: Color(0xFF586e75), // base01
      gridWidth: 0.5,
      axisWidth: 1.0,
      pointSizeDefault: 5.0,
      pointSizeMin: 2.0,
      pointSizeMax: 12.0,
      colorPalette: [
        Color(0xFF268bd2), // blue
        Color(0xFFdc322f), // red
        Color(0xFF859900), // green
        Color(0xFFb58900), // yellow
        Color(0xFF6c71c4), // violet
        Color(0xFFd33682), // magenta
        Color(0xFF2aa198), // cyan
        Color(0xFFcb4b16), // orange
      ],
      padding: EdgeInsets.only(left: 80, right: 20, top: 20, bottom: 40),
      axisTextStyle: TextStyle(fontSize: 12, color: Color(0xFF586e75)), // base01
      axisLabelStyle: TextStyle(fontSize: 12, color: Color(0xFF586e75)), // base01
    );
  }

  /// Solarized Dark theme variant
  static ChartTheme solarizedDarkTheme() {
    return const ChartTheme(
      backgroundColor: Color(0xFF002b36), // base03
      plotBackgroundColor: Color(0xFF073642), // base02
      primaryColor: Color(0xFF268bd2), // blue
      borderColor: Color(0xFF586e75), // base01
      gridColor: Color(0xFF073642), // base02
      axisColor: Color(0xFF839496), // base0
      gridWidth: 0.5,
      axisWidth: 1.0,
      pointSizeDefault: 5.0,
      pointSizeMin: 2.0,
      pointSizeMax: 12.0,
      colorPalette: [
        Color(0xFF268bd2), // blue
        Color(0xFFdc322f), // red
        Color(0xFF859900), // green
        Color(0xFFb58900), // yellow
        Color(0xFF6c71c4), // violet
        Color(0xFFd33682), // magenta
        Color(0xFF2aa198), // cyan
        Color(0xFFcb4b16), // orange
      ],
      padding: EdgeInsets.only(left: 80, right: 20, top: 20, bottom: 40),
      axisTextStyle: TextStyle(fontSize: 12, color: Color(0xFF839496)), // base0
      axisLabelStyle: TextStyle(fontSize: 12, color: Color(0xFF839496)), // base0
    );
  }
}
