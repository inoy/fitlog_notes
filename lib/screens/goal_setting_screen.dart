import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fitlog_notes/models/goal_data.dart';
import 'package:fitlog_notes/data/goal_repository.dart';

class GoalSettingScreen extends StatefulWidget {
  final GoalData currentGoal;

  const GoalSettingScreen({super.key, required this.currentGoal});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  final GoalRepository _goalRepository = GoalRepository();
  late int _weeklyGoal;
  late int _monthlyGoal;

  @override
  void initState() {
    super.initState();
    _weeklyGoal = widget.currentGoal.weeklyGoal;
    _monthlyGoal = widget.currentGoal.monthlyGoal;
  }

  void _saveGoals() async {
    if (_weeklyGoal <= 0 || _monthlyGoal <= 0) {
      HapticFeedback.heavyImpact();
      _showErrorDialog('目標は1回以上に設定してください');
      return;
    }

    if (_weeklyGoal * 4 > _monthlyGoal + 5) {
      HapticFeedback.mediumImpact();
      _showWarningDialog();
      return;
    }

    HapticFeedback.lightImpact();
    
    final updatedGoal = widget.currentGoal.copyWith(
      weeklyGoal: _weeklyGoal,
      monthlyGoal: _monthlyGoal,
      updatedAt: DateTime.now(),
    );

    await _goalRepository.saveGoalData(updatedGoal);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('入力エラー'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('目標の確認'),
        content: const Text('週間目標に対して月間目標が低く設定されています。このまま保存しますか？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              _saveGoalsForced();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _saveGoalsForced() async {
    final updatedGoal = widget.currentGoal.copyWith(
      weeklyGoal: _weeklyGoal,
      monthlyGoal: _monthlyGoal,
      updatedAt: DateTime.now(),
    );

    await _goalRepository.saveGoalData(updatedGoal);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('目標設定'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveGoals,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGoalSettingCard(
                '週間目標',
                '1週間でワークアウトする回数',
                _weeklyGoal,
                1,
                14,
                (value) => setState(() => _weeklyGoal = value),
                CupertinoColors.systemBlue,
              ),
              const SizedBox(height: 20),
              _buildGoalSettingCard(
                '月間目標',
                '1ヶ月でワークアウトする回数',
                _monthlyGoal,
                1,
                60,
                (value) => setState(() => _monthlyGoal = value),
                CupertinoColors.systemOrange,
              ),
              const SizedBox(height: 32),
              _buildRecommendationCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSettingCard(
    String title,
    String description,
    int currentValue,
    int minValue,
    int maxValue,
    ValueChanged<int> onChanged,
    Color color,
  ) {
    return Container(
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
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                onPressed: currentValue > minValue 
                    ? () {
                        HapticFeedback.lightImpact();
                        onChanged(currentValue - 1);
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.minus_circle,
                  size: 32,
                  color: currentValue > minValue ? color : CupertinoColors.systemGrey3,
                ),
              ),
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$currentValue回',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              CupertinoButton(
                onPressed: currentValue < maxValue 
                    ? () {
                        HapticFeedback.lightImpact();
                        onChanged(currentValue + 1);
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.plus_circle,
                  size: 32,
                  color: currentValue < maxValue ? color : CupertinoColors.systemGrey3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(initialItem: currentValue - 1),
              onSelectedItemChanged: (index) {
                HapticFeedback.selectionClick();
                onChanged(index + 1);
              },
              children: List.generate(
                maxValue - minValue + 1,
                (index) => Center(
                  child: Text(
                    '${index + minValue}回',
                    style: TextStyle(color: color),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: CupertinoColors.systemGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb,
                color: CupertinoColors.systemGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '推奨目標',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 初心者：週2-3回、月8-12回\n'
            '• 中級者：週3-4回、月12-16回\n'
            '• 上級者：週4-5回、月16-20回',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.label,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '現在の設定: 週$_weeklyGoal回、月$_monthlyGoal回',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGreen,
            ),
          ),
        ],
      ),
    );
  }
}