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
      padding: EdgeInsets.all(60),
      axisTextStyle: TextStyle(fontSize: 12, color: Colors.black87),
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
      padding: EdgeInsets.all(60),
      axisTextStyle: TextStyle(fontSize: 12, color: Colors.white70),
    );
  }
}
