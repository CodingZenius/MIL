import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double heightCm;

  @HiveField(2)
  double weightKg;

  @HiveField(3)
  String goal; // 'lose', 'maintain', 'gain', 'endurance'

  @HiveField(4)
  int age;

  @HiveField(5)
  String sex; // 'male', 'female', 'other' -> affects BMR formula slightly

  @HiveField(6)
  bool onboarded;

  UserProfile({
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    this.age = 30,
    this.sex = 'other',
    this.onboarded = true,
  });

  /// Mifflin-St Jeor BMR estimate, then scaled by an activity factor.
  double get bmr {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    switch (sex) {
      case 'male':
        return base + 5;
      case 'female':
        return base - 161;
      default:
        return base - 78; // averaged offset for 'other'
    }
  }

  /// Estimated total daily calorie burn (moderately active multiplier),
  /// nudged by the user's goal.
  double get dailyCalorieBurn {
    const activityFactor = 1.55; // moderately active baseline
    double total = bmr * activityFactor;
    switch (goal) {
      case 'lose':
        total *= 1.05; // slightly higher target to encourage a deficit via intake
        break;
      case 'gain':
        total *= 0.95;
        break;
      case 'endurance':
        total *= 1.15;
        break;
    }
    return total;
  }

  /// Rough calories burned per km walked/run, from weight (a widely used estimate).
  double get caloriesPerKm => weightKg * 1.036;
}
