import 'package:flutter/cupertino.dart';
import 'package:fitlog_notes/data/workout_repository.dart';
import 'package:fitlog_notes/data/exercise_repository.dart';
import 'package:fitlog_notes/data/streak_repository.dart';
import 'package:fitlog_notes/models/exercise.dart';
import 'package:fitlog_notes/models/streak_data.dart';
import 'package:fitlog_notes/main.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final ExerciseRepository _exerciseRepository = ExerciseRepository();
  final StreakRepository _streakRepository = StreakRepository();
  
  List<WorkoutRecord> _allWorkouts = [];
  List<Exercise> _exercises = [];
  StreakData _streakData = StreakData.empty;
  final Map<String, int> _exerciseFrequency = {};
  final List<MapEntry<String, int>> _weeklyWorkouts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final workouts = await _workoutRepository.loadWorkouts();
    final exercises = await _exerciseRepository.loadExercises();
    final streakData = await _streakRepository.loadStreakData();
    
    setState(() {
      _allWorkouts = workouts.map((e) => WorkoutRecord.fromJson(jsonDecode(e))).toList();
      _exercises = exercises;
      _streakData = streakData;
      _calculateStats();
    });
  }

  void _calculateStats() {
    // 種目別頻度計算
    _exerciseFrequency.clear();
    for (final workout in _allWorkouts) {
      final exercise = _exercises.firstWhere(
        (e) => e.id == workout.exerciseId,
        orElse: () => Exercise(id: '', name: 'Unknown', defaultWorkoutType: workout.details.first.type),
      );
      _exerciseFrequency[exercise.name] = (_exerciseFrequency[exercise.name] ?? 0) + 1;
    }
    
    // 週別ワークアウト数計算（過去8週間）
    _weeklyWorkouts.clear();
    final now = DateTime.now();
    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekLabel = DateFormat('M/d').format(weekStart);
      
      final weekWorkouts = _allWorkouts.where((workout) {
        if (workout.date == null) return false;
        final workoutDate = workout.date!;
        return workoutDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               workoutDate.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;
      
      _weeklyWorkouts.add(MapEntry(weekLabel, weekWorkouts));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('統計・分析'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(),
              const SizedBox(height: 20),
              _buildWeeklyProgressCard(),
              const SizedBox(height: 20),
              _buildExerciseFrequencyCard(),
              const SizedBox(height: 20),
              _buildAchievementsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '概要',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '現在のストリーク',
                  '${_streakData.currentStreak}日',
                  CupertinoColors.systemBlue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '最長ストリーク',
                  '${_streakData.longestStreak}日',
                  CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '総ワークアウト',
                  '${_streakData.totalWorkouts}回',
                  CupertinoColors.systemOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '今月',
                  '${_getThisMonthWorkouts()}回',
                  CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '週間進捗（過去8週間）',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: _buildWeeklyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (_weeklyWorkouts.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    final maxWorkouts = _weeklyWorkouts.map((e) => e.value).fold(0, max);
    final chartHeight = 80.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _weeklyWorkouts.map((entry) {
        final barHeight = maxWorkouts > 0 ? (entry.value / maxWorkouts) * chartHeight : 0.0;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: entry.value > 0 ? CupertinoColors.systemBlue : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseFrequencyCard() {
    final sortedExercises = _exerciseFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '種目別実施回数',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedExercises.isEmpty)
            const Center(
              child: Text(
                'まだワークアウトの記録がありません',
                style: TextStyle(color: CupertinoColors.secondaryLabel),
              ),
            )
          else
            ...sortedExercises.take(5).map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${entry.value}回',
                      style: const TextStyle(
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    final achievements = _getAchievements();
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '実績',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...achievements.map((achievement) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Text(
                  achievement['icon'],
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        achievement['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  int _getThisMonthWorkouts() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _allWorkouts.where((workout) {
      if (workout.date == null) return false;
      final workoutDate = workout.date!;
      return workoutDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
             workoutDate.isBefore(monthEnd.add(const Duration(days: 1)));
    }).length;
  }

  List<Map<String, dynamic>> _getAchievements() {
    List<Map<String, dynamic>> achievements = [];
    
    if (_streakData.totalWorkouts >= 1) {
      achievements.add({
        'icon': '🏁',
        'title': 'はじめの一歩',
        'description': '初回のワークアウトを記録しました'
      });
    }
    
    if (_streakData.currentStreak >= 7) {
      achievements.add({
        'icon': '📅',
        'title': '一週間継続',
        'description': '7日連続でワークアウトを継続しました'
      });
    }
    
    if (_streakData.longestStreak >= 30) {
      achievements.add({
        'icon': '🏆',
        'title': 'ひと月マスター',
        'description': '30日連続記録を達成しました'
      });
    }
    
    if (_streakData.totalWorkouts >= 50) {
      achievements.add({
        'icon': '💪',
        'title': 'フィットネス愛好家',
        'description': '50回のワークアウトを達成しました'
      });
    }
    
    if (_exerciseFrequency.length >= 5) {
      achievements.add({
        'icon': '🎯',
        'title': 'バラエティマスター',
        'description': '5種類以上の種目を記録しました'
      });
    }
    
    return achievements;
  }
}