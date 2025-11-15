import 'dart:ui';

import 'package:flutter/material.dart';

import 'geometry.dart';
import 'render_models.dart';
import 'scale.dart';
import 'util/helper.dart';
import '../themes/chart_theme.dart';

/// Calculates chart geometry (positions, sizes, colors) independently of rendering.
///
/// This class extracts all geometric calculations from the rendering layer,
/// enabling:
/// - Shared calculation logic between Canvas and SVG renderers
/// - Unit testing of layout without rendering
/// - Cleaner separation of concerns
///
/// All methods return full geometry with no animation applied. Animation
/// is the responsibility of the rendering layer.
class GeometryCalculator {
  final List<Map<String, dynamic>> data;
  final String? xColumn;
  final String? yColumn;
  final String? colorColumn;
  final String? sizeColumn;
  final ChartTheme theme;
  final bool coordFlipped;

  const GeometryCalculator({
    required this.data,
    this.xColumn,
    this.yColumn,
    this.colorColumn,
    this.sizeColumn,
    required this.theme,
    this.coordFlipped = false,
  });

  /// Calculates geometry for a single bar.
  ///
  /// Extracted from AnimatedChartPainter._drawSingleBar (lines 1003-1120).
  ///
  /// Returns null if the bar cannot be drawn (invalid scales, empty rect, etc.).
  BarRenderData? calculateSingleBar(
    dynamic xValForPosition,
    double yValForBar,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    BarGeometry geometry,
    Map<String, dynamic> dataPoint,
    Rect plotArea, {
    double? customX,
    double? customWidth,
    double yStackOffset = 0,
  }) {
    // Priority: geometry.color > colorScale > theme fallback
    final dynamic colorOrGradient;
    if (geometry.color != null) {
      colorOrGradient = geometry.color!;
    } else if (colorColumn != null) {
      colorOrGradient = colorScale.scale(dataPoint[colorColumn]);
    } else {
      colorOrGradient = theme.colorPalette.isNotEmpty
          ? theme.colorPalette.first
          : theme.primaryColor;
    }

    Rect barRect;

    if (coordFlipped) {
      // Horizontal bars
      if (yScale is! OrdinalScale || xScale is! LinearScale) {
        return null;
      }

      final yPos = plotArea.top + yScale.scale(xValForPosition);
      final barHeight = yScale.bandWidth * geometry.width;
      final yCenter = yPos + (yScale.bandWidth * (1 - geometry.width)) / 2;

      final xStart = plotArea.left + xScale.scale(yStackOffset);
      final xEnd = plotArea.left + xScale.scale(yValForBar + yStackOffset);
      final barWidth = xEnd - xStart;

      barRect = Rect.fromLTWH(
        xStart,
        yCenter,
        barWidth.isFinite ? barWidth : 0,
        barHeight.isFinite ? barHeight : 0,
      );
    } else {
      // Vertical bars
      if (xScale is! OrdinalScale || yScale is! LinearScale) {
        return null;
      }

      double xPos;
      double barWidth;

      if (customX != null && customWidth != null) {
        // For grouped bars - use provided position and width
        xPos = customX;
        barWidth = customWidth;
      } else {
        // For simple/stacked bars - center within band
        xPos = plotArea.left + xScale.scale(xValForPosition);
        barWidth = xScale.bandWidth * geometry.width;
        xPos += (xScale.bandWidth * (1 - geometry.width)) / 2;
      }

      final yStart = plotArea.top + yScale.scale(yStackOffset);
      final yEnd = plotArea.top + yScale.scale(yValForBar + yStackOffset);
      final barHeight = yStart - yEnd;

      barRect = Rect.fromLTWH(
        xPos.isFinite ? xPos : 0,
        yEnd, // Full height, no animation
        barWidth.isFinite ? barWidth : 0,
        barHeight.isFinite ? barHeight : 0,
      );
    }

    if (!barRect.isFinite || barRect.isEmpty) {
      return null;
    }

    return BarRenderData(
      rect: barRect,
      colorOrGradient: colorOrGradient,
      alpha: geometry.alpha,
      borderRadius: geometry.borderRadius,
      borderWidth: geometry.borderWidth,
      borderColor: geometry.borderWidth > 0 ? theme.borderColor : null,
      dataPoint: dataPoint,
    );
  }

  /// Calculates geometry for simple (non-grouped, non-stacked) bars.
  ///
  /// Extracted from AnimatedChartPainter._drawSimpleBars (lines 791-831).
  List<BarRenderData> calculateSimpleBars(
    BarGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    Rect plotArea,
    String? yCol,
  ) {
    final bars = <BarRenderData>[];

    for (final point in data) {
      final x = point[xColumn];
      final y = getNumericValue(point[yCol]);

      if (y == null || !y.isFinite) continue;

      final bar = calculateSingleBar(
        x,
        y,
        xScale,
        yScale,
        colorScale,
        geometry,
        point,
        plotArea,
      );

      if (bar != null) {
        bars.add(bar);
      }
    }

    return bars;
  }

