import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(HabitLogAdapter());

    await Hive.openBox<Habit>('habits');
    await Hive.openBox<HabitLog>('habit_logs');
  }
}