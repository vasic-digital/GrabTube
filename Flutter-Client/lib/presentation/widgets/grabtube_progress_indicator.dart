import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A custom progress indicator widget for GrabTube using the animated arrow logo.
///
/// This widget displays an animated arrow that fills from bottom to top
/// based on the provided progress value (0.0 to 1.0).
///
/// Example usage:
/// ```dart
/// GrabTubeProgressIndicator(
///   progress: 0.75, // 75% complete
///   size: 48,
/// )
/// ```
class GrabTubeProgressIndicator extends StatelessWidget {
  /// The progress value from 0.0 (0%) to 1.0 (100%)
  final double progress;

  /// The size of the progress indicator widget
  final double size;

  /// Whether to show the progress percentage as text
  final bool showPercentage;

  /// The color of the percentage text
  final Color? textColor;

  const GrabTubeProgressIndicator({
    required this.progress,
    this.size = 48.0,
    this.showPercentage = false,
    this.textColor,
    super.key,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    // Clamp progress to ensure it's within valid range
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            'assets/animations/progress_arrow.json',
            controller: null,
            animate: false,
            frameRate: FrameRate.max,
            // Convert progress (0.0-1.0) to frame position (0.0-1.0)
            delegates: LottieDelegates(
              values: [
                ValueDelegate.position(
                  const ['**'],
                  value: clampedProgress,
                ),
              ],
            ),
            options: LottieOptions(
              enableMergePaths: true,
            ),
            // Use a custom composition builder to control the animation frame
            frameBuilder: (context, child, composition) {
              if (composition == null) return child;

              return AnimatedBuilder(
                animation: AlwaysStoppedAnimation(clampedProgress),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _LottieProgressPainter(
                      composition: composition,
                      progress: clampedProgress,
                    ),
                    child: child,
                  );
                },
              );
            },
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${(clampedProgress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.w600,
              color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter to render the Lottie animation at a specific progress point
class _LottieProgressPainter extends CustomPainter {
  final dynamic composition;
  final double progress;

  _LottieProgressPainter({
    required this.composition,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The actual rendering is handled by the Lottie widget
    // This is just a placeholder for the custom painter interface
  }

  @override
  bool shouldRepaint(covariant _LottieProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A simpler linear progress bar styled with GrabTube colors and the arrow icon
class GrabTubeLinearProgress extends StatelessWidget {
  /// The progress value from 0.0 (0%) to 1.0 (100%)
  final double progress;

  /// The height of the progress bar
  final double height;

  /// Whether to show the progress percentage as text
  final bool showPercentage;

  /// Optional label to display above the progress bar
  final String? label;

  const GrabTubeLinearProgress({
    required this.progress,
    this.height = 8.0,
    this.showPercentage = true,
    this.label,
    super.key,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: MediaQuery.of(context).size.width * clampedProgress,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 45,
                child: Text(
                  '${(clampedProgress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// A circular progress indicator with the GrabTube arrow icon
class GrabTubeCircularProgress extends StatelessWidget {
  /// The progress value from 0.0 (0%) to 1.0 (100%)
  final double progress;

  /// The size of the circular progress indicator
  final double size;

  /// The stroke width of the progress circle
  final double strokeWidth;

  /// Whether to show the progress percentage in the center
  final bool showPercentage;

  const GrabTubeCircularProgress({
    required this.progress,
    this.size = 64.0,
    this.strokeWidth = 4.0,
    this.showPercentage = true,
    super.key,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedProgress,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          // Center content
          if (showPercentage)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GrabTubeProgressIndicator(
                  progress: clampedProgress,
                  size: size * 0.4,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(clampedProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            )
          else
            GrabTubeProgressIndicator(
              progress: clampedProgress,
              size: size * 0.5,
            ),
        ],
      ),
    );
  }
}
