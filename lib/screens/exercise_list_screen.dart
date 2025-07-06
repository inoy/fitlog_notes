import 'package:flutter/material.dart';
import 'package:fitlog_notes/data/exercise_repository.dart';
import 'package:fitlog_notes/models/exercise.dart';
import 'package:fitlog_notes/models/workout_type.dart';
import 'package:uuid/uuid.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ExerciseRepository _repository = ExerciseRepository();
  List<Exercise> _exercises = [];
  final TextEditingController _exerciseNameController = TextEditingController();
  WorkoutType _selectedWorkoutType = WorkoutType.reps; // デフォルトは回数
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final loadedExercises = await _repository.loadExercises();
    setState(() {
      _exercises = loadedExercises;
    });
  }

  Future<void> _addExercise() async {
    if (_exerciseNameController.text.isEmpty) {
      return;
    }
    final newExercise = Exercise(
      id: _uuid.v4(),
      name: _exerciseNameController.text,
      defaultWorkoutType: _selectedWorkoutType,
    );
    setState(() {
      _exercises.add(newExercise);
      _exerciseNameController.clear();
      _selectedWorkoutType = WorkoutType.reps; // 追加後リセット
    });
    await _repository.saveExercises(_exercises);
  }

  Future<void> _removeExercise(int index) async {
    setState(() {
      _exercises.removeAt(index);
    });
    await _repository.saveExercises(_exercises);
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('種目管理'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _exerciseNameController,
                        decoration: const InputDecoration(
                          labelText: '新しい種目名',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _addExercise,
                      child: const Text('追加'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<WorkoutType>(
                        title: const Text('回数'),
                        value: WorkoutType.reps,
                        groupValue: _selectedWorkoutType,
                        onChanged: (WorkoutType? value) {
                          setState(() {
                            _selectedWorkoutType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<WorkoutType>(
                        title: const Text('秒数'),
                        value: WorkoutType.seconds,
                        groupValue: _selectedWorkoutType,
                        onChanged: (WorkoutType? value) {
                          setState(() {
                            _selectedWorkoutType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _exercises.isEmpty
                ? const Center(child: Text('登録されている種目がありません。'))
                : ListView.builder(
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return Dismissible(
                        key: ValueKey(exercise.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeExercise(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                '「${exercise.name} (${exercise.defaultWorkoutType == WorkoutType.reps ? '回数' : '秒数'})」を削除しました')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(
                                'タイプ: ${exercise.defaultWorkoutType == WorkoutType.reps ? '回数' : '秒数'}'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
