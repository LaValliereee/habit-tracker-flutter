import 'package:hive/hive.dart';

part 'habit_log_model.g.dart';

@HiveType(typeId: 1)
class HabitLog extends HiveObject {
  @HiveField(0)
  String habitId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int progressCount;

  @HiveField(3)
  bool isCompleted;

  HabitLog({
    required this.habitId,
    required this.date,
    required this.progressCount,
    required this.isCompleted,
  });
}