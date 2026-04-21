import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int targetCount;

  @HiveField(3)
  List<int> scheduledDays; // 1-7 (DateTime.weekday)

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int reminderHour;

  @HiveField(6)
  int reminderMinute;

  Habit({
    required this.id,
    required this.name,
    required this.targetCount,
    required this.scheduledDays,
    required this.createdAt,
    required this.reminderHour,
    required this.reminderMinute,
  });
}
