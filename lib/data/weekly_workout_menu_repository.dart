import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitlog_notes/models/weekly_menu_item.dart';
import 'package:fitlog_notes/data/predefined_data.dart';

class WeeklyWorkoutMenuRepository {
  static const _keyWeeklyMenu = 'weeklyMenu';

  Future<void> saveWeeklyMenu(List<WeeklyMenuItem> menu) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedMenu = menu.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_keyWeeklyMenu, encodedMenu);
  }

  Future<List<WeeklyMenuItem>> loadWeeklyMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedMenu = prefs.getStringList(_keyWeeklyMenu);
    if (encodedMenu == null || encodedMenu.isEmpty) {
      await saveWeeklyMenu(predefinedWeeklyMenuItems);
      return predefinedWeeklyMenuItems;
    }
    return encodedMenu.map((item) => WeeklyMenuItem.fromJson(jsonDecode(item))).toList();
  }
}
