import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/scale.dart';
import 'chart_interactions.dart';

/// Efficient spatial indexing for chart interaction detection
class InteractionDetector {
  final List<Map<String, dynamic>> data;
  final List<Geometry> geometries;
  final Scale xScale;
  final Scale yScale;
  final Scale? y2Scale;
  final Rect plotArea;
  final String? xColumn;
  final String? yColumn;
  final String? y2Column;
  final String? colorColumn;
  final bool coordFlipped;

  // Spatial index for fast hit testing
  final Map<int, List<_IndexedDataPoint>> _spatialGrid = {};
  final int _gridSize = 20; // Grid cell size in pixels
  bool _indexBuilt = false;

  InteractionDetector({
    required this.data,
    required this.geometries,
    required this.xScale,
    required this.yScale,
    this.y2Scale,
    required this.plotArea,
    this.xColumn,
    this.yColumn,
    this.y2Column,
    this.colorColumn,
    this.coordFlipped = false,
  });

  /// Find the closest data point to the given screen coordinates
  DataPointInfo? detectPoint(Offset screenPosition, {double maxDistance = 15.0}) {
    if (!_indexBuilt) {
      _buildSpatialIndex();
    }

    _IndexedDataPoint? closest;
    double closestDistance = maxDistance;

    // Check grid cells around the touch point
    final touchGridX = (screenPosition.dx / _gridSize).floor();
    final touchGridY = (screenPosition.dy / _gridSize).floor();

    for (int gx = touchGridX - 1; gx <= touchGridX + 1; gx++) {
      for (int gy = touchGridY - 1; gy <= touchGridY + 1; gy++) {
        final gridKey = _gridKey(gx, gy);
        final cellPoints = _spatialGrid[gridKey];
        if (cellPoints == null) continue;

        for (final point in cellPoints) {
          final distance = _calculateDistance(screenPosition, point);
          if (distance < closestDistance) {
            closest = point;
            closestDistance = distance;
          }
        }
      }
    }

    if (closest == null) return null;

    return DataPointInfo(
      data: closest.data,
      screenPosition: closest.screenPosition,
      dataIndex: closest.dataIndex,
      seriesName: closest.seriesName,
      xValue: closest.xValue,
      yValue: closest.yValue,
      color: closest.color,
    );
  }

  /// Build spatial index for efficient hit testing
  void _buildSpatialIndex() {
    _spatialGrid.clear();

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      for (final geometry in geometries) {
        final indexedPoint = _createIndexedPoint(point, i, geometry);
        if (indexedPoint != null) {
          _addToSpatialGrid(indexedPoint);
        }
      }
    }

