import 'package:fitlog_notes/models/workout_type.dart';

class Exercise {
  final String id;
  final String name;
  final WorkoutType defaultWorkoutType;

  Exercise({
    required this.id,
    required this.name,
    this.defaultWorkoutType = WorkoutType.reps, // デフォルトは回数
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defaultWorkoutType': defaultWorkoutType.toString().split('.').last,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        defaultWorkoutType: WorkoutType.values.firstWhere(
          (e) => e.toString().split('.').last == json['defaultWorkoutType'] as String,
          orElse: () => WorkoutType.reps, // 互換性のため
        ),
      );
}
