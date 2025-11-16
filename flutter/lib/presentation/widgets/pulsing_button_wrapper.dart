import 'package:flutter/material.dart';

/// Wraps a widget with a pulsing animation effect
/// Used in tutorial screens to draw attention to important buttons
class PulsingButtonWrapper extends StatefulWidget {
  final Widget child;
  final bool animate;

  const PulsingButtonWrapper({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<PulsingButtonWrapper> createState() => _PulsingButtonWrapperState();
}

class _PulsingButtonWrapperState extends State<PulsingButtonWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3 * _scaleAnimation.value),
                  blurRadius: 8 * _scaleAnimation.value,
                  spreadRadius: 2 * _scaleAnimation.value,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
