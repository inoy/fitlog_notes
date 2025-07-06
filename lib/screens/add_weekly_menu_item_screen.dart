import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialItem == null ? '週間メニューを追加' : '週間メニューを編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedExerciseId,
              decoration: const InputDecoration(
                labelText: '種目名',
                border: OutlineInputBorder(),
              ),
              items: _exercises.map((exercise) {
                return DropdownMenuItem(
                  value: exercise.id,
                  child: Text(exercise.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedExerciseId = newValue;
                  if (newValue != null) {
                    final selectedExercise = _exercises.firstWhere((e) => e.id == newValue);
                    _workoutDetails.clear(); // 既存の詳細をクリア
                    _addWorkoutDetail(selectedExercise.defaultWorkoutType);
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '種目を選択してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<int>(
              value: _selectedDayOfWeek,
              decoration: const InputDecoration(
                labelText: '曜日',
                border: OutlineInputBorder(),
              ),
              items: List.generate(7, (index) {
                final day = index + 1;
                return DropdownMenuItem(
                  value: day,
                  child: Text(_getDayName(day)),
                );
              }),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedDayOfWeek = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return '曜日を選択してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            Text('詳細', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: ListView.builder(
                itemCount: _workoutDetails.length,
                itemBuilder: (context, index) {
                  final detail = _workoutDetails[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: detail.value.toString()),
                              decoration: const InputDecoration(
                                labelText: '値',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateWorkoutDetailValue(index, value),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          DropdownButton<WorkoutType>(
                            value: detail.type,
                            items: WorkoutType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type == WorkoutType.reps ? '回' : '秒'),
                              );
                            }).toList(),
                            onChanged: (WorkoutType? newType) {
                              if (newType != null) {
                                _updateWorkoutDetailType(index, newType);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeWorkoutDetail(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedExerciseId != null) {
                  final selectedExercise = _exercises.firstWhere((e) => e.id == _selectedExerciseId);
                  _addWorkoutDetail(selectedExercise.defaultWorkoutType);
                }
              },
              child: const Text('詳細を追加'),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                if (_selectedExerciseId != null && _workoutDetails.isNotEmpty) {
                  final newWeeklyMenuItem = WeeklyMenuItem(
                    exerciseId: _selectedExerciseId!,
                    dayOfWeek: _selectedDayOfWeek!,
                    details: _workoutDetails,
                  );
                  Navigator.pop(context, newWeeklyMenuItem);
                } else {
                  // エラーハンドリング
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
