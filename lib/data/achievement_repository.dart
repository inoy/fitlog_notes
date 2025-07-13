import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitlog_notes/models/achievement.dart';
import 'package:fitlog_notes/models/streak_data.dart';
import 'package:fitlog_notes/models/goal_data.dart';

class AchievementRepository {
  static const _keyAchievements = 'achievements';

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = achievements.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_keyAchievements, encoded);
  }

  Future<List<Achievement>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_keyAchievements);
    
    if (encoded == null) {
      final defaultAchievements = Achievement.getDefaultAchievements();
      await saveAchievements(defaultAchievements);
      return defaultAchievements;
    }
    
    return encoded.map((e) => Achievement.fromJson(jsonDecode(e))).toList();
  }

  Future<List<Achievement>> updateAchievements({
    required StreakData streakData,
    required GoalProgress goalProgress,
    required int exerciseVarietyCount,
    required int weeklyGoalsAchieved,
    required int monthlyGoalsAchieved,
  }) async {
    final achievements = await loadAchievements();
    final updatedAchievements = <Achievement>[];

    for (final achievement in achievements) {
      Achievement updated = achievement;
      
      switch (achievement.type) {
        case AchievementType.firstWorkout:
          updated = achievement.copyWith(
            progress: streakData.totalWorkouts > 0 ? 1 : 0,
            isUnlocked: streakData.totalWorkouts > 0,
            unlockedAt: streakData.totalWorkouts > 0 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.streak7:
          updated = achievement.copyWith(
            progress: streakData.longestStreak,
            isUnlocked: streakData.longestStreak >= 7,
            unlockedAt: streakData.longestStreak >= 7 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.streak30:
          updated = achievement.copyWith(
            progress: streakData.longestStreak,
            isUnlocked: streakData.longestStreak >= 30,
            unlockedAt: streakData.longestStreak >= 30 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.streak100:
          updated = achievement.copyWith(
            progress: streakData.longestStreak,
            isUnlocked: streakData.longestStreak >= 100,
            unlockedAt: streakData.longestStreak >= 100 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.totalWorkouts10:
          updated = achievement.copyWith(
            progress: streakData.totalWorkouts,
            isUnlocked: streakData.totalWorkouts >= 10,
            unlockedAt: streakData.totalWorkouts >= 10 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.totalWorkouts50:
          updated = achievement.copyWith(
            progress: streakData.totalWorkouts,
            isUnlocked: streakData.totalWorkouts >= 50,
            unlockedAt: streakData.totalWorkouts >= 50 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.totalWorkouts100:
          updated = achievement.copyWith(
            progress: streakData.totalWorkouts,
            isUnlocked: streakData.totalWorkouts >= 100,
            unlockedAt: streakData.totalWorkouts >= 100 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.varietyMaster:
          updated = achievement.copyWith(
            progress: exerciseVarietyCount,
            isUnlocked: exerciseVarietyCount >= 5,
            unlockedAt: exerciseVarietyCount >= 5 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.weeklyGoalAchiever:
          updated = achievement.copyWith(
            progress: weeklyGoalsAchieved,
            isUnlocked: weeklyGoalsAchieved >= 10,
            unlockedAt: weeklyGoalsAchieved >= 10 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        case AchievementType.monthlyGoalAchiever:
          updated = achievement.copyWith(
            progress: monthlyGoalsAchieved,
            isUnlocked: monthlyGoalsAchieved >= 3,
            unlockedAt: monthlyGoalsAchieved >= 3 && !achievement.isUnlocked ? DateTime.now() : achievement.unlockedAt,
          );
          break;
          
        default:
          // 他のアチーブメントタイプの処理を後で追加
          break;
      }
      
      
      updatedAchievements.add(updated);
    }
    
    await saveAchievements(updatedAchievements);
    return updatedAchievements;
  }

  Future<List<Achievement>> getRecentUnlocks({int days = 7}) async {
    final achievements = await loadAchievements();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return achievements.where((achievement) {
      return achievement.isUnlocked && 
             achievement.unlockedAt != null && 
             achievement.unlockedAt!.isAfter(cutoffDate);
    }).toList();
  }

  Future<List<Achievement>> getUnlockedAchievements() async {
    final achievements = await loadAchievements();
    return achievements.where((a) => a.isUnlocked).toList();
  }

  Future<List<Achievement>> getInProgressAchievements() async {
    final achievements = await loadAchievements();
    return achievements.where((a) => !a.isUnlocked && (a.progress ?? 0) > 0).toList();
  }

  Future<double> getOverallProgress() async {
    final achievements = await loadAchievements();
    if (achievements.isEmpty) return 0.0;
    
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    return unlockedCount / achievements.length;
  }
}