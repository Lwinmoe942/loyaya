import 'dart:convert';

import 'package:flutter/services.dart';

class MathQuizItem {
  MathQuizItem({
    required this.id,
    required this.numbers,
    required this.answer,
    required this.points,
  });

  factory MathQuizItem.fromJson(Map<String, dynamic> json) {
    return MathQuizItem(
      id: json['id'] as String,
      numbers: (json['numbers'] as List<dynamic>).cast<int>(),
      answer: json['answer'] as int,
      points: json['points'] as int? ?? 2,
    );
  }

  final String id;
  final List<int> numbers;
  final int answer;
  final int points;

  String get expression => numbers.join(' + ');
}

class SurveyQuestion {
  SurveyQuestion({
    required this.text,
    required this.options,
    required this.correct,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correct: json['correct'] as int,
    );
  }

  final String text;
  final List<String> options;
  final int correct;
}

class SurveyItem {
  SurveyItem({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.questions,
  });

  factory SurveyItem.fromJson(Map<String, dynamic> json) {
    return SurveyItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      points: json['points'] as int? ?? 2,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => SurveyQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String title;
  final String description;
  final int points;
  final List<SurveyQuestion> questions;
}

class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  List<MathQuizItem>? _mathQuizzes;
  List<SurveyItem>? _surveys;

  Future<List<MathQuizItem>> mathQuizzes() async {
    if (_mathQuizzes != null) return _mathQuizzes!;
    final raw = await rootBundle.loadString('assets/content/math_quizzes.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _mathQuizzes = list
        .map((e) => MathQuizItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return _mathQuizzes!;
  }

  Future<List<SurveyItem>> surveys() async {
    if (_surveys != null) return _surveys!;
    final raw = await rootBundle.loadString('assets/content/surveys.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _surveys = list
        .map((e) => SurveyItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return _surveys!;
  }

  Future<MathQuizItem?> mathQuizById(String id) async {
    final all = await mathQuizzes();
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<SurveyItem?> surveyById(String id) async {
    final all = await surveys();
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
