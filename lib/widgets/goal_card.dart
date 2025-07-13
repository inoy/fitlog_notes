import 'package:flutter/cupertino.dart';
import 'package:fitlog_notes/models/goal_data.dart';
import 'package:fitlog_notes/data/goal_repository.dart';
import 'package:fitlog_notes/screens/goal_setting_screen.dart';

class GoalCard extends StatefulWidget {
  const GoalCard({super.key});

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  final GoalRepository _goalRepository = GoalRepository();
  GoalData _goalData = GoalData.defaultGoal;
  GoalProgress? _progress;
  List<String> _motivationalMessages = [];

  @override
  void initState() {
    super.initState();
    _loadGoalData();
  }

  Future<void> _loadGoalData() async {
    final goalData = await _goalRepository.loadGoalData();
    final progress = await _goalRepository.calculateProgress();
    final messages = await _goalRepository.getMotivationalMessages(progress);
    
    setState(() {
      _goalData = goalData;
      _progress = progress;
      _motivationalMessages = messages;
    });
  }

  Future<void> refreshGoalData() async {
    await _loadGoalData();
  }

  void _navigateToGoalSetting() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GoalSettingScreen(currentGoal: _goalData),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadGoalData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_progress == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _navigateToGoalSetting,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '今週・今月の目標',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  CupertinoIcons.settings,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    '今週',
                    _progress!.currentWeeklyCount,
                    _goalData.weeklyGoal,
                    _progress!.weeklyProgress,
                    _progress!.isWeeklyGoalAchieved ? CupertinoColors.systemGreen : CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressItem(
                    '今月',
                    _progress!.currentMonthlyCount,
                    _goalData.monthlyGoal,
                    _progress!.monthlyProgress,
                    _progress!.isMonthlyGoalAchieved ? CupertinoColors.systemGreen : CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),
            if (_motivationalMessages.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...(_motivationalMessages.map((message) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ))),
            ],
            const SizedBox(height: 8),
            const Text(
              'タップで目標を変更',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, int current, int goal, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            Text(
              '$current/$goal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width * 0.35 * progress,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}