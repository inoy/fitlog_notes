import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitlog_notes/models/streak_data.dart';

class StreakRepository {
  static const _keyStreakData = 'streak_data';

  Future<void> saveStreakData(StreakData streakData) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(streakData.toJson());
    await prefs.setString(_keyStreakData, encoded);
  }

  Future<StreakData> loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_keyStreakData);
    if (encoded == null) {
      return StreakData.empty;
    }
    return StreakData.fromJson(jsonDecode(encoded));
  }

  Future<StreakData> updateStreakWithNewWorkout(DateTime workoutDate) async {
    final currentStreak = await loadStreakData();
    final workoutDateOnly = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
    
    int newCurrentStreak;
    int newLongestStreak = currentStreak.longestStreak;
    
    if (currentStreak.lastWorkoutDate == null) {
      // 初回ワークアウト
      newCurrentStreak = 1;
    } else {
      final lastWorkoutDateOnly = DateTime(
        currentStreak.lastWorkoutDate!.year,
        currentStreak.lastWorkoutDate!.month,
        currentStreak.lastWorkoutDate!.day,
      );
      
      final daysDifference = workoutDateOnly.difference(lastWorkoutDateOnly).inDays;
      
      if (daysDifference == 0) {
        // 同じ日の場合はストリークを変更しない
        newCurrentStreak = currentStreak.currentStreak;
      } else if (daysDifference == 1) {
        // 連続している場合
        newCurrentStreak = currentStreak.currentStreak + 1;
      } else {
        // ストリークが途切れた場合
        newCurrentStreak = 1;
      }
    }
    
    // 最長ストリークの更新
    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }
    
    final updatedStreak = StreakData(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastWorkoutDate: workoutDateOnly,
      totalWorkouts: currentStreak.totalWorkouts + 1,
    );
    
    await saveStreakData(updatedStreak);
    return updatedStreak;
  }

  Future<int> getDaysSinceLastWorkout() async {
    final streakData = await loadStreakData();
    if (streakData.lastWorkoutDate == null) {
      return 0;
    }
    
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final lastWorkoutDateOnly = DateTime(
      streakData.lastWorkoutDate!.year,
      streakData.lastWorkoutDate!.month,
      streakData.lastWorkoutDate!.day,
    );
    
    return todayOnly.difference(lastWorkoutDateOnly).inDays;
  }

  Future<bool> isStreakAtRisk() async {
    final daysSince = await getDaysSinceLastWorkout();
    return daysSince >= 1; // 1日以上空いたらリスク
  }

  Future<bool> hasWorkedOutToday() async {
    final daysSince = await getDaysSinceLastWorkout();
    return daysSince == 0;
  }
}