import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chart_interactions.dart';

/// Abstract controller for managing the tooltip visibility.
/// This allows other parts of the library to interact with the tooltip
/// without needing direct access to its private state class.
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
  void didUpdateWidget(ChartTooltipOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    debugPrint("[_ChartTooltipOverlayState.showTooltip] Called. Point: $point, Position: $position");
    _currentPoint = point;
    _currentPosition = position;

    if (widget.config.builder == null) {
      debugPrint("[_ChartTooltipOverlayState.showTooltip] No tooltip builder configured. Aborting.");
      return;
    }

    final showDelay = widget.config.showDelay;
    debugPrint("[_ChartTooltipOverlayState.showTooltip] Current showDelay: $showDelay");

    if (_showTimer != null && _showTimer!.isActive) {
      debugPrint("[_ChartTooltipOverlayState.showTooltip] Cancelling active showTimer.");
    }
    _showTimer?.cancel();
    _showTimer = Timer(showDelay,
        () {
      // This debugPrint is crucial for confirming timer execution.
      debugPrint("[_ChartTooltipOverlayState.showTooltip] --- Timer FIRED --- _currentPoint: $_currentPoint, mounted: $mounted");
      if (_currentPoint != null && mounted) {
        _createTooltip();
      }
    });
  }

  /// Hide tooltip
  @override
  void hideTooltip() {
    debugPrint("[_ChartTooltipOverlayState.hideTooltip] Called. Current overlayEntry: $_overlayEntry, current _hideTimer: $_hideTimer (isActive: ${_hideTimer?.isActive})");
    _showTimer?.cancel(); // Cancel any pending show operations

    if (_overlayEntry != null) {
      if (_hideTimer != null && _hideTimer!.isActive) {
        debugPrint("[_ChartTooltipOverlayState.hideTooltip] Cancelling active hideTimer.");
      }
      _hideTimer?.cancel(); // Cancel any existing hide timer
      debugPrint("[_ChartTooltipOverlayState.hideTooltip] Starting hide timer with delay: ${widget.config.hideDelay}");
      _hideTimer = Timer(widget.config.hideDelay, () {
        debugPrint("[_ChartTooltipOverlayState.hideTooltip] --- Hide Timer FIRED --- mounted: $mounted");
        if (mounted) {
          _animationController.reverse().whenComplete(() {
            debugPrint("[_ChartTooltipOverlayState.hideTooltip] Animation reversed. Removing overlay via _removeTooltip.");
            _removeTooltip();
          });
        } else {
          debugPrint("[_ChartTooltipOverlayState.hideTooltip] Widget not mounted when hide timer fired. Removing overlay directly via _removeTooltip.");
          _removeTooltip(); // If not mounted, just ensure it's removed without animation
        }
      });
    } else {
      debugPrint("[_ChartTooltipOverlayState.hideTooltip] No overlayEntry to hide.");
    }
  }

  /// Create and show tooltip overlay
  void _createTooltip() {
    debugPrint("[_ChartTooltipOverlayState._createTooltip] Called. _currentPoint: $_currentPoint, _currentPosition: $_currentPosition");

    // Always remove the existing tooltip before creating a new one to ensure fresh data.
    if (_overlayEntry != null) {
      debugPrint("[_ChartTooltipOverlayState._createTooltip] Removing existing OverlayEntry before creating a new one.");
      _overlayEntry!.remove(); // Remove from overlay
      _overlayEntry = null;     // Nullify the reference
    }

    // Assert that _currentPosition and _currentPoint are not null before using them.
    assert(_currentPosition != null, "_currentPosition must not be null in _createTooltip");
    assert(_currentPoint != null, "_currentPoint must not be null in _createTooltip");
    if (_currentPosition == null || _currentPoint == null || widget.config.builder == null) {
      debugPrint("[_ChartTooltipOverlayState._createTooltip] _currentPosition, _currentPoint, or builder is null. Aborting tooltip creation.");
      return;
    }

    final Offset capturedPosition = _currentPosition!;
    final TooltipConfig capturedConfig = widget.config;
    final DataPointInfo capturedPoint = _currentPoint!;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        debugPrint("[_ChartTooltipOverlayState._createTooltip] OverlayEntry BUILDER executing. Point: $capturedPoint, Position: $capturedPosition. Builder context: $context");
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
      debugPrint("[_ChartTooltipOverlayState._createTooltip] Attempting Overlay.of(context)... State context: $context");
      final overlay = Overlay.of(context);
      debugPrint("[_ChartTooltipOverlayState._createTooltip] Overlay.of(context) successful. Overlay: $overlay. Attempting insert...");
      overlay.insert(_overlayEntry!);
      debugPrint("[_ChartTooltipOverlayState._createTooltip] OverlayEntry INSERTED successfully.");
      _animationController.forward();
      debugPrint("[_ChartTooltipOverlayState._createTooltip] Animation controller FORWARD called.");
    } catch (e, s) {
      debugPrint("[_ChartTooltipOverlayState._createTooltip] Error during OverlayEntry insertion or animation: $e\n$s. Context used: $context");
    }
  }

  /// Remove tooltip overlay
  void _removeTooltip() {
    debugPrint("[_ChartTooltipOverlayState._removeTooltip] Called. Current _overlayEntry: $_overlayEntry");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      debugPrint("[_ChartTooltipOverlayState._removeTooltip] OverlayEntry removed and nullified.");
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
  }) : super(listenable: fadeAnimation); // Listen to one for AnimatedWidget

  @override
  Widget build(BuildContext context) {
    debugPrint("[_TooltipPositioned.build] Building with position: $position, fade: ${fadeAnimation.value}, scale: ${scaleAnimation.value}");
    return Positioned(
      left: math.max(10, position.dx - 50), // Ensure it stays on screen
      top: math.max(10, position.dy - 60), // Position above the point
      child: AnimatedBuilder(
        animation: Listenable.merge([fadeAnimation, scaleAnimation]),
        builder: (context, child) {
          return Opacity(
            opacity: fadeAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Material( // Add Material for proper rendering
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
    return Transform.translate(
      offset: const Offset(-50, -10), // Center above touch point
      child: Container(
        padding: config.padding,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
          boxShadow: config.shadow != null ? [config.shadow!] : [
            // Add a more prominent default shadow
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
          // Add a border for debugging
          border: Border.all(color: Colors.white, width: 1),
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

  /// Retrieves the [TooltipController] from the nearest [ChartTooltipProvider] ancestor.
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
    debugPrint("[TooltipMixin.showTooltip] Called. Point: $point, Position: $position");
    final provider = ChartTooltipProvider.of(context);
    if (provider == null) {
      debugPrint("[TooltipMixin.showTooltip] ChartTooltipProvider.of(context) returned NULL. Tooltip will not be shown.");
      return;
    }
    debugPrint("[TooltipMixin.showTooltip] Provider found. Calling provider.showTooltip.");
    provider.showTooltip(point, position);
  }

  /// Hide tooltip
  void hideTooltip(BuildContext context) {
    debugPrint("[TooltipMixin.hideTooltip] Called.");
    final provider = ChartTooltipProvider.of(context);
    if (provider == null) {
      debugPrint("[TooltipMixin.hideTooltip] ChartTooltipProvider.of(context) returned NULL. Cannot hide tooltip.");
      return;
    }
    debugPrint("[TooltipMixin.hideTooltip] Provider found. Calling provider.hideTooltip.");
    provider.hideTooltip();
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