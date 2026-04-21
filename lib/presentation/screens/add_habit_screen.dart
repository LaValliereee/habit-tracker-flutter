import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/habit_provider.dart';
import '../../../data/models/habit_model.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController targetController = TextEditingController();

  List<int> selectedDays = [];
  TimeOfDay? selectedTime;

  void saveHabit() async {
    final name = nameController.text.trim();
    final target = int.tryParse(targetController.text) ?? 1;

    if (name.isEmpty ||
        selectedDays.isEmpty ||
        target <= 0 ||
        selectedTime == null)
      return;

    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      targetCount: target,
      scheduledDays: selectedDays,
      createdAt: DateTime.now(),
      reminderHour: selectedTime!.hour,
      reminderMinute: selectedTime!.minute,
    );

    await ref.read(habitListProvider.notifier).addHabit(habit);

    if (mounted) Navigator.pop(context);
  }

  Widget buildDaySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Wrap(
      spacing: 8,
      children: List.generate(days.length, (index) {
        final dayValue = index + 1;

        final isSelected = selectedDays.contains(dayValue);

        return ChoiceChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              if (isSelected) {
                selectedDays.remove(dayValue);
              } else {
                selectedDays.add(dayValue);
              }
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Habit Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Count'),
            ),
            const SizedBox(height: 16),
            buildDaySelector(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: Text(
                selectedTime == null
                    ? 'Pick Reminder Time'
                    : 'Time: ${selectedTime!.format(context)}',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: saveHabit,
              child: const Text('Save Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
