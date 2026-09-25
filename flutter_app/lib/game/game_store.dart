import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../localisation/app_language.dart';
import 'game_engine.dart';

class GameStats {
  GameStats({
    this.played = 0,
    this.wins = 0,
    this.streak = 0,
    this.best = 0,
    this.totalStars = 0,
    this.lastCompletedDate,
    this.lastWinDate,
    List<int>? distribution,
  }) : distribution = distribution ?? <int>[0, 0, 0, 0, 0, 0];

  int played;
  int wins;
  int streak;
  int best;
  int totalStars;
  String? lastCompletedDate;
  String? lastWinDate;
  List<int> distribution;

  int get winRate => played == 0 ? 0 : ((wins / played) * 100).round();

  Map<String, dynamic> toJson() => {
        'played': played,
        'wins': wins,
        'streak': streak,
        'best': best,
        'totalStars': totalStars,
        'lastCompletedDate': lastCompletedDate,
        'lastWinDate': lastWinDate,
        'distribution': distribution,
      };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    final rawDistribution = json['distribution'] as List<dynamic>?;
    return GameStats(
      played: json['played'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      best: json['best'] as int? ?? 0,
      totalStars: json['totalStars'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] as String?,
      lastWinDate: json['lastWinDate'] as String?,
      distribution: rawDistribution == null
          ? null
          : rawDistribution.map((value) => (value as num).toInt()).toList(),
    );
  }
}

class DailyState {
  const DailyState({
    required this.answer,
    required this.currentGuess,
    required this.guesses,
    required this.gameOver,
    required this.won,
    this.hintsUsed = 0,
  });

  final String answer;
  final List<String> currentGuess;
  final List<EvaluatedGuess> guesses;
  final bool gameOver;
  final bool won;
  final int hintsUsed;

  Map<String, dynamic> toJson() => {
        'answer': answer,
        'currentGuess': currentGuess,
        'guesses': guesses.map((guess) => guess.toJson()).toList(),
        'gameOver': gameOver,
        'won': won,
        'hintsUsed': hintsUsed,
      };

  factory DailyState.fromJson(Map<String, dynamic> json) {
    return DailyState(
      answer: json['answer'] as String? ?? '',
      currentGuess: (json['currentGuess'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      guesses: (json['guesses'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EvaluatedGuess.fromJson)
          .toList(),
      gameOver: json['gameOver'] as bool? ?? false,
      won: json['won'] as bool? ?? false,
      hintsUsed: (json['hintsUsed'] as num?)?.toInt() ?? 0,
    );
  }
}

class GameStore {
  static const _statsKey = 'dyfala.stats.flutter.v1';
  static const _languageKey = 'dyfala.language.flutter.v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _dailyKey(String dateKey) => 'dyfala.daily.flutter.$dateKey';

  Future<DailyState?> loadDaily(String dateKey) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_dailyKey(dateKey));
    if (raw == null) return null;
    try {
      return DailyState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDaily(String dateKey, DailyState state) async {
    final prefs = await _prefs;
    await prefs.setString(_dailyKey(dateKey), jsonEncode(state.toJson()));
  }

  Future<GameStats> loadStats() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_statsKey);
    if (raw == null) return GameStats();
    try {
      return GameStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return GameStats();
    }
  }

  Future<void> saveStats(GameStats stats) async {
    final prefs = await _prefs;
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<void> recordUnknownGuess(String word) async {
    final prefs = await _prefs;
    final current = prefs.getStringList('dyfala.beta.unknownGuesses') ?? <String>[];
    if (!current.contains(word)) {
      current.add(word);
      current.sort();
      await prefs.setStringList('dyfala.beta.unknownGuesses', current);
    }
  }

  Future<UiLanguage> loadLanguage() async {
    final prefs = await _prefs;
    final saved = prefs.getString(_languageKey);
    return saved == 'cy' ? UiLanguage.welsh : UiLanguage.english;
  }

  Future<void> saveLanguage(UiLanguage language) async {
    final prefs = await _prefs;
    await prefs.setString(_languageKey, language == UiLanguage.welsh ? 'cy' : 'en');
  }
}
