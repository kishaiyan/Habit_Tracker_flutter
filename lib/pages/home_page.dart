import 'package:flutter/material.dart';
import 'package:habit_tracker/components/drawer_custom.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/utils/habit_utils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  void handleAddHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add A Habit"),
              content: TextField(
                controller: textController,
                decoration: InputDecoration(hintText: "Exercise"),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabit = textController.text;
                    context.read<HabitDatabase>().addHabit(newHabit);
                    textController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    textController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                )
              ],
            ));
  }

  void handleChange(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabit(Habit habit) {
    textController.text = habit.name;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Update the Habit"),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      context
                          .read<HabitDatabase>()
                          .updateHabitName(habit.id, textController.text);
                      textController.clear();
                      Navigator.pop(context);
                    },
                    child: Text("Save")),
                MaterialButton(
                  onPressed: () {
                    textController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                )
              ],
            ));
  }

  void deleteHabit(Habit habit) {
    context.read<HabitDatabase>().deleteHabit(habit.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("sample"),
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: handleAddHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          //Calendar heatMap
          _buildHeatMap(),
          //HabitList tile
          _buildHabitList(),
        ],
      ),
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHeatMap(
                startTime: snapshot.data!,
                datasets: prepHeatMapDataset(currentHabits));
          } else {
            return Container();
          }
        });
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          final habit = currentHabits[index];

          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          return HabitTile(
              isCompleted: isCompletedToday,
              text: habit.name,
              editHabit: (context) => editHabit(habit),
              deleteHabit: (context) => deleteHabit(habit),
              onChanged: (value) => handleChange(value, habit));
        });
  }
}
