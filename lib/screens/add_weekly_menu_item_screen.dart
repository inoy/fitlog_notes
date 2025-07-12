import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fitlog_notes/data/exercise_repository.dart';
import 'package:fitlog_notes/models/exercise.dart';
import 'package:fitlog_notes/models/weekly_menu_item.dart';
import 'package:fitlog_notes/models/workout_detail.dart';
import 'package:fitlog_notes/models/workout_type.dart';

class AddWeeklyMenuItemScreen extends StatefulWidget {
  final WeeklyMenuItem? initialItem;

  const AddWeeklyMenuItemScreen({super.key, this.initialItem});

  @override
  State<AddWeeklyMenuItemScreen> createState() => _AddWeeklyMenuItemScreenState();
}

class _AddWeeklyMenuItemScreenState extends State<AddWeeklyMenuItemScreen> {
  final ExerciseRepository _exerciseRepository = ExerciseRepository();
  List<Exercise> _exercises = [];
  String? _selectedExerciseId;
  int? _selectedDayOfWeek;
  final List<WorkoutDetail> _workoutDetails = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    if (widget.initialItem != null) {
      _selectedExerciseId = widget.initialItem!.exerciseId;
      _selectedDayOfWeek = widget.initialItem!.dayOfWeek;
      _workoutDetails.addAll(widget.initialItem!.details);
    } else {
      _selectedDayOfWeek = DateTime.monday; // デフォルトは月曜日
    }
  }

  Future<void> _loadExercises() async {
    final loadedExercises = await _exerciseRepository.loadExercises();
    setState(() {
      _exercises = loadedExercises;
      if (_selectedExerciseId == null && _exercises.isNotEmpty) {
        _selectedExerciseId = _exercises.first.id;
      }
    });
  }

  void _addWorkoutDetail(WorkoutType defaultType) {
    setState(() {
      _workoutDetails.add(WorkoutDetail(value: 0, type: defaultType));
    });
  }

  void _removeWorkoutDetail(int index) {
    setState(() {
      _workoutDetails.removeAt(index);
    });
  }

  void _updateWorkoutDetailValue(int index, String value) {
    setState(() {
      _workoutDetails[index] = WorkoutDetail(
        value: int.tryParse(value) ?? 0,
        type: _workoutDetails[index].type,
      );
    });
  }

  void _updateWorkoutDetailType(int index, WorkoutType type) {
    setState(() {
      _workoutDetails[index] = WorkoutDetail(
        value: _workoutDetails[index].value,
        type: type,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.initialItem == null ? '週間メニューを追加' : '週間メニューを編集'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('種目名', style: TextStyle(color: CupertinoColors.systemGrey)),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 120.0,
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedExerciseId != null 
                              ? _exercises.indexWhere((e) => e.id == _selectedExerciseId)
                              : 0,
                        ),
                        onSelectedItemChanged: (int index) {
                          if (_exercises.isNotEmpty) {
                            setState(() {
                              _selectedExerciseId = _exercises[index].id;
                              final selectedExercise = _exercises[index];
                              _workoutDetails.clear();
                              _addWorkoutDetail(selectedExercise.defaultWorkoutType);
                            });
                          }
                        },
                        children: _exercises.map((exercise) => Text(exercise.name)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('曜日', style: TextStyle(color: CupertinoColors.systemGrey)),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 120.0,
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        scrollController: FixedExtentScrollController(
                          initialItem: (_selectedDayOfWeek ?? 1) - 1,
                        ),
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedDayOfWeek = index + 1;
                          });
                        },
                        children: List.generate(7, (index) {
                          final day = index + 1;
                          return Text(_getDayName(day));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('詳細', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Expanded(
                child: ListView.builder(
                  itemCount: _workoutDetails.length,
                  itemBuilder: (context, index) {
                    final detail = _workoutDetails[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: TextEditingController(text: detail.value.toString()),
                              placeholder: '値',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateWorkoutDetailValue(index, value),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            onPressed: () {
                              final newType = detail.type == WorkoutType.reps
                                  ? WorkoutType.seconds
                                  : WorkoutType.reps;
                              _updateWorkoutDetailType(index, newType);
                            },
                            child: Text(detail.type == WorkoutType.reps ? '回' : '秒'),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _removeWorkoutDetail(index),
                            child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  if (_selectedExerciseId != null) {
                    final selectedExercise = _exercises.firstWhere((e) => e.id == _selectedExerciseId);
                    _addWorkoutDetail(selectedExercise.defaultWorkoutType);
                  }
                },
                child: const Text('詳細を追加', style: TextStyle(color: CupertinoColors.systemBlue)),
              ),
              const SizedBox(height: 32.0),
              CupertinoButton.filled(
                onPressed: () {
                  if (_selectedExerciseId != null && _workoutDetails.isNotEmpty && _selectedDayOfWeek != null) {
                    HapticFeedback.lightImpact();
                    final newWeeklyMenuItem = WeeklyMenuItem(
                      exerciseId: _selectedExerciseId!,
                      dayOfWeek: _selectedDayOfWeek!,
                      details: _workoutDetails,
                    );
                    Navigator.pop(context, newWeeklyMenuItem);
                  } else {
                    HapticFeedback.heavyImpact();
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}