import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fitlog_notes/data/workout_repository.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const FitlogApp());
}

class WorkoutRecord {
  final String name;
  final int reps;
  final int sets;
  final DateTime? date;

  WorkoutRecord({
    required this.name,
    required this.reps,
    required this.sets,
    this.date,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'reps': reps,
    'sets': sets,
    'date': date?.toIso8601String(),
  };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
    name: json['name'] as String,
    reps: json['reps'] as int,
    sets: json['sets'] as int,
    date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
  );
}

class FitlogApp extends StatelessWidget {
  const FitlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitlogNotes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WorkoutListScreen(),
    );
  }
}

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  final WorkoutRepository _repository = WorkoutRepository();
  final List<WorkoutRecord> _allWorkoutRecords = []; // 全ての記録を保持
  List<WorkoutRecord> _filteredWorkoutRecords = []; // フィルタリングされた記録
  DateTime _focusedDay = DateTime.now(); // カレンダーの表示月
  DateTime _selectedDay = DateTime.now(); // 選択された日付

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final List<String> encodedWorkouts = await _repository.loadWorkouts();
    setState(() {
      _allWorkoutRecords.clear();
      _allWorkoutRecords.addAll(
        encodedWorkouts.map((e) => WorkoutRecord.fromJson(jsonDecode(e))),
      );
      _applyFilter(); // 読み込み後にフィルタを適用
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredWorkoutRecords = _allWorkoutRecords.where((record) {
        return record.date != null &&
            record.date!.year == _selectedDay.year &&
            record.date!.month == _selectedDay.month &&
            record.date!.day == _selectedDay.day;
      }).toList();
    });
  }

  void _addWorkoutRecord(WorkoutRecord record) {
    setState(() {
      _allWorkoutRecords.add(record);
      _applyFilter();
    });
    _saveWorkouts();
  }

  void _editWorkoutRecord(int index, WorkoutRecord updatedRecord) {
    setState(() {
      // _allWorkoutRecordsから元のレコードを見つけて更新
      final originalIndex = _allWorkoutRecords.indexOf(
        _filteredWorkoutRecords[index],
      );
      if (originalIndex != -1) {
        _allWorkoutRecords[originalIndex] = updatedRecord;
      }
      _applyFilter();
    });
    _saveWorkouts();
  }

  void _removeWorkoutRecord(int index) {
    setState(() {
      // _allWorkoutRecordsから元のレコードを見つけて削除
      final originalIndex = _allWorkoutRecords.indexOf(
        _filteredWorkoutRecords[index],
      );
      if (originalIndex != -1) {
        _allWorkoutRecords.removeAt(originalIndex);
      }
      _applyFilter();
    });
    _saveWorkouts();
  }

  Future<void> _saveWorkouts() async {
    final List<String> encodedWorkouts = _allWorkoutRecords
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await _repository.saveWorkouts(encodedWorkouts);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy/MM/dd').format(_selectedDay)),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _applyFilter();
              });
            },
            calendarFormat: CalendarFormat.week,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: _filteredWorkoutRecords.isEmpty
                ? const _EmptyWorkoutListMessage()
                : ListView.builder(
                    itemCount: _filteredWorkoutRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredWorkoutRecords[index];
                      return WorkoutRecordItem(
                        record: record,
                        index: index,
                        onDismissed: (idx) => _removeWorkoutRecord(idx),
                        onTap: () async {
                          final updatedRecord =
                              await Navigator.push<WorkoutRecord>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddWorkoutScreen(initialRecord: record),
                                ),
                              );

                          if (updatedRecord != null) {
                            _editWorkoutRecord(index, updatedRecord);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRecord = await Navigator.push<WorkoutRecord>(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
          );

          if (newRecord != null) {
            _addWorkoutRecord(newRecord);
          }
        },
        tooltip: '記録を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyWorkoutListMessage extends StatelessWidget {
  const _EmptyWorkoutListMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('記録がありません。右下のボタンから追加してください。'));
  }
}

class WorkoutRecordItem extends StatelessWidget {
  final WorkoutRecord record;
  final ValueChanged<int> onDismissed;
  final int index;
  final VoidCallback? onTap;

  const WorkoutRecordItem({
    super.key,
    required this.record,
    required this.onDismissed,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Dismissible(
        key: ObjectKey(record),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("確認"),
                content: const Text("この記録を削除してもよろしいですか？"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("キャンセル"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("削除"),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          onDismissed(index);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('「${record.name}」を削除しました')));
        },
        child: GestureDetector(
          onTap: onTap,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    record.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '日付: ${record.date != null ? DateFormat('yyyy/MM/dd').format(record.date!) : '未設定'}',
                  ),
                  Text('回数: ${record.reps}'),
                  Text('セット数: ${record.sets}'),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddWorkoutScreen extends StatefulWidget {
  final WorkoutRecord? initialRecord;

  const AddWorkoutScreen({super.key, this.initialRecord});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final TextEditingController _workoutNameController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      _workoutNameController.text = widget.initialRecord!.name;
      _repsController.text = widget.initialRecord!.reps.toString();
      _setsController.text = widget.initialRecord!.sets.toString();
      _selectedDate = widget.initialRecord!.date;
    } else {
      _selectedDate = DateTime.now(); // 新規作成時は現在日付をデフォルトに
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // nullの場合は現在日付を初期値に
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しい記録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                "日付: ${_selectedDate != null ? DateFormat('yyyy/MM/dd').format(_selectedDate!) : '未設定'}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _workoutNameController,
              decoration: const InputDecoration(
                labelText: '種目名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: '回数',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _setsController,
              decoration: const InputDecoration(
                labelText: 'セット数',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                final String workoutName = _workoutNameController.text;
                final int? reps = int.tryParse(_repsController.text);
                final int? sets = int.tryParse(_setsController.text);

                if (workoutName.isNotEmpty && reps != null && sets != null) {
                  final newRecord = WorkoutRecord(
                    name: workoutName,
                    reps: reps,
                    sets: sets,
                    date: _selectedDate,
                  );
                  Navigator.pop(context, newRecord);
                } else {
                  // エラーハンドリング（例: SnackBarを表示するなど）
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
