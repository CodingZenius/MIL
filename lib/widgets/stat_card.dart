import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rectangular detail card used for secondary stats (pace, hydration ml,
/// macros, etc.) — pairs with the circular ActivityRing on the dashboard.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accent = AppColors.electricBlue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBlack,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mist.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable rotating-tip card: concise at a glance, expands for full body.
class TipCardWidget extends StatefulWidget {
  final String title;
  final String summary;
  final String body;
  final Color accent;

  const TipCardWidget({
    super.key,
    required this.title,
    required this.summary,
    required this.body,
    this.accent = AppColors.pulseRed,
  });

  @override
  State<TipCardWidget> createState() => _TipCardWidgetState();
}

class _TipCardWidgetState extends State<TipCardWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.accent.withValues(alpha: 0.25)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.mist.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _expanded ? widget.body : widget.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mist.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
