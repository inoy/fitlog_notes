import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitlog_notes/models/exercise.dart';
import 'package:fitlog_notes/data/predefined_data.dart';

import 'package:collection/collection.dart';

class ExerciseRepository {
  static const _keyExercises = 'exercises';

  Future<void> saveExercises(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedExercises = exercises.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyExercises, encodedExercises);
  }

  Future<List<Exercise>> loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedExercises = prefs.getStringList(_keyExercises);
    if (encodedExercises == null || encodedExercises.isEmpty) {
      await saveExercises(predefinedExercises);
      return predefinedExercises;
    }
    return encodedExercises.map((e) => Exercise.fromJson(jsonDecode(e))).toList();
  }

  Future<Exercise?> getExerciseById(String id) async {
    final exercises = await loadExercises();
    return exercises.firstWhereOrNull((exercise) => exercise.id == id);
  }
}