import 'package:flutter/material.dart';
import 'package:fitlog_notes/data/weekly_workout_menu_repository.dart';
import 'package:fitlog_notes/data/exercise_repository.dart';
import 'package:fitlog_notes/models/weekly_menu_item.dart';
import 'package:fitlog_notes/models/exercise.dart';
import 'package:fitlog_notes/models/workout_type.dart';

import 'package:fitlog_notes/screens/add_weekly_menu_item_screen.dart';

class WeeklyMenuScreen extends StatefulWidget {
  const WeeklyMenuScreen({super.key});

  @override
  State<WeeklyMenuScreen> createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends State<WeeklyMenuScreen> {
  final WeeklyWorkoutMenuRepository _weeklyMenuRepository = WeeklyWorkoutMenuRepository();
  final ExerciseRepository _exerciseRepository = ExerciseRepository();
  List<WeeklyMenuItem> _weeklyMenu = [];
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedMenu = await _weeklyMenuRepository.loadWeeklyMenu();
    final loadedExercises = await _exerciseRepository.loadExercises();
    setState(() {
      _weeklyMenu = loadedMenu;
      _exercises = loadedExercises;
    });
  }

  void _addWeeklyMenuItem(WeeklyMenuItem item) {
    setState(() {
      _weeklyMenu.add(item);
    });
    _saveWeeklyMenu();
  }

  Future<void> _saveWeeklyMenu() async {
    await _weeklyMenuRepository.saveWeeklyMenu(_weeklyMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('週間メニュー'),
      ),
      body: Column(
        children: [
          // TODO: 曜日ごとのタブまたはセクション
          Expanded(
            child: ListView.builder(
              itemCount: _weeklyMenu.length,
              itemBuilder: (context, index) {
                final item = _weeklyMenu[index];
                final exercise = _exercises.firstWhere(
                  (e) => e.id == item.exerciseId,
                  orElse: () => Exercise(id: '', name: 'Unknown'),
                );
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_getDayName(item.dayOfWeek)}: ${exercise.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ...item.details.map((detail) => Text(
                            '${detail.value} ${detail.type == WorkoutType.reps ? '回' : '秒'}')).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMenuItem = await Navigator.push<WeeklyMenuItem>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWeeklyMenuItemScreen(),
            ),
          );
          if (newMenuItem != null) {
            _addWeeklyMenuItem(newMenuItem);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return '月曜日';
      case 2: return '火曜日';
      case 3: return '水曜日';
      case 4: return '木曜日';
      case 5: return '金曜日';
      case 6: return '土曜日';
      case 7: return '日曜日';
      default: return '';
    }
  }
}
