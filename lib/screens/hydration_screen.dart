import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _mlToday = 0;
  static const _goalMl = 2500;

  void _addWater(int ml) {
    setState(() => _mlToday = (_mlToday + ml).clamp(0, 6000));
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentService>();
    final tips = content.byCategory('hydration');
    final progress = (_mlToday / _goalMl).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Hydration')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 16,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.electricBlue.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.electricBlue),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$_mlToday ml', style: Theme.of(context).textTheme.headlineMedium),
                      Text(
                        'of $_goalMl ml goal',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mist.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.local_drink,
                  label: 'Add 250ml',
                  value: 'Glass',
                  accent: AppColors.electricBlue,
                  onTap: () => _addWater(250),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.sports_bar,
                  label: 'Add 500ml',
                  value: 'Bottle',
                  accent: AppColors.electricBlue,
                  onTap: () => _addWater(500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Hydration tips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TipCardWidget(
                title: t.title,
                summary: t.summary,
                body: t.body,
                accent: AppColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
