import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class NutritionScreen extends StatelessWidget {
  final UserProfile profile;
  const NutritionScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentService>();
    final tips = content.byCategory('nutrition');
    final target = profile.dailyCalorieBurn;
    // Rough macro split, purely illustrative (not medical advice).
    final proteinG = (profile.weightKg * 1.6).round();
    final carbsKcal = target * 0.45;
    final fatKcal = target * 0.30;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBlack,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily target',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mist.withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${target.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 44),
                ),
                Text(
                  'Estimated from your height, weight, and goal (${profile.goal}).',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mist.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.egg_alt_outlined,
                  label: 'Protein target',
                  value: '${proteinG}g',
                  accent: AppColors.pulseRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.rice_bowl_outlined,
                  label: 'Carb budget',
                  value: '${carbsKcal.toStringAsFixed(0)} kcal',
                  accent: AppColors.electricBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatCard(
            icon: Icons.opacity_outlined,
            label: 'Fat budget',
            value: '${fatKcal.toStringAsFixed(0)} kcal',
            accent: AppColors.emberRed,
          ),
          const SizedBox(height: 28),
          Text('Nutrition tips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TipCardWidget(
                title: t.title,
                summary: t.summary,
                body: t.body,
                accent: AppColors.pulseRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
