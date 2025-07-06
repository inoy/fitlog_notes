import 'package:fitlog_notes/models/workout_detail.dart';

class WeeklyMenuItem {
  final String exerciseId;
  final int dayOfWeek; // DateTime.monday, DateTime.tuesday など
  final List<WorkoutDetail> details;

  WeeklyMenuItem({
    required this.exerciseId,
    required this.dayOfWeek,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'dayOfWeek': dayOfWeek,
    'details': details.map((d) => d.toJson()).toList(),
  };

  factory WeeklyMenuItem.fromJson(Map<String, dynamic> json) => WeeklyMenuItem(
    exerciseId: json['exerciseId'] as String,
    dayOfWeek: json['dayOfWeek'] as int,
    details: (json['details'] as List)
        .map((d) => WorkoutDetail.fromJson(d as Map<String, dynamic>))
        .toList(),
  );
}
