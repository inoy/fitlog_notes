import 'package:fitlog_notes/models/workout_type.dart';

class WorkoutDetail {
  final int value;
  final WorkoutType type;

  WorkoutDetail({
    required this.value,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'type': type.toString().split('.').last, // Enumを文字列として保存
  };

  factory WorkoutDetail.fromJson(Map<String, dynamic> json) => WorkoutDetail(
    value: json['value'] as int,
    type: WorkoutType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'] as String,
    ),
  );
}
