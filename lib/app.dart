import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/services/settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/habit_repository.dart';
import 'features/habits/controller/habit_controller.dart';
import 'features/splash/screens/splash_screen.dart';

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitController(HabitRepository())),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
