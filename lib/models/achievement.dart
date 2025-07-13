enum AchievementType {
  firstWorkout,
  streak7,
  streak30,
  streak100,
  totalWorkouts10,
  totalWorkouts50,
  totalWorkouts100,
  varietyMaster,
  weeklyGoalAchiever,
  monthlyGoalAchiever,
  consistency,
  earlyBird,
  nightOwl,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final int? progress;
  final int? targetValue;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.isUnlocked,
    this.progress,
    this.targetValue,
  });

  Achievement copyWith({
    AchievementType? type,
    String? title,
    String? description,
    String? icon,
    DateTime? unlockedAt,
    bool? isUnlocked,
    int? progress,
    int? targetValue,
  }) {
    return Achievement(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      targetValue: targetValue ?? this.targetValue,
    );
  }

  double get progressPercentage {
    if (targetValue == null || progress == null || targetValue == 0) return 0.0;
    return (progress! / targetValue!).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'title': title,
    'description': description,
    'icon': icon,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'isUnlocked': isUnlocked,
    'progress': progress,
    'targetValue': targetValue,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    type: AchievementType.values[json['type'] as int],
    title: json['title'] as String,
    description: json['description'] as String,
    icon: json['icon'] as String,
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
    isUnlocked: json['isUnlocked'] as bool,
    progress: json['progress'] as int?,
    targetValue: json['targetValue'] as int?,
  );

  static List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        type: AchievementType.firstWorkout,
        title: 'はじめの一歩',
        description: '初回のワークアウトを記録',
        icon: '🏁',
        isUnlocked: false,
        targetValue: 1,
      ),
      Achievement(
        type: AchievementType.streak7,
        title: '一週間チャレンジャー',
        description: '7日間連続でワークアウト',
        icon: '📅',
        isUnlocked: false,
        targetValue: 7,
      ),
      Achievement(
        type: AchievementType.streak30,
        title: 'ひと月マスター',
        description: '30日間連続でワークアウト',
        icon: '🏆',
        isUnlocked: false,
        targetValue: 30,
      ),
      Achievement(
        type: AchievementType.streak100,
        title: 'レジェンド',
        description: '100日間連続でワークアウト',
        icon: '👑',
        isUnlocked: false,
        targetValue: 100,
      ),
      Achievement(
        type: AchievementType.totalWorkouts10,
        title: 'フィットネス入門者',
        description: '合計10回のワークアウトを完了',
        icon: '💪',
        isUnlocked: false,
        targetValue: 10,
      ),
      Achievement(
        type: AchievementType.totalWorkouts50,
        title: 'フィットネス愛好家',
        description: '合計50回のワークアウトを完了',
        icon: '🔥',
        isUnlocked: false,
        targetValue: 50,
      ),
      Achievement(
        type: AchievementType.totalWorkouts100,
        title: 'フィットネス達人',
        description: '合計100回のワークアウトを完了',
        icon: '⭐',
        isUnlocked: false,
        targetValue: 100,
      ),
      Achievement(
        type: AchievementType.varietyMaster,
        title: 'バラエティマスター',
        description: '5種類以上の種目を記録',
        icon: '🎯',
        isUnlocked: false,
        targetValue: 5,
      ),
      Achievement(
        type: AchievementType.weeklyGoalAchiever,
        title: '週間目標達成者',
        description: '週間目標を10回達成',
        icon: '✨',
        isUnlocked: false,
        targetValue: 10,
      ),
      Achievement(
        type: AchievementType.monthlyGoalAchiever,
        title: '月間目標達成者',
        description: '月間目標を3回達成',
        icon: '🌟',
        isUnlocked: false,
        targetValue: 3,
      ),
    ];
  }
}