  /// Calculates geometry for grouped bars.
  ///
  /// Extracted from AnimatedChartPainter._drawGroupedBars (lines 833-921).
  List<BarRenderData> calculateGroupedBars(
    BarGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    Rect plotArea,
    String? yCol,
  ) {
    if (colorColumn == null) return [];

    final bars = <BarRenderData>[];

    // Group data by X value
    final groups = <dynamic, Map<dynamic, double>>{};
    for (final point in data) {
      final x = point[xColumn];
      final y = getNumericValue(point[yCol]);
      final color = point[colorColumn];

      if (y == null || !y.isFinite) continue;

      groups.putIfAbsent(x, () => {})[color] = y;
    }

    // Get all unique colors to determine bar count per group
    final allColors = data.map((d) => d[colorColumn]).toSet().toList();
    final colorCount = allColors.length;

    for (final groupEntry in groups.entries) {
      final x = groupEntry.key;
      final colorValues = groupEntry.value;

      // Calculate group layout
      double basePosition;
      double totalGroupWidth;

      if (xScale is OrdinalScale) {
        final centerPos = plotArea.left + xScale.bandCenter(x);
        totalGroupWidth = xScale.bandWidth * geometry.width;
        basePosition = centerPos - (totalGroupWidth / 2);
      } else {
        basePosition = plotArea.left + xScale.scale(x) - 20;
        totalGroupWidth = 40 * geometry.width;
      }

      final barWidth = totalGroupWidth / colorCount;

      // Create bars for each color in the group
      int colorIndex = 0;
      for (final color in allColors) {
        final value = colorValues[color];
        if (value == null) {
          colorIndex++;
          continue;
        }

        final barX = basePosition + colorIndex * barWidth;

        final bar = calculateSingleBar(
          x,
          value,
          xScale,
          yScale,
          colorScale,
          geometry,
          {colorColumn!: color},
          plotArea,
          customX: barX,
          customWidth: barWidth,
        );

        if (bar != null) {
          bars.add(bar);
        }

        colorIndex++;
      }
    }

    return bars;
  }

  /// Calculates geometry for stacked bars.
  ///
  /// Extracted from AnimatedChartPainter._drawStackedBars (lines 923-1001).
  List<BarRenderData> calculateStackedBars(
    BarGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    Rect plotArea,
    String? yCol,
  ) {
    final bars = <BarRenderData>[];

    // Group data by X value
    final groups = <dynamic, List<Map<String, dynamic>>>{};
    for (final point in data) {
      final x = point[xColumn];
      groups.putIfAbsent(x, () => []).add(point);
    }

    for (final groupEntry in groups.entries) {
      final x = groupEntry.key;
      final groupData = groupEntry.value;

      // Sort by color for consistent stacking order
      groupData.sort((a, b) {
        final aColor = a[colorColumn]?.toString() ?? '';
        final bColor = b[colorColumn]?.toString() ?? '';
        return aColor.compareTo(bColor);
      });

      double cumulativeValue = 0;
      for (final point in groupData) {
        final y = getNumericValue(point[yCol]);
        if (y == null || !y.isFinite || y <= 0) continue;

        final bar = calculateSingleBar(
          x,
          y,
          xScale,
          yScale,
          colorScale,
          geometry,
          point,
          plotArea,
          yStackOffset: cumulativeValue,
        );

        if (bar != null) {
          bars.add(bar);
        }

        cumulativeValue += y;
      }
    }

    return bars;
  }

