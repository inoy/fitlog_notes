import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
  final PageController _pageController = PageController();
  int _currentDayIndex = DateTime.now().weekday - 1; // 0-6のインデックス

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int get _currentDay => _currentDayIndex + 1;


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
      navigationBar: CupertinoNavigationBar(
        middle: Text(_getDayName(_currentDay)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final newMenuItem = await Navigator.push<WeeklyMenuItem>(
              context,
              CupertinoPageRoute(
                builder: (context) => AddWeeklyMenuItemScreen(initialDay: _currentDay),
              ),
            );
            if (newMenuItem != null) {
              _addWeeklyMenuItem(newMenuItem);
            }
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 曜日インジケーター
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final dayOfWeek = index + 1;
                  final isSelected = dayOfWeek == _currentDay;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _animateToDay(index);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? CupertinoColors.systemBlue 
                          : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _getDayShortName(dayOfWeek),
                          style: TextStyle(
                            color: isSelected 
                              ? CupertinoColors.white 
                              : CupertinoColors.label,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // 曜日別メニューカード
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 300) {
                    // 右へのスワイプ → 前の日
                    _moveToPreviousDay();
                  } else if (details.primaryVelocity! < -300) {
                    // 左へのスワイプ → 次の日
                    _moveToNextDay();
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: child,
                    );
                  },
                  child: _buildDayCard(),
                ),
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

  String _getDayShortName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return '月';
      case 2: return '火';
      case 3: return '水';
      case 4: return '木';
      case 5: return '金';
      case 6: return '土';
      case 7: return '日';
      default: return '';
    }
  }

  void _animateToDay(int targetDayIndex) {
    setState(() {
      _currentDayIndex = targetDayIndex;
    });
  }

  void _moveToNextDay() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentDayIndex = (_currentDayIndex + 1) % 7; // 0-6でループ
    });
  }

  void _moveToPreviousDay() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentDayIndex = (_currentDayIndex - 1 + 7) % 7; // 0-6でループ
    });
  }

  Widget _buildDayCard() {
    final dayOfWeek = _currentDay;
    final todaysMenu = _weeklyMenu
        .where((item) => item.dayOfWeek == dayOfWeek)
        .toList();
    
    return DayMenuCard(
      key: ValueKey(_currentDayIndex), // AnimatedSwitcherのため
      dayOfWeek: dayOfWeek,
      menu: todaysMenu,
      exercises: _exercises,
      onAddMenu: () async {
        final newMenuItem = await Navigator.push<WeeklyMenuItem>(
          context,
          CupertinoPageRoute(
            builder: (context) => AddWeeklyMenuItemScreen(initialDay: dayOfWeek),
          ),
        );
        if (newMenuItem != null) {
          _addWeeklyMenuItem(newMenuItem);
        }
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class DayMenuCard extends StatelessWidget {
  final int dayOfWeek;
  final List<WeeklyMenuItem> menu;
  final List<Exercise> exercises;
  final VoidCallback onAddMenu;

  const DayMenuCard({
    super.key,
    required this.dayOfWeek,
    required this.menu,
    required this.exercises,
    required this.onAddMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (menu.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.calendar_badge_plus,
                      size: 64,
                      color: CupertinoColors.systemGrey3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'この日のメニューは\nまだ設定されていません',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      onPressed: onAddMenu,
                      child: const Text('メニューを追加'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: menu.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = menu[index];
                  final exercise = exercises.firstWhere(
                    (e) => e.id == item.exerciseId,
                    orElse: () => Exercise(id: '', name: 'Unknown'),
                  );
                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ...item.details.map(
                          (detail) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  detail.type == WorkoutType.reps 
                                    ? CupertinoIcons.repeat 
                                    : CupertinoIcons.timer,
                                  size: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${detail.value} ${detail.type == WorkoutType.reps ? '回' : '秒'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (menu.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CupertinoButton(
                onPressed: onAddMenu,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.add, size: 20),
                    SizedBox(width: 8),
                    Text('メニューを追加'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
