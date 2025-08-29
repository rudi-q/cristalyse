import 'package:flutter/material.dart';

import '../../../cristalyse.dart' show AnimatedCristalyseChartWidget;
import '../../widgets/animated_chart_painter.dart' show AnimatedChartPainter;

AnimatedChartPainter chartPainterAnimated(
    {required AnimatedCristalyseChartWidget widget,
    required BuildContext context,
    required Size size,
    required double animationProgress,
    List<double>? panXDomain,
    List<double>? panYDomain}) {
  return AnimatedChartPainter(
    data: widget.data,
    xColumn: widget.xColumn,
    yColumn: widget.yColumn,
    y2Column: widget.y2Column,
    colorColumn: widget.colorColumn,
    sizeColumn: widget.sizeColumn,
    pieValueColumn: widget.pieValueColumn,
    pieCategoryColumn: widget.pieCategoryColumn,
    heatMapXColumn: widget.heatMapXColumn,
    heatMapYColumn: widget.heatMapYColumn,
    heatMapValueColumn: widget.heatMapValueColumn,
    geometries: widget.geometries,
    xScale: widget.xScale,
    yScale: widget.yScale,
    y2Scale: widget.y2Scale,
    colorScale: widget.colorScale,
    sizeScale: widget.sizeScale,
    theme: widget.theme,
    animationProgress: animationProgress,
    coordFlipped: widget.coordFlipped,
    panXDomain: panXDomain,
    panYDomain: panYDomain,
  );
}
