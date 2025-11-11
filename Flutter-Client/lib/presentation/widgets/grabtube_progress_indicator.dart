import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A custom progress indicator widget for GrabTube using the animated arrow logo.
///
/// This widget displays an animated arrow that fills from bottom to top
/// based on the provided progress value (0.0 to 1.0).
///
/// Features smooth animated transitions, pulsing effect for active downloads,
/// and bounce animation on completion.
///
/// Example usage:
/// ```dart
/// GrabTubeProgressIndicator(
///   progress: 0.75, // 75% complete
///   size: 48,
///   isAnimating: true, // Shows pulsing effect
/// )
/// ```
class GrabTubeProgressIndicator extends StatefulWidget {
  /// The progress value from 0.0 (0%) to 1.0 (100%)
  final double progress;

  /// The size of the progress indicator widget
  final double size;

  /// Whether to show the progress percentage as text
  final bool showPercentage;

  /// The color of the percentage text
  final Color? textColor;

  /// Whether the download is actively progressing (enables pulsing animation)
  final bool isAnimating;

  const GrabTubeProgressIndicator({
    required this.progress,
    this.size = 48.0,
    this.showPercentage = false,
    this.textColor,
    this.isAnimating = false,
    super.key,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');

  @override
  State<GrabTubeProgressIndicator> createState() => _GrabTubeProgressIndicatorState();
}

class _GrabTubeProgressIndicatorState extends State<GrabTubeProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  double _displayProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _displayProgress = widget.progress;

    // Pulsing animation controller (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Pulse scale animation (1.0 → 1.05 → 1.0)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Scale animation for completion bounce
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GrabTubeProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }

    // Handle completion bounce
    if (widget.progress == 1.0 && oldWidget.progress < 1.0) {
      _playCompletionBounce();
    }

    // Smoothly animate progress changes
    if (widget.progress != oldWidget.progress) {
      _animateProgress(widget.progress);
    }
  }

  void _animateProgress(double targetProgress) {
    // Smoothly transition to new progress value
    setState(() {
      _displayProgress = targetProgress;
    });
  }

  void _playCompletionBounce() {
    _pulseController.stop();
    _pulseController.forward(from: 0.0).then((_) {
      _pulseController.reverse();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clamp progress to ensure it's within valid range
    final clampedProgress = _displayProgress.clamp(0.0, 1.0);
    final isComplete = clampedProgress >= 1.0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isComplete ? _scaleAnimation.value : (widget.isAnimating ? _pulseAnimation.value : 1.0);

        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: _displayProgress, end: clampedProgress),
                builder: (context, animatedProgress, child) {
                  return SizedBox(
                    width: widget.size,
                    height: widget.size,
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
                            value: Offset(0, animatedProgress * 100),
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
                          animation: AlwaysStoppedAnimation(animatedProgress),
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _LottieProgressPainter(
                                composition: composition,
                                progress: animatedProgress,
                              ),
                              child: child,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              if (widget.showPercentage) ...[
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  tween: Tween<double>(begin: _displayProgress, end: clampedProgress),
                  builder: (context, animatedProgress, child) {
                    return Text(
                      '${(animatedProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: widget.size * 0.25,
                        fontWeight: FontWeight.w600,
                        color: widget.textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
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

/// A simpler linear progress bar styled with GrabTube colors and shimmer effect.
///
/// Features smooth animated progress transitions, shimmer effect for active downloads,
/// and success animation when reaching 100%.
class GrabTubeLinearProgress extends StatefulWidget {
  /// The progress value from 0.0 (0%) to 1.0 (100%)
  final double progress;

  /// The height of the progress bar
  final double height;

  /// Whether to show the progress percentage as text
  final bool showPercentage;

  /// Optional label to display above the progress bar
  final String? label;

  /// Whether the download is actively progressing (enables shimmer effect)
  final bool isAnimating;

  const GrabTubeLinearProgress({
    required this.progress,
    this.height = 8.0,
    this.showPercentage = true,
    this.label,
    this.isAnimating = false,
    super.key,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');

  @override
  State<GrabTubeLinearProgress> createState() => _GrabTubeLinearProgressState();
}

class _GrabTubeLinearProgressState extends State<GrabTubeLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation controller (continuous)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Shimmer position animation (moves from left to right)
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isAnimating && widget.progress > 0.0 && widget.progress < 1.0) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(GrabTubeLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes
    final shouldAnimate = widget.isAnimating && widget.progress > 0.0 && widget.progress < 1.0;
    final wasAnimating = oldWidget.isAnimating && oldWidget.progress > 0.0 && oldWidget.progress < 1.0;

    if (shouldAnimate != wasAnimating) {
      if (shouldAnimate) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                    child: Stack(
                      children: [
                        // Progress bar
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(begin: clampedProgress, end: clampedProgress),
                          builder: (context, animatedProgress, child) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: constraints.maxWidth * animatedProgress,
                              height: widget.height,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(widget.height / 2),
                              ),
                            );
                          },
                        ),
                        // Shimmer effect overlay
                        if (widget.isAnimating && clampedProgress > 0.0 && clampedProgress < 1.0)
                          AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(widget.height / 2),
                                child: ShaderMask(
                                  shaderCallback: (rect) {
                                    return LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      stops: [
                                        _shimmerAnimation.value - 0.3,
                                        _shimmerAnimation.value,
                                        _shimmerAnimation.value + 0.3,
                                      ].map((e) => e.clamp(0.0, 1.0)).toList(),
                                    ).createShader(rect);
                                  },
                                  child: Container(
                                    width: constraints.maxWidth * clampedProgress,
                                    height: widget.height,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (widget.showPercentage) ...[
              const SizedBox(width: 12),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                tween: Tween<double>(begin: clampedProgress, end: clampedProgress),
                builder: (context, animatedProgress, child) {
                  return SizedBox(
                    width: 45,
                    child: Text(
                      '${(animatedProgress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
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

/// A shimmer loading effect widget for skeleton screens.
///
/// Displays an animated shimmer effect that moves from left to right,
/// perfect for loading states and skeleton screens.
///
/// Example usage:
/// ```dart
/// ShimmerLoading(
///   width: 200,
///   height: 100,
///   borderRadius: 8,
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  /// The width of the shimmer container
  final double? width;

  /// The height of the shimmer container
  final double height;

  /// The border radius of the shimmer container
  final double borderRadius;

  /// Optional child widget to overlay on the shimmer
  final Widget? child;

  const ShimmerLoading({
    this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.child,
    super.key,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      theme.colorScheme.surfaceContainerHighest,
                      theme.colorScheme.surfaceContainerHigh,
                      theme.colorScheme.surfaceContainerHighest,
                    ]
                  : [
                      theme.colorScheme.surfaceContainerHighest,
                      theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
                      theme.colorScheme.surfaceContainerHighest,
                    ],
              stops: [
                (_shimmerAnimation.value - 1.0).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 1.0).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// A wrapper widget that adds smooth entry/exit animations to list items.
///
/// Provides slide-in animation from right and fade-in effect when item appears,
/// and slide-out animation with fade-out when item is removed.
///
/// Example usage:
/// ```dart
/// AnimatedListItem(
///   index: 0,
///   child: ListTile(title: Text('Item')),
/// )
/// ```
class AnimatedListItem extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// The index of the item in the list (used for staggered animation)
  final int index;

  /// The duration of the animation
  final Duration duration;

  const AnimatedListItem({
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 400),
    super.key,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Slide animation (from right to center)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Fade animation (from transparent to opaque)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Stagger animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
