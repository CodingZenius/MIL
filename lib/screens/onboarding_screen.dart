import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _goal = 'maintain';

  static const _goals = [
    ('lose', 'Lose weight', Icons.trending_down),
    ('maintain', 'Stay healthy', Icons.favorite_outline),
    ('gain', 'Build strength', Icons.trending_up),
    ('endurance', 'Endurance', Icons.directions_run),
  ];

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final height = double.tryParse(_heightCtrl.text) ?? 170;
    final weight = double.tryParse(_weightCtrl.text) ?? 70;
    final profile = UserProfile(
      name: _nameCtrl.text.trim().isEmpty ? 'Athlete' : _nameCtrl.text.trim(),
      heightCm: height,
      weightKg: weight,
      goal: _goal,
    );

    final storage = context.read<StorageService>();
    await storage.saveProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _StepDots(current: _page, total: 3),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _NameStep(controller: _nameCtrl),
                  _MetricsStep(heightCtrl: _heightCtrl, weightCtrl: _weightCtrl),
                  _GoalStep(
                    goals: _goals,
                    selected: _goal,
                    onSelect: (g) => setState(() => _goal = g),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_page < 2 ? 'Continue' : 'Get started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.electricBlue : AppColors.cardBlack,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  const _NameStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome to FitPulse', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            "Let's set things up. What should we call you?",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mist.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              hintText: 'Your name',
              filled: true,
              fillColor: AppColors.cardBlack,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsStep extends StatelessWidget {
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  const _MetricsStep({required this.heightCtrl, required this.weightCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Your metrics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Used only on this device to personalize your calorie estimates.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mist.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 32),
          _NumberField(label: 'Height (cm)', controller: heightCtrl),
          const SizedBox(height: 16),
          _NumberField(label: 'Weight (kg)', controller: weightCtrl),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _NumberField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: AppColors.cardBlack,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  final List<(String, String, IconData)> goals;
  final String selected;
  final ValueChanged<String> onSelect;

  const _GoalStep({
    required this.goals,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('What is your goal?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: goals.map((g) {
              final (key, label, icon) = g;
              final active = key == selected;
              return GestureDetector(
                onTap: () => onSelect(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: active ? AppColors.electricBlue : AppColors.cardBlack,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
