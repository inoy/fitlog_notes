class GoalData {
  final int weeklyGoal; // 週間目標回数
  final int monthlyGoal; // 月間目標回数
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalData({
    required this.weeklyGoal,
    required this.monthlyGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'weeklyGoal': weeklyGoal,
    'monthlyGoal': monthlyGoal,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory GoalData.fromJson(Map<String, dynamic> json) => GoalData(
    weeklyGoal: json['weeklyGoal'] as int? ?? 3,
    monthlyGoal: json['monthlyGoal'] as int? ?? 12,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.now(),
  );

  GoalData copyWith({
    int? weeklyGoal,
    int? monthlyGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalData(
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static GoalData get defaultGoal => GoalData(
    weeklyGoal: 3,
    monthlyGoal: 12,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

class GoalProgress {
  final int currentWeeklyCount;
  final int currentMonthlyCount;
  final double weeklyProgress; // 0.0 - 1.0
  final double monthlyProgress; // 0.0 - 1.0
  final bool isWeeklyGoalAchieved;
  final bool isMonthlyGoalAchieved;
  final int daysLeftInWeek;
  final int daysLeftInMonth;

  const GoalProgress({
    required this.currentWeeklyCount,
    required this.currentMonthlyCount,
    required this.weeklyProgress,
    required this.monthlyProgress,
    required this.isWeeklyGoalAchieved,
    required this.isMonthlyGoalAchieved,
    required this.daysLeftInWeek,
    required this.daysLeftInMonth,
  });
}