import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showAddTaskDialog(BuildContext context, Box<Task> box) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter task title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              final newTask = Task(
                id: DateTime.now().toString(),
                title: controller.text.trim(),
                createdAt: DateTime.now(),
              );

              await box.put(newTask.id, newTask);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>('tasks_box');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 118, 159, 248),
              Color.fromARGB(255, 187, 178, 245),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// HEADER
                const Text(
                  "Let's Do This!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "No excuses. Just action. 🔥",
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),

                const SizedBox(height: 20),

                /// DYNAMIC SECTION
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<Task> box, _) {
                      final tasks = box.values.toList();

                      final today = DateTime.now();
                      final todayTasks = tasks.where((task) {
                        return task.createdAt.year == today.year &&
                            task.createdAt.month == today.month &&
                            task.createdAt.day == today.day;
                      }).toList();

                      final completedToday = todayTasks
                          .where((task) => task.isCompleted)
                          .length;

                      final percentToday = todayTasks.isEmpty
                          ? 0
                          : ((completedToday / todayTasks.length) * 100)
                                .round();
                      final todayString =
                          "${today.year}-${today.month}-${today.day}";
                      if (percentToday == 100 && todayTasks.isNotEmpty) {
                        if (lastCompletedDate != todayString) {
                          streak += 1;
                          lastCompletedDate = todayString;
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setInt('streak', streak);
                            prefs.setString('lastCompletedDate', todayString);
                          });
                        }
                      }

                      return Column(
                        children: [
                          /// DASHBOARD
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "🔥 1 Day Streak",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "🎯 $percentToday% Today",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// TASK LIST
                          Expanded(
                            child: tasks.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No tasks yet.\nTap + to add what you remembered!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                task.isCompleted =
                                                    !task.isCompleted;
                                                await task.save();
                                              },
                                              child: Container(
                                                width: 26,
                                                height: 26,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                  color: task.isCompleted
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                ),
                                                child: task.isCompleted
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: Color(
                                                          0xFF6D5DF6,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  decoration: task.isCompleted
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async =>
                                                  await task.delete(),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _showAddTaskDialog(context, box),
        icon: const Icon(Icons.add, color: Color.fromARGB(255, 118, 159, 248)),
        label: const Text("Remembered something?"),
      ),
    );
  }
}
