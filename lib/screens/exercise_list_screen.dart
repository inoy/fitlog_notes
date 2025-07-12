import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.lightImpact();
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

  void _showDeleteConfirmation(BuildContext context, Exercise exercise, int index) {
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('確認'),
        content: Text('「${exercise.name}」を削除してもよろしいですか？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pop();
              _removeExercise(index);
              _showDeletedMessage(context, exercise);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showDeletedMessage(BuildContext context, Exercise exercise) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text('「${exercise.name} (${exercise.defaultWorkoutType == WorkoutType.reps ? '回数' : '秒数'})」を削除しました'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('種目管理'),
      ),
      child: SafeArea(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _exerciseNameController,
                        placeholder: '新しい種目名',
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: CupertinoColors.systemGrey4),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    CupertinoButton.filled(
                      onPressed: _addExercise,
                      child: const Text('追加'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _selectedWorkoutType = WorkoutType.reps;
                            });
                          },
                          color: _selectedWorkoutType == WorkoutType.reps 
                              ? CupertinoColors.systemBlue 
                              : CupertinoColors.systemGrey5,
                          child: Text(
                            '回数',
                            style: TextStyle(
                              color: _selectedWorkoutType == WorkoutType.reps 
                                  ? CupertinoColors.white 
                                  : CupertinoColors.label,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _selectedWorkoutType = WorkoutType.seconds;
                            });
                          },
                          color: _selectedWorkoutType == WorkoutType.seconds 
                              ? CupertinoColors.systemBlue 
                              : CupertinoColors.systemGrey5,
                          child: Text(
                            '秒数',
                            style: TextStyle(
                              color: _selectedWorkoutType == WorkoutType.seconds 
                                  ? CupertinoColors.white 
                                  : CupertinoColors.label,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      return CupertinoContextMenu(
                        actions: [
                          CupertinoContextMenuAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                              _showDeleteConfirmation(context, exercise, index);
                            },
                            trailingIcon: CupertinoIcons.delete,
                            child: const Text('削除'),
                          ),
                        ],
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withOpacity(0.2),
                                blurRadius: 2.0,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'タイプ: ${exercise.defaultWorkoutType == WorkoutType.reps ? '回数' : '秒数'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
        ),
      ),
    );
  }
}