    _indexBuilt = true;
  }

  /// Create indexed point for a given data point and geometry
  _IndexedDataPoint? _createIndexedPoint(
      Map<String, dynamic> point,
      int index,
      Geometry geometry,
      ) {
    final useY2 = geometry.yAxis == YAxis.secondary;
    final yCol = useY2 ? y2Column : yColumn;
    final activeYScale = useY2 ? (y2Scale ?? yScale) : yScale;

    dynamic xValue = point[xColumn];
    dynamic yValue = point[yCol];

    if (xValue == null || yValue == null) return null;

    // Calculate screen position based on coordinate system
    Offset screenPosition;
    if (coordFlipped) {
      // Horizontal charts: X becomes Y, Y becomes X
      final numYValue = _getNumericValue(yValue);
      final screenX = plotArea.left + activeYScale.scale(numYValue ?? 0);

      double screenY;
      if (xScale is OrdinalScale) {
        final ordinalScale = xScale as OrdinalScale;
        screenY = plotArea.top + ordinalScale.bandCenter(xValue);
      } else {
        final numXValue = _getNumericValue(xValue);
        screenY = plotArea.top + xScale.scale(numXValue ?? 0);
      }
      screenPosition = Offset(screenX, screenY);
    } else {
      // Normal charts
      double screenX;
      if (xScale is OrdinalScale) {
        final ordinalScale = xScale as OrdinalScale;
        screenX = plotArea.left + ordinalScale.bandCenter(xValue);
      } else {
        final numXValue = _getNumericValue(xValue);
        screenX = plotArea.left + xScale.scale(numXValue ?? 0);
      }

      final numYValue = _getNumericValue(yValue);
      final screenY = plotArea.top + activeYScale.scale(numYValue ?? 0);
      screenPosition = Offset(screenX, screenY);
    }

    // Skip points outside plot area
    if (!plotArea.contains(screenPosition)) {
      return null;
    }

    return _IndexedDataPoint(
      data: point,
      dataIndex: index,
      screenPosition: screenPosition,
      geometry: geometry,
      xValue: xValue,
      yValue: yValue,
      seriesName: colorColumn != null ? point[colorColumn]?.toString() : null,
      color: _getPointColor(point, geometry),
    );
  }

  /// Add point to spatial grid for fast lookups
  void _addToSpatialGrid(_IndexedDataPoint point) {
    final gridX = (point.screenPosition.dx / _gridSize).floor();
    final gridY = (point.screenPosition.dy / _gridSize).floor();
    final gridKey = _gridKey(gridX, gridY);

    _spatialGrid.putIfAbsent(gridKey, () => []).add(point);
  }

  /// Calculate distance between screen position and data point
  double _calculateDistance(Offset screenPos, _IndexedDataPoint point) {
    final geometry = point.geometry;

    if (geometry is PointGeometry) {
      return _distanceToPoint(screenPos, point.screenPosition);
    } else if (geometry is LineGeometry) {
      return _distanceToLine(screenPos, point);
    } else if (geometry is BarGeometry) {
      return _distanceToBar(screenPos, point);
    }

    return double.infinity;
  }

  /// Distance to point (circle)
  double _distanceToPoint(Offset screenPos, Offset pointPos) {
    final dx = screenPos.dx - pointPos.dx;
    final dy = screenPos.dy - pointPos.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Distance to line segment (approximated)
  double _distanceToLine(Offset screenPos, _IndexedDataPoint point) {
    // For line charts, we treat each point as a circle
    // In a more complete implementation, we'd find the actual line segments
    return _distanceToPoint(screenPos, point.screenPosition);
  }

  /// Distance to bar rectangle
  double _distanceToBar(Offset screenPos, _IndexedDataPoint point) {
    // Approximate bar bounds
    Rect barBounds;
    if (coordFlipped) {
      // Horizontal bar
      final height = 20.0; // Approximate bar height
      barBounds = Rect.fromLTWH(
        plotArea.left,
        point.screenPosition.dy - height / 2,
        point.screenPosition.dx - plotArea.left,
        height,
      );
    } else {
      // Vertical bar
      final width = 20.0; // Approximate bar width
      barBounds = Rect.fromLTWH(
        point.screenPosition.dx - width / 2,
        point.screenPosition.dy,
        width,
        plotArea.bottom - point.screenPosition.dy,
      );
    }

    if (barBounds.contains(screenPos)) {
      return 0.0; // Inside bar
    }

    // Distance to closest edge
    final dx = math.max(0, math.max(barBounds.left - screenPos.dx, screenPos.dx - barBounds.right));
    final dy = math.max(0, math.max(barBounds.top - screenPos.dy, screenPos.dy - barBounds.bottom));
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Get color for a data point
  Color? _getPointColor(Map<String, dynamic> point, Geometry geometry) {
    if (geometry is PointGeometry && geometry.color != null) {
      return geometry.color;
    } else if (geometry is LineGeometry && geometry.color != null) {
      return geometry.color;
    } else if (geometry is BarGeometry && geometry.color != null) {
      return geometry.color;
    }

    // Default color logic would go here
    return Colors.blue;
  }

  /// Convert numeric value from dynamic
  double? _getNumericValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Generate grid key for spatial indexing
  int _gridKey(int x, int y) {
    return (x << 16) | (y & 0xFFFF);
  }

  /// Invalidate spatial index when data changes
  void invalidate() {
    _indexBuilt = false;
    _spatialGrid.clear();
  }
}

/// Internal class for spatial indexing
class _IndexedDataPoint {
  final Map<String, dynamic> data;
  final int dataIndex;
  final Offset screenPosition;
  final Geometry geometry;
  final dynamic xValue;
  final dynamic yValue;
  final String? seriesName;
  final Color? color;

  const _IndexedDataPoint({
    required this.data,
    required this.dataIndex,
    required this.screenPosition,
    required this.geometry,
    this.xValue,
    this.yValue,
    this.seriesName,
    this.color,
  });
}