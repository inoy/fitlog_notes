import 'package:flutter/cupertino.dart';
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('週間メニュー'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _weeklyMenu.isEmpty
                  ? const Center(
                      child: Text(
                        '週間メニューがありません。\n下のボタンから追加してください。',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _weeklyMenu.length,
                      itemBuilder: (context, index) {
                        final item = _weeklyMenu[index];
                        final exercise = _exercises.firstWhere(
                          (e) => e.id == item.exerciseId,
                          orElse: () => Exercise(id: '', name: 'Unknown'),
                        );
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getDayName(item.dayOfWeek)}: ${exercise.name}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ...item.details.map(
                                (detail) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${detail.value} ${detail.type == WorkoutType.reps ? '回' : '秒'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoButton.filled(
                onPressed: () async {
                  final newMenuItem = await Navigator.push<WeeklyMenuItem>(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AddWeeklyMenuItemScreen(),
                    ),
                  );
                  if (newMenuItem != null) {
                    _addWeeklyMenuItem(newMenuItem);
                  }
                },
                child: const Text('メニューを追加'),
              ),
            ),
          ],
        ),
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
