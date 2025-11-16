import 'package:flutter/material.dart';

/// A widget that wraps a child with a highlighted border and optional instruction text
/// Used in tutorial screens to guide users
class TutorialHighlightBox extends StatelessWidget {
  final Widget child;
  final String? instructionText;
  final Color highlightColor;
  final double borderWidth;
  final bool showPulseAnimation;

  const TutorialHighlightBox({
    super.key,
    required this.child,
    this.instructionText,
    this.highlightColor = Colors.red,
    this.borderWidth = 3.0,
    this.showPulseAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: highlightColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: highlightColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );

    if (showPulseAnimation) {
      content = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: highlightColor.withOpacity(0.5 + (value * 0.5)),
                width: borderWidth,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: highlightColor.withOpacity(0.2 + (value * 0.3)),
                  blurRadius: 4 + (value * 8),
                  spreadRadius: value * 3,
                ),
              ],
            ),
            child: this.child,
          );
        },
        onEnd: () {
          // Restart animation
        },
      );
    }

    if (instructionText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: highlightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: highlightColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: highlightColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    instructionText!,
                    style: TextStyle(
                      color: highlightColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      );
    }

    return content;
  }
}

/// A banner that appears at the top of tutorial screens
class TutorialBanner extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final int currentStep;
  final int totalSteps;

  const TutorialBanner({
    super.key,
    required this.title,
    required this.description,
    this.onNext,
    this.onSkip,
    this.currentStep = 1,
    this.totalSteps = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '튜토리얼 ($currentStep/$totalSteps)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (onSkip != null)
                TextButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  label: const Text(
                    '건너뛰기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          if (onNext != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('다음 단계'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