  /// Calculates geometry for a single line.
  ///
  /// Extracted from AnimatedChartPainter._drawSingleLineAnimated (lines 1505-1577).
  ///
  /// Returns null if the line cannot be drawn (< 2 points, invalid data, etc.).
  LineRenderData? calculateLine(
    LineGeometry geometry,
    Scale xScale,
    Scale yScale,
    Color color,
    Rect plotArea,
    List<Map<String, dynamic>> lineData,
    String? yCol,
  ) {
    if (yCol == null) return null;

    // Sort data by x value for proper line connection
    final sortedData = List<Map<String, dynamic>>.from(lineData);
    sortedData.sort((a, b) {
      final aXValue = a[xColumn];
      final bXValue = b[xColumn];

      if (aXValue == null && bXValue == null) return 0;
      if (aXValue == null) return -1;
      if (bXValue == null) return 1;

      // Get the actual plotted X position for proper ordering
      double aXPosition, bXPosition;

      if (xScale is OrdinalScale) {
        aXPosition = xScale.bandCenter(aXValue);
        bXPosition = xScale.bandCenter(bXValue);
      } else {
        final aXNum = getNumericValue(aXValue) ?? 0;
        final bXNum = getNumericValue(bXValue) ?? 0;
        aXPosition = xScale.scale(aXNum);
        bXPosition = xScale.scale(bXNum);
      }

      return aXPosition.compareTo(bXPosition);
    });

    final points = <Offset>[];

    for (final point in sortedData) {
      final xRawValue = point[xColumn];
      final yVal = getNumericValue(point[yCol]);

      if (xRawValue == null || yVal == null) {
        continue;
      }

      // Handle both ordinal and continuous X-scales
      double screenX;
      if (xScale is OrdinalScale) {
        screenX = plotArea.left + xScale.bandCenter(xRawValue);
      } else {
        final xVal = getNumericValue(xRawValue);
        if (xVal == null) continue;
        screenX = plotArea.left + xScale.scale(xVal);
      }

      final screenY = plotArea.top + yScale.scale(yVal);

      if (!screenX.isFinite || !screenY.isFinite) {
        continue;
      }

      points.add(Offset(screenX, screenY));
    }

    if (points.length < 2) {
      return null;
    }

    return LineRenderData(
      points: points,
      color: color,
      strokeWidth: geometry.strokeWidth,
      alpha: geometry.alpha,
      style: geometry.style,
    );
  }

  /// Calculates geometry for all lines (handles grouping by color).
  ///
  /// Extracted from AnimatedChartPainter._drawLinesAnimated (lines 1458-1503).
  List<LineRenderData> calculateLines(
    LineGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    Rect plotArea,
    String? yCol,
  ) {
    if (yCol == null) return [];

    final lines = <LineRenderData>[];

    if (colorColumn != null) {
      // Group by color and draw separate lines
      final groupedData = <dynamic, List<Map<String, dynamic>>>{};
      for (final point in data) {
        final colorValue = point[colorColumn];
        groupedData.putIfAbsent(colorValue, () => []).add(point);
      }

      for (final entry in groupedData.entries) {
        final colorValue = entry.key;
        final groupData = entry.value;
        final lineColor = geometry.color ?? colorScale.scale(colorValue);

        final line = calculateLine(
          geometry,
          xScale,
          yScale,
          lineColor,
          plotArea,
          groupData,
          yCol,
        );

        if (line != null) {
          lines.add(line);
        }
      }
    } else {
      // Draw single line for all data
      final lineColor = geometry.color ??
          (theme.colorPalette.isNotEmpty
              ? theme.colorPalette.first
              : theme.primaryColor);

      final line = calculateLine(
        geometry,
        xScale,
        yScale,
        lineColor,
        plotArea,
        data,
        yCol,
      );

      if (line != null) {
        lines.add(line);
      }
    }

    return lines;
  }

  /// Calculates geometry for scatter points.
  ///
  /// Extracted from AnimatedChartPainter._drawPointsAnimated (lines 1122-1269).
  List<PointRenderData> calculatePoints(
    PointGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    SizeScale sizeScale,
    Rect plotArea,
    String? yCol,
  ) {
    if (yCol == null) return [];

    final points = <PointRenderData>[];

    for (final point in data) {
      final xRawValue = point[xColumn];
      final y = getNumericValue(point[yCol]);

      if (xRawValue == null || y == null) continue;

      // Handle both ordinal and continuous X-scales
      double pointX;
      if (xScale is OrdinalScale) {
        pointX = plotArea.left + xScale.bandCenter(xRawValue);
      } else {
        final x = getNumericValue(xRawValue);
        if (x == null) continue;
        pointX = plotArea.left + xScale.scale(x);
      }

      final pointY = plotArea.top + yScale.scale(y);

      if (!pointX.isFinite || !pointY.isFinite) {
        continue;
      }

      // Priority: geometry.color > colorScale > theme fallback
      final dynamic colorOrGradient;
      if (geometry.color != null) {
        colorOrGradient = geometry.color!;
      } else if (colorColumn != null) {
        colorOrGradient = colorScale.scale(point[colorColumn]);
      } else {
        colorOrGradient = theme.colorPalette.isNotEmpty
            ? theme.colorPalette.first
            : theme.primaryColor;
      }

      final size = sizeColumn != null
          ? sizeScale.scale(point[sizeColumn])
          : theme.pointSizeDefault;

      points.add(PointRenderData(
        position: Offset(pointX, pointY),
        size: size,
        colorOrGradient: colorOrGradient,
        alpha: geometry.alpha,
        shape: geometry.shape,
        borderWidth: geometry.borderWidth,
        borderColor: geometry.borderWidth > 0 ? theme.borderColor : null,
        dataPoint: point,
      ));
    }

    return points;
  }
}
