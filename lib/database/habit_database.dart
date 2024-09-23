import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingSchema], directory: dir.path);
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final setting = AppSetting()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(setting));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final launchDate = await isar.appSettings.where().findFirst();
    return launchDate?.firstLaunchDate;
  }

  final List<Habit> currentHabits = [];

  //create
  Future<void> addHabit(String userText) async {
    final habit = Habit()..name = userText;

    await isar.writeTxn(() => isar.habits.put(habit));

    readHabits();
  }

  Future<void> readHabits() async {
    List<Habit> result = await isar.habits.where().findAll();

    currentHabits.clear();
    currentHabits.addAll(result);

    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          habit.completedDays.add(
            DateTime(today.year, today.month, today.day),
          );
        } else {
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        await isar.habits.put(habit);
      });
      readHabits();
    }
  }

  Future<void> updateHabitName(int id, String updatedText) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = updatedText;
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    readHabits();
  }
}
