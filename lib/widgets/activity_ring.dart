import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RingMetric {
  final String label;
  final double progress; // 0.0 - 1.0+
  final Color color;
  final String valueText;

  RingMetric({
    required this.label,
    required this.progress,
    required this.color,
    required this.valueText,
  });
}

/// Large multi-ring circular dashboard, in the spirit of a bold Material 3
/// "hero" activity indicator: steps (outer), distance (middle), calories
/// (inner), each an independently animated ring.
class ActivityRing extends StatelessWidget {
  final List<RingMetric> metrics;
  final double size;

  const ActivityRing({super.key, required this.metrics, this.size = 260});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingsPainter(metrics: metrics, animation: t),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                metrics.isNotEmpty ? metrics.first.valueText : '',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: size * 0.16,
                    ),
              ),
              Text(
                metrics.isNotEmpty ? metrics.first.label.toUpperCase() : '',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.mist.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final List<RingMetric> metrics;
  final double animation;

  _RingsPainter({required this.metrics, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;
    const strokeWidth = 18.0;
    const gap = 8.0;

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final radius = maxRadius - (i * (strokeWidth + gap)) - strokeWidth / 2;

      final trackPaint = Paint()
        ..color = metric.color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: 2 * pi,
          colors: [metric.color.withValues(alpha: 0.6), metric.color],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, trackPaint);

      final sweep = 2 * pi * min(metric.progress, 1.0) * animation;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.metrics != metrics;
}
