import '../../data/models/habit_log_model.dart';
import 'date_utils.dart';

class StreakHelper {
  static int calculateStreak({
    required List<HabitLog> logs,
    required List<int> scheduledDays,
  }) {
    if (logs.isEmpty) return 0;

    // sort descending (latest first)
    logs.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateUtilsHelper.normalize(DateTime.now());

    while (true) {
      // cek apakah hari ini termasuk scheduled
      if (!scheduledDays.contains(currentDate.weekday)) {
        currentDate = currentDate.subtract(const Duration(days: 1));
        continue;
      }

      // cari log di tanggal ini
      final log = logs.firstWhere(
        (l) => DateUtilsHelper.isSameDay(l.date, currentDate),
        orElse: () => HabitLog(
          habitId: '',
          date: currentDate,
          progressCount: 0,
          isCompleted: false,
        ),
      );

      if (!log.isCompleted) {
        break;
      }

      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}