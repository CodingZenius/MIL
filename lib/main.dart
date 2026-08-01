import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/content_service.dart';
import 'services/activity_service.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final content = ContentService();
  await content.loadInitial();

  runApp(FitPulseApp(storage: storage, content: content));
}

class FitPulseApp extends StatelessWidget {
  final StorageService storage;
  final ContentService content;

  const FitPulseApp({super.key, required this.storage, required this.content});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider<ContentService>.value(value: content),
        ChangeNotifierProvider<ActivityService>(create: (_) => ActivityService()),
      ],
      child: MaterialApp(
        title: 'FitPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: storage.hasProfile
            ? HomeScreen(profile: storage.profile!)
            : const OnboardingScreen(),
      ),
    );
  }
}
