import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/habit_model.dart';
import '../../data/services/habit_repository.dart';
import '../../data/services/notification_service.dart';
import '../../core/utils/streak_helper.dart';

final habitRepositoryProvider = Provider((ref) {
  return HabitRepository();
});

final habitListProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((
  ref,
) {
  final repo = ref.read(habitRepositoryProvider);
  return HabitNotifier(repo);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HabitRepository repository;

  HabitNotifier(this.repository) : super([]) {
    loadHabits();
  }

  void loadHabits() {
    state = repository.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    await repository.addHabit(habit);
    if (!kIsWeb) {
      await NotificationService.scheduleDailyNotification(
        id: habit.hashCode,
        title: habit.name,
        body: 'Don\'t forget your habit today!',
        hour: habit.reminderHour,
        minute: habit.reminderMinute,
      );
    }
    loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await repository.deleteHabit(id);
    loadHabits();
  }

  Future<void> incrementHabit(String habitId, int target) async {
    await repository.incrementProgress(habitId, target);

    // trigger rebuild
    state = [...state];
    loadHabits();
  }

  Future<int> getTodayProgress(String habitId) async {
    final today = DateTime.now();
    final log = await repository.getLogForDate(habitId, today);

    return log?.progressCount ?? 0;
  }

  Future<int> getHabitStreak(Habit habit) async {
    final logs = repository.getLogsByHabit(habit.id);

    return StreakHelper.calculateStreak(
      logs: logs,
      scheduledDays: habit.scheduledDays,
    );
  }

  Future<int> getWeeklyCompletion(Habit habit) async {
    final logs = repository.getLast7DaysLogs(habit.id);

    int completedDays = logs.where((log) => log.isCompleted).length;

    return completedDays;
  }
}
