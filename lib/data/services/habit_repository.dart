import 'package:hive/hive.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';

class HabitRepository {
  final Box<Habit> habitBox = Hive.box<Habit>('habits');
  final Box<HabitLog> logBox = Hive.box<HabitLog>('habit_logs');
  String _generateKey(String habitId, DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${habitId}_${normalized.toIso8601String()}';
  }

  List<Habit> getHabits() {
    return habitBox.values.toList();
  }

  List<HabitLog> getLast7DaysLogs(String habitId) {
    final now = DateTime.now();

    return logBox.values.where((log) {
      final diff = now.difference(log.date).inDays;
      return log.habitId == habitId && diff >= 0 && diff < 7;
    }).toList();
  }

  Future<void> addHabit(Habit habit) async {
    await habitBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await habitBox.delete(id);
  }

  List<HabitLog> getLogsByHabit(String habitId) {
    return logBox.values.where((log) => log.habitId == habitId).toList();
  }

  Future<void> saveLog(HabitLog log) async {
    final key = '${log.habitId}_${log.date.toIso8601String()}';
    await logBox.put(key, log);
  }

  Future<HabitLog?> getLogForDate(String habitId, DateTime date) async {
    final key = '${habitId}_${date.toIso8601String()}';
    return logBox.get(key);
  }

  Future<void> incrementProgress(String habitId, int target) async {
    final today = DateTime.now();
    final key = _generateKey(habitId, today);

    final existing = logBox.get(key);

    if (existing != null) {
      existing.progressCount += 1;
      existing.isCompleted = existing.progressCount >= target;
      await existing.save();
    } else {
      final log = HabitLog(
        habitId: habitId,
        date: today,
        progressCount: 1,
        isCompleted: target <= 1,
      );

      await logBox.put(key, log);
    }
  }
}
