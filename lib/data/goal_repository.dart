import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitlog_notes/models/goal_data.dart';
import 'package:fitlog_notes/data/workout_repository.dart';
import 'package:fitlog_notes/main.dart';

class GoalRepository {
  static const _keyGoalData = 'goal_data';
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  Future<void> saveGoalData(GoalData goalData) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(goalData.toJson());
    await prefs.setString(_keyGoalData, encoded);
  }

  Future<GoalData> loadGoalData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_keyGoalData);
    if (encoded == null) {
      final defaultGoal = GoalData.defaultGoal;
      await saveGoalData(defaultGoal);
      return defaultGoal;
    }
    return GoalData.fromJson(jsonDecode(encoded));
  }

  Future<GoalProgress> calculateProgress() async {
    final goalData = await loadGoalData();
    final allWorkouts = await _workoutRepository.loadWorkouts();
    final workoutRecords = allWorkouts.map((e) => WorkoutRecord.fromJson(jsonDecode(e))).toList();
    
    final now = DateTime.now();
    
    // 今週の開始と終了
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEnd = weekStartOnly.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    // 今月の開始と終了
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    
    // 今週のワークアウト数
    final weeklyWorkouts = workoutRecords.where((workout) {
      if (workout.date == null) return false;
      return workout.date!.isAfter(weekStartOnly.subtract(const Duration(seconds: 1))) &&
             workout.date!.isBefore(weekEnd.add(const Duration(seconds: 1)));
    }).length;
    
    // 今月のワークアウト数
    final monthlyWorkouts = workoutRecords.where((workout) {
      if (workout.date == null) return false;
      return workout.date!.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
             workout.date!.isBefore(monthEnd.add(const Duration(seconds: 1)));
    }).length;
    
    // 進捗計算
    final weeklyProgress = goalData.weeklyGoal > 0 
        ? (weeklyWorkouts / goalData.weeklyGoal).clamp(0.0, 1.0)
        : 0.0;
    
    final monthlyProgress = goalData.monthlyGoal > 0 
        ? (monthlyWorkouts / goalData.monthlyGoal).clamp(0.0, 1.0)
        : 0.0;
    
    // 残り日数計算
    final daysLeftInWeek = 7 - now.weekday;
    final daysLeftInMonth = monthEnd.day - now.day;
    
    return GoalProgress(
      currentWeeklyCount: weeklyWorkouts,
      currentMonthlyCount: monthlyWorkouts,
      weeklyProgress: weeklyProgress,
      monthlyProgress: monthlyProgress,
      isWeeklyGoalAchieved: weeklyWorkouts >= goalData.weeklyGoal,
      isMonthlyGoalAchieved: monthlyWorkouts >= goalData.monthlyGoal,
      daysLeftInWeek: daysLeftInWeek,
      daysLeftInMonth: daysLeftInMonth,
    );
  }

  Future<bool> checkGoalAchievement(GoalProgress previousProgress, GoalProgress currentProgress) async {
    // 新たに目標達成した場合にtrueを返す
    return (!previousProgress.isWeeklyGoalAchieved && currentProgress.isWeeklyGoalAchieved) ||
           (!previousProgress.isMonthlyGoalAchieved && currentProgress.isMonthlyGoalAchieved);
  }

  Future<List<String>> getMotivationalMessages(GoalProgress progress) async {
    List<String> messages = [];
    
    if (progress.isWeeklyGoalAchieved && progress.isMonthlyGoalAchieved) {
      messages.add('🎉 週間・月間目標を達成しています！');
    } else if (progress.isWeeklyGoalAchieved) {
      messages.add('✨ 今週の目標を達成しました！');
      if (progress.daysLeftInMonth > 0) {
        final remaining = (await loadGoalData()).monthlyGoal - progress.currentMonthlyCount;
        if (remaining > 0) {
          messages.add('月間目標まであと$remaining回です');
        }
      }
    } else if (progress.isMonthlyGoalAchieved) {
      messages.add('🏆 今月の目標を達成しました！');
    } else {
      // まだ目標未達成の場合
      final goalData = await loadGoalData();
      final weeklyRemaining = goalData.weeklyGoal - progress.currentWeeklyCount;
      final monthlyRemaining = goalData.monthlyGoal - progress.currentMonthlyCount;
      
      if (weeklyRemaining > 0 && progress.daysLeftInWeek > 0) {
        messages.add('今週の目標まであと$weeklyRemaining回');
      }
      
      if (monthlyRemaining > 0 && progress.daysLeftInMonth > 0) {
        messages.add('今月の目標まであと$monthlyRemaining回');
      }
      
      // 励ましメッセージ
      if (progress.weeklyProgress >= 0.5) {
        messages.add('今週も順調です！');
      } else if (progress.daysLeftInWeek <= 2) {
        messages.add('今週はラストスパート！');
      }
    }
    
    return messages;
  }
}