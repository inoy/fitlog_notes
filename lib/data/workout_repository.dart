import 'package:shared_preferences/shared_preferences.dart';

class WorkoutRepository {
  static const _keyWorkouts = 'workouts';

  Future<void> saveWorkouts(List<String> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWorkouts, workouts);
  }

  Future<List<String>> loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyWorkouts) ?? [];
  }
}
