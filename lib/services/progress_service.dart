import 'dart:convert';

import 'package:loyaya/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _mathKey = 'completed_math_ids';
  static const _surveyKey = 'completed_survey_ids';
  static const _mathLockedKey = 'locked_math_ids';
  static const _surveyLockedKey = 'locked_survey_ids';

  Future<Set<String>> completedMathIds() => _loadSet(_mathKey);
  Future<Set<String>> completedSurveyIds() => _loadSet(_surveyKey);
  Future<Set<String>> lockedMathIds() => _loadSet(_mathLockedKey);
  Future<Set<String>> lockedSurveyIds() => _loadSet(_surveyLockedKey);

  Future<void> markMathCompleted(String id) async {
    final set = await completedMathIds();
    set.add(id);
    await _saveSet(_mathKey, set);
  }

  Future<void> markSurveyCompleted(String id) async {
    final set = await completedSurveyIds();
    set.add(id);
    await _saveSet(_surveyKey, set);
  }

  Future<void> markMathLocked(String id) async {
    final set = await lockedMathIds();
    set.add(id);
    await _saveSet(_mathLockedKey, set);
  }

  Future<void> markSurveyLocked(String id) async {
    final set = await lockedSurveyIds();
    set.add(id);
    await _saveSet(_surveyLockedKey, set);
  }

  Future<void> syncFromHistory(List<Map<String, dynamic>> history) async {
    final math = await completedMathIds();
    final surveys = await completedSurveyIds();

    for (final row in history) {
      final ref = row['reference_id']?.toString();
      if (ref == null || ref.isEmpty) continue;
      final type = row['type']?.toString() ?? '';
      if (type == 'earn_math_quiz') {
        math.add(ref);
      } else if (type == 'earn_survey') {
        surveys.add(ref);
      }
    }

    await _saveSet(_mathKey, math);
    await _saveSet(_surveyKey, surveys);
  }

  Future<void> syncLocksFromApi(ApiClient api) async {
    final locks = await api.contentLocks();
    final mathLocked = <String>{};
    final surveyLocked = <String>{};

    for (final lock in locks) {
      final type = lock['content_type']?.toString();
      final id = lock['content_id']?.toString();
      if (id == null || id.isEmpty) continue;
      if (type == 'math_quiz') {
        mathLocked.add(id);
      } else if (type == 'survey') {
        surveyLocked.add(id);
      }
    }

    await _saveSet(_mathLockedKey, mathLocked);
    await _saveSet(_surveyLockedKey, surveyLocked);
  }

  Future<Set<String>> _loadSet(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<String>().toSet();
  }

  Future<void> _saveSet(String key, Set<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(values.toList()));
  }
}
