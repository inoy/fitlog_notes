class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final int totalWorkouts;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    required this.totalWorkouts,
  });

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
    'totalWorkouts': totalWorkouts,
  };

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
    currentStreak: json['currentStreak'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    lastWorkoutDate: json['lastWorkoutDate'] != null 
        ? DateTime.parse(json['lastWorkoutDate'] as String) 
        : null,
    totalWorkouts: json['totalWorkouts'] as int? ?? 0,
  );

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
    int? totalWorkouts,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    );
  }

  static const StreakData empty = StreakData(
    currentStreak: 0,
    longestStreak: 0,
    lastWorkoutDate: null,
    totalWorkouts: 0,
  );
}