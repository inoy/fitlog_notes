import 'package:fitlog_notes/models/exercise.dart';
import 'package:fitlog_notes/models/weekly_menu_item.dart';
import 'package:fitlog_notes/models/workout_detail.dart';
import 'package:fitlog_notes/models/workout_type.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

// Exercises
final _jumpingJacks = Exercise(id: _uuid.v4(), name: 'ジャンピングジャック', defaultWorkoutType: WorkoutType.seconds);
final _crunches = Exercise(id: _uuid.v4(), name: 'クランチ');
final _absRoller = Exercise(id: _uuid.v4(), name: '腹筋ローラー（膝コロ）');
final _plank = Exercise(id: _uuid.v4(), name: 'プランク', defaultWorkoutType: WorkoutType.seconds);
final _dumbbellPress = Exercise(id: _uuid.v4(), name: 'ダンベルプレス');
final _dumbbellCurl = Exercise(id: _uuid.v4(), name: 'ダンベルカール');
final _dumbbellShoulderPress = Exercise(id: _uuid.v4(), name: 'ダンベルショルダープレス');
final _legRaises = Exercise(id: _uuid.v4(), name: 'レッグレイズ');
final _bicycleCrunches = Exercise(id: _uuid.v4(), name: 'バイシクルクランチ');
final _stretch = Exercise(id: _uuid.v4(), name: 'ストレッチ', defaultWorkoutType: WorkoutType.seconds);
final _squats = Exercise(id: _uuid.v4(), name: 'スクワット');
final _dumbbellSquats = Exercise(id: _uuid.v4(), name: 'ダンベルスクワット');
final _lunges = Exercise(id: _uuid.v4(), name: 'ランジ');

final predefinedExercises = [
  _jumpingJacks,
  _crunches,
  _absRoller,
  _plank,
  _dumbbellPress,
  _dumbbellCurl,
  _dumbbellShoulderPress,
  _legRaises,
  _bicycleCrunches,
  _stretch,
  _squats,
  _dumbbellSquats,
  _lunges,
];

// Weekly Menu
final predefinedWeeklyMenuItems = [
  // Monday
  WeeklyMenuItem(exerciseId: _jumpingJacks.id, dayOfWeek: DateTime.monday, details: [WorkoutDetail(value: 30, type: WorkoutType.seconds)]),
  WeeklyMenuItem(exerciseId: _crunches.id, dayOfWeek: DateTime.monday, details: [WorkoutDetail(value: 15, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _absRoller.id, dayOfWeek: DateTime.monday, details: [WorkoutDetail(value: 8, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _plank.id, dayOfWeek: DateTime.monday, details: [WorkoutDetail(value: 30, type: WorkoutType.seconds)]),
  // Tuesday
  WeeklyMenuItem(exerciseId: _dumbbellPress.id, dayOfWeek: DateTime.tuesday, details: [WorkoutDetail(value: 10, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _dumbbellCurl.id, dayOfWeek: DateTime.tuesday, details: [WorkoutDetail(value: 10, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _dumbbellShoulderPress.id, dayOfWeek: DateTime.tuesday, details: [WorkoutDetail(value: 10, type: WorkoutType.reps)]),
  // Wednesday
  WeeklyMenuItem(exerciseId: _legRaises.id, dayOfWeek: DateTime.wednesday, details: [WorkoutDetail(value: 15, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _plank.id, dayOfWeek: DateTime.wednesday, details: [WorkoutDetail(value: 30, type: WorkoutType.seconds)]),
  WeeklyMenuItem(exerciseId: _stretch.id, dayOfWeek: DateTime.wednesday, details: [WorkoutDetail(value: 300, type: WorkoutType.seconds)]),
  // Thursday
  WeeklyMenuItem(exerciseId: _legRaises.id, dayOfWeek: DateTime.thursday, details: [WorkoutDetail(value: 15, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _bicycleCrunches.id, dayOfWeek: DateTime.thursday, details: [WorkoutDetail(value: 20, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _absRoller.id, dayOfWeek: DateTime.thursday, details: [WorkoutDetail(value: 10, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _plank.id, dayOfWeek: DateTime.thursday, details: [WorkoutDetail(value: 30, type: WorkoutType.seconds)]),
  // Friday
  WeeklyMenuItem(exerciseId: _stretch.id, dayOfWeek: DateTime.friday, details: [WorkoutDetail(value: 300, type: WorkoutType.seconds)]),
  // Saturday
  WeeklyMenuItem(exerciseId: _squats.id, dayOfWeek: DateTime.saturday, details: [WorkoutDetail(value: 20, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _dumbbellSquats.id, dayOfWeek: DateTime.saturday, details: [WorkoutDetail(value: 10, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _lunges.id, dayOfWeek: DateTime.saturday, details: [WorkoutDetail(value: 10, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _plank.id, dayOfWeek: DateTime.saturday, details: [WorkoutDetail(value: 30, type: WorkoutType.seconds)]),
  // Sunday
  WeeklyMenuItem(exerciseId: _squats.id, dayOfWeek: DateTime.sunday, details: [WorkoutDetail(value: 15, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _dumbbellPress.id, dayOfWeek: DateTime.sunday, details: [WorkoutDetail(value: 10, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _bicycleCrunches.id, dayOfWeek: DateTime.sunday, details: [WorkoutDetail(value: 20, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _absRoller.id, dayOfWeek: DateTime.sunday, details: [WorkoutDetail(value: 8, type: WorkoutType.reps)]),
  WeeklyMenuItem(exerciseId: _plank.id, dayOfWeek: DateTime.sunday, details: [WorkoutDetail(value: 30, type: WorkoutType.seconds)]),
];