import 'package:flutter/material.dart';
import 'dart:math' as math;

class TutorialStep {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final TutorialPosition position;

  TutorialStep({
    required this.title,
    required this.description,
    required this.targetKey,
    this.position = TutorialPosition.bottom,
  });
}

enum TutorialPosition {
  top,
  bottom,
  left,
  right,
}

class InteractiveTutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const InteractiveTutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<InteractiveTutorialOverlay> createState() =>
      _InteractiveTutorialOverlayState();
}

class _InteractiveTutorialOverlayState
    extends State<InteractiveTutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _skip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      widget.onComplete();
    }
  }

  Rect? _getTargetRect() {
    final step = widget.steps[_currentStep];
    final RenderBox? renderBox =
        step.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return null;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final targetRect = _getTargetRect();
    final step = widget.steps[_currentStep];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent overlay
          GestureDetector(
            onTap: _nextStep,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: CustomPaint(
                painter: targetRect != null
                    ? HolePainter(holeRect: targetRect)
                    : null,
                child: Container(),
              ),
            ),
          ),

          // Tutorial content
          if (targetRect != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildTutorialContent(targetRect, step),
                ),
              ),
            ),

          // Skip button
          Positioned(
            top: 40,
            right: 20,
            child: TextButton.icon(
              onPressed: _skip,
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text(
                '건너뛰기',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // Progress indicator
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              '${_currentStep + 1} / ${widget.steps.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialContent(Rect targetRect, TutorialStep step) {
    final screenSize = MediaQuery.of(context).size;
    final isTop = targetRect.top > screenSize.height / 2;

    return Stack(
      children: [
        // Arrow pointing to target
        _buildArrow(targetRect, step.position),

        // Tutorial card
        Positioned(
          left: 20,
          right: 20,
          top: isTop ? null : targetRect.bottom + 40,
          bottom: isTop ? screenSize.height - targetRect.top + 40 : null,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      if (_currentStep > 0)
                        TextButton.icon(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('이전'),
                        )
                      else
                        const SizedBox.shrink(),

                      // Next/Complete button
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _currentStep < widget.steps.length - 1
                              ? '다음'
                              : '완료',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrow(Rect targetRect, TutorialPosition position) {
    final screenSize = MediaQuery.of(context).size;
    final isTop = targetRect.top > screenSize.height / 2;

    double left = targetRect.center.dx - 20;
    double? top = isTop ? targetRect.top - 60 : null;
    double? bottom = isTop ? null : screenSize.height - targetRect.bottom - 60;

    return Positioned(
      left: left,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: isTop ? math.pi : 0,
        child: Icon(
          Icons.arrow_downward,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  final Rect holeRect;

  HolePainter({required this.holeRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create rounded rectangle hole with padding
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          holeRect.inflate(8),
          const Radius.circular(8),
        ),
      );

    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      holePath,
    );

    canvas.drawPath(combinedPath, paint);

    // Draw highlight border around hole
    final borderPaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        holeRect.inflate(8),
        const Radius.circular(8),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(HolePainter oldDelegate) {
    return oldDelegate.holeRect != holeRect;
  }
}
