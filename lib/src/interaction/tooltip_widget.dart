import 'dart:async';

import 'package:flutter/material.dart';

import 'chart_interactions.dart';

/// Abstract controller for managing the tooltip visibility.
abstract class TooltipController {
  /// Hides the tooltip.
  void hideTooltip();

  /// Shows the tooltip for a given data point at a specific position.
  void showTooltip(DataPointInfo point, Offset position);
}

/// Tooltip overlay widget for chart interactions
class ChartTooltipOverlay extends StatefulWidget {
  final Widget child;
  final TooltipConfig config;
  final TooltipBuilder? tooltipBuilder;

  const ChartTooltipOverlay({
    super.key,
    required this.child,
    required this.config,
    this.tooltipBuilder,
  });

  @override
  State<ChartTooltipOverlay> createState() => _ChartTooltipOverlayState();
}

class _ChartTooltipOverlayState extends State<ChartTooltipOverlay>
    with SingleTickerProviderStateMixin implements TooltipController {
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  DataPointInfo? _currentPoint;
  Offset? _currentPosition;
  bool _isVisible = false;
  bool _shouldShow = false; // Track intended state

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _removeTooltip();
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// Show tooltip for a data point
  @override
  void showTooltip(DataPointInfo point, Offset position) {
    // Update current state
    _currentPoint = point;
    _currentPosition = position;
    _shouldShow = true;

    if (widget.config.builder == null) {
      return;
    }

    // Cancel any pending hide operation
    _hideTimer?.cancel();
    _hideTimer = null;

    // If already showing a tooltip, immediately switch to new point
    if (_isVisible && _overlayEntry != null) {
      // Update position and recreate with new data
      _removeTooltip();
      _createTooltip();
      return;
    }

    // Cancel any existing show timer and start a new one
    _showTimer?.cancel();
    _showTimer = Timer(widget.config.showDelay, () {
      if (_shouldShow && _currentPoint != null && mounted) {
        _createTooltip();
      }
    });
  }

  /// Hide tooltip
  @override
  void hideTooltip() {
    _shouldShow = false;

    // Cancel any pending show operation
    _showTimer?.cancel();
    _showTimer = null;

    // Only start hide timer if we're actually visible
    if (_overlayEntry != null && _isVisible) {
      _hideTimer?.cancel();
      _hideTimer = Timer(widget.config.hideDelay, () {
        if (!_shouldShow && mounted) {
          _animationController.reverse().whenComplete(() {
            // Only defer the cleanup, not the animation
            if (!_shouldShow) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_shouldShow && mounted) {
                  _removeTooltip();
                }
              });
            }
          });
        }
      });
    }
  }

  /// Create and show tooltip overlay
  void _createTooltip() {
    if (!_shouldShow || _currentPosition == null || _currentPoint == null) {
      return;
    }

    // Remove existing tooltip
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    final Offset capturedPosition = _currentPosition!;
    final TooltipConfig capturedConfig = widget.config;
    final DataPointInfo capturedPoint = _currentPoint!;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _TooltipPositioned(
          position: capturedPosition,
          config: capturedConfig,
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
          child: capturedConfig.builder!(capturedPoint),
        );
      },
    );

    try {
      final overlay = Overlay.of(context);
      overlay.insert(_overlayEntry!);
      _isVisible = true;
      _animationController.forward();
    } catch (e) {
      debugPrint("Error creating tooltip: $e");
      _removeTooltip();
    }
  }

  /// Remove tooltip overlay
  void _removeTooltip() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isVisible = false;
    _animationController.reset();

    // Clear current point reference when removing
    if (!_shouldShow) {
      _currentPoint = null;
      _currentPosition = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChartTooltipProvider(
      state: this,
      child: widget.child,
    );
  }
}

/// Positioned tooltip widget
class _TooltipPositioned extends AnimatedWidget {
  final Offset position;
  final TooltipConfig config;
  final Widget child;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _TooltipPositioned({
    required this.position,
    required this.config,
    required this.child,
    required this.fadeAnimation,
    required this.scaleAnimation,
  }) : super(listenable: fadeAnimation);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Smart positioning to avoid screen edges
    double left = position.dx - 75; // Center tooltip horizontally
    double top = position.dy - 80;  // Position above touch point

    // Adjust if too close to edges
    if (left < 10) left = 10;
    if (left + 150 > screenSize.width) left = screenSize.width - 160;
    if (top < 10) top = position.dy + 20; // Show below if too close to top

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer( // THIS IS THE KEY FIX!
        child: AnimatedBuilder(
          animation: Listenable.merge([fadeAnimation, scaleAnimation]),
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: _TooltipContainer(
                    config: config,
                    child: this.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Styled tooltip container
class _TooltipContainer extends StatelessWidget {
  final TooltipConfig config;
  final Widget child;

  const _TooltipContainer({
    required this.config,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        boxShadow: config.shadow != null ? [config.shadow!] : [
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white24, width: 1),
      ),
      constraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 30,
        maxWidth: 200,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }
}

/// Provider for tooltip functionality
class ChartTooltipProvider extends InheritedWidget {
  final TooltipController state;

  const ChartTooltipProvider({
    super.key,
    required this.state,
    required super.child,
  });

  static TooltipController? of(BuildContext context, {bool listen = true}) {
    return listen
        ? context.dependOnInheritedWidgetOfExactType<ChartTooltipProvider>()?.state
        : (context.getElementForInheritedWidgetOfExactType<ChartTooltipProvider>()?.widget
    as ChartTooltipProvider?)
        ?.state;
  }

  @override
  bool updateShouldNotify(ChartTooltipProvider oldWidget) {
    return oldWidget.state != state;
  }
}

/// Mixin for widgets that want to show tooltips
mixin TooltipMixin {
  /// Show tooltip for a data point
  void showTooltip(BuildContext context, DataPointInfo point, Offset position) {
    final provider = ChartTooltipProvider.of(context);
    provider?.showTooltip(point, position);
  }

  /// Hide tooltip
  void hideTooltip(BuildContext context) {
    final provider = ChartTooltipProvider.of(context);
    provider?.hideTooltip();
  }
}

/// Helper functions for tooltip positioning
class TooltipPositioning {
  /// Calculate optimal tooltip position to avoid screen edges
  static Offset calculatePosition(
      Offset touchPosition,
      Size tooltipSize,
      Size screenSize, {
        double margin = 16.0,
      }) {
    double x = touchPosition.dx;
    double y = touchPosition.dy - tooltipSize.height - 10;

    // Adjust horizontal position to stay on screen
    if (x + tooltipSize.width + margin > screenSize.width) {
      x = screenSize.width - tooltipSize.width - margin;
    }
    if (x < margin) {
      x = margin;
    }

    // Adjust vertical position to stay on screen
    if (y < margin) {
      y = touchPosition.dy + 10; // Show below touch point
    }

    return Offset(x, y);
  }
}