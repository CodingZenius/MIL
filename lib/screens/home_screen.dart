import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/activity_service.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_ring.dart';
import '../widgets/stat_card.dart';
import 'running_screen.dart';
import 'hydration_screen.dart';
import 'nutrition_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile profile;
  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _autoLaunchedRunMode = false;

  // Placeholder daily progress; in a full build these would come from a
  // pedometer/HealthKit/Health Connect integration alongside ActivityService.
  int _steps = 4820;
  double _distanceKm = 3.4;
  int _calories = 310;

  static const int _stepGoal = 10000;
  static const double _distanceGoal = 8.0;
  static const int _calorieGoal = 600;

  @override
  void initState() {
    super.initState();
    context.read<ActivityService>().start();
  }

  void _maybeAutoEnterRunMode(ActivityState state) {
    if (state == ActivityState.running && !_autoLaunchedRunMode) {
      _autoLaunchedRunMode = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RunningScreen(profile: widget.profile),
          ),
        );
      });
    } else if (state != ActivityState.running) {
      _autoLaunchedRunMode = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityService>();
    _maybeAutoEnterRunMode(activity.state);

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _DashboardPage(
              profile: widget.profile,
              steps: _steps,
              distanceKm: _distanceKm,
              calories: _calories,
              stepGoal: _stepGoal,
              distanceGoal: _distanceGoal,
              calorieGoal: _calorieGoal,
              onOpenRunning: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RunningScreen(profile: widget.profile),
                ),
              ),
            ),
            const HydrationScreen(),
            NutritionScreen(profile: widget.profile),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final active = i == _page;
            return GestureDetector(
              onTap: () => _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: active ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.electricBlue : AppColors.cardBlack,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  final UserProfile profile;
  final int steps;
  final double distanceKm;
  final int calories;
  final int stepGoal;
  final double distanceGoal;
  final int calorieGoal;
  final VoidCallback onOpenRunning;

  const _DashboardPage({
    required this.profile,
    required this.steps,
    required this.distanceKm,
    required this.calories,
    required this.stepGoal,
    required this.distanceGoal,
    required this.calorieGoal,
    required this.onOpenRunning,
  });

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentService>();
    final tip = content.todaysTip;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, ${profile.name}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Daily burn target: ${profile.dailyCalorieBurn.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mist.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                ),
              ],
            ),
            IconButton.filledTonal(
              onPressed: onOpenRunning,
              icon: const Icon(Icons.directions_run),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Center(
          child: ActivityRing(
            metrics: [
              RingMetric(
                label: 'Steps',
                progress: steps / stepGoal,
                color: AppColors.electricBlue,
                valueText: '$steps',
              ),
              RingMetric(
                label: 'Distance',
                progress: distanceKm / distanceGoal,
                color: AppColors.pulseRed,
                valueText: '${distanceKm.toStringAsFixed(1)} km',
              ),
              RingMetric(
                label: 'Calories',
                progress: calories / calorieGoal,
                color: Colors.amber,
                valueText: '$calories kcal',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.directions_walk,
                label: 'Steps today',
                value: '$steps',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.route,
                label: 'Distance',
                value: '${distanceKm.toStringAsFixed(1)} km',
                accent: AppColors.pulseRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          icon: Icons.local_fire_department,
          label: 'Calories burned',
          value: '$calories kcal',
          accent: Colors.amber.shade700,
        ),
        const SizedBox(height: 28),
        Text("Today's tip", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (tip != null)
          TipCardWidget(
            title: tip.title,
            summary: tip.summary,
            body: tip.body,
          )
        else
          const SizedBox.shrink(),
        const SizedBox(height: 8),
        Text(
          'Swipe left for hydration and nutrition →',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mist.withValues(alpha: 0.4),
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
