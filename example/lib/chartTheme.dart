import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

// Extension to add copyWith method to ChartTheme

extension ChartThemeExtension on ChartTheme {
  ChartTheme copyWith({
    Color? backgroundColor,
    Color? plotBackgroundColor,
    Color? primaryColor,
    Color? borderColor,
    Color? gridColor,
    Color? axisColor,
    double? gridWidth,
    double? axisWidth,
    double? pointSizeDefault,
    double? pointSizeMin,
    double? pointSizeMax,
    List<Color>? colorPalette,
    EdgeInsets? padding,
    TextStyle? axisTextStyle,
    TextStyle? axisLabelStyle,
  }) {
    return ChartTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      plotBackgroundColor: plotBackgroundColor ?? this.plotBackgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      borderColor: borderColor ?? this.borderColor,
      gridColor: gridColor ?? this.gridColor,
      axisColor: axisColor ?? this.axisColor,
      gridWidth: gridWidth ?? this.gridWidth,
      axisWidth: axisWidth ?? this.axisWidth,
      pointSizeDefault: pointSizeDefault ?? this.pointSizeDefault,
      pointSizeMin: pointSizeMin ?? this.pointSizeMin,
      pointSizeMax: pointSizeMax ?? this.pointSizeMax,
      colorPalette: colorPalette ?? this.colorPalette,
      padding: padding ?? this.padding,
      axisTextStyle: axisTextStyle ?? this.axisTextStyle,
      axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
    );
  }
}