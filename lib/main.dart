import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage — habits are persisted as JSON strings in a Hive box.
  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.habitsBox);
  await Hive.openBox<String>(AppConstants.settingsBox);

  // Notifications (safe to init early; permission is requested lazily).
  await NotificationService.instance.init();

  runApp(const HabitFlowApp());
}
