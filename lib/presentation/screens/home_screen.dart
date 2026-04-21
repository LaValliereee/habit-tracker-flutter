import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import 'add_habit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.track_changes, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Start building your habits 🚀',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: FutureBuilder<int>(
                    key: ValueKey(habit.id + habits.length.toString()),
                    future: ref
                        .watch(habitListProvider.notifier)
                        .getTodayProgress(habit.id),
                    builder: (context, snapshot) {
                      final progress = snapshot.data ?? 0;
                      final isCompleted = progress >= habit.targetCount;
                      final percent = (progress / habit.targetCount).clamp(
                        0.0,
                        1.0,
                      );

                      return ListTile(
                        title: Text(
                          habit.name,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$progress / ${habit.targetCount}'),

                            const SizedBox(height: 6),

                            SizedBox(
                              height: 60,
                              width: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: percent,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: const AlwaysStoppedAnimation(
                                      Colors.deepPurple,
                                    ),
                                  ),
                                  Text(
                                    '${(percent * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            FutureBuilder<int>(
                              future: ref
                                  .watch(habitListProvider.notifier)
                                  .getHabitStreak(habit),
                              builder: (context, snapshot) {
                                final streak = snapshot.data ?? 0;

                                return Text(
                                  '🔥 Streak: $streak days',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            FutureBuilder<int>(
                              future: ref
                                  .watch(habitListProvider.notifier)
                                  .getWeeklyCompletion(habit),
                              builder: (context, snapshot) {
                                final weekly = snapshot.data ?? 0;

                                return Text(
                                  '📊 This week: $weekly/7 days',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: progress >= habit.targetCount
                                  ? null
                                  : () {
                                      ref
                                          .read(habitListProvider.notifier)
                                          .incrementHabit(
                                            habit.id,
                                            habit.targetCount,
                                          );
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref
                                    .read(habitListProvider.notifier)
                                    .deleteHabit(habit.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
