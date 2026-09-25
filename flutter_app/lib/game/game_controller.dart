import 'package:flutter/foundation.dart';

import '../data/puzzles.dart';
import '../localisation/app_language.dart';
import '../models/puzzle.dart';
import 'game_engine.dart';
import 'game_store.dart';

enum AppScreen { home, game, result }

class HintMessage {
  const HintMessage({
    required this.number,
    required this.title,
    required this.body,
    required this.starsRemaining,
  });

  final int number;
  final String title;
  final String body;
  final int starsRemaining;
}

class GameController extends ChangeNotifier {
  GameController({GameStore? store, DateTime? now})
      : _store = store ?? GameStore(),
        _nowOverride = now;

  final GameStore _store;
  final DateTime? _nowOverride;

  bool isReady = false;
  UiLanguage uiLanguage = UiLanguage.english;
  AppScreen screen = AppScreen.home;
  late String todayKey;
  late int puzzleNumber;
  late Puzzle puzzle;
  late List<String> answerTokens;
  List<String> currentGuess = <String>[];
  List<EvaluatedGuess> guesses = <EvaluatedGuess>[];
  bool gameOver = false;
  bool won = false;
  int hintsUsed = 0;
  bool practiceMode = false;
  GameStats stats = GameStats();
  int invalidWordTick = 0;
  bool lastSubmitWasInvalidWord = false;

  late int _dailyPuzzleNumber;
  late Puzzle _dailyPuzzle;
  int _practiceCursor = 0;

  DateTime get _now => _nowOverride ?? DateTime.now();

  Future<void> initialise() async {
    todayKey = localDateKey(_now);
    _dailyPuzzleNumber = puzzleNumberForDate(todayKey);
    _dailyPuzzle = puzzleForDate(todayKey);
    stats = await _store.loadStats();
    uiLanguage = await _store.loadLanguage();
    await _restoreDailyPuzzle();
    isReady = true;
    notifyListeners();
  }

  AppStrings get strings => AppStrings(uiLanguage);

  int get resultStars => starsForResult(won: won, hintsUsed: hintsUsed);
  int get starsAvailable => (3 - hintsUsed).clamp(0, 3).toInt();
  bool get canUseHint => !gameOver && hintsUsed < 3;

  String get learnerStage {
    if (stats.wins < 10) return strings.levelEveryday;
    if (stats.wins < 25) return strings.levelGrowing;
    return strings.levelChallenge;
  }

  Future<void> setLanguage(UiLanguage language) async {
    if (uiLanguage == language) return;
    uiLanguage = language;
    await _store.saveLanguage(language);
    notifyListeners();
  }

  void startOrResume() {
    screen = gameOver ? AppScreen.result : AppScreen.game;
    notifyListeners();
  }

  void goHome() {
    if (practiceMode) {
      _restoreDailyPuzzle().then((_) {
        screen = AppScreen.home;
        notifyListeners();
      });
      return;
    }
    screen = AppScreen.home;
    notifyListeners();
  }

  void viewResult() {
    screen = AppScreen.result;
    notifyListeners();
  }

  Future<void> addToken(String token) async {
    if (gameOver || currentGuess.length >= answerTokens.length) return;
    lastSubmitWasInvalidWord = false;
    currentGuess = <String>[...currentGuess, token.toUpperCase()];
    await _saveDaily();
    notifyListeners();
  }

  Future<void> backspace() async {
    if (gameOver || currentGuess.isEmpty) return;
    lastSubmitWasInvalidWord = false;
    currentGuess = currentGuess.sublist(0, currentGuess.length - 1);
    await _saveDaily();
    notifyListeners();
  }

  String _maskedSentence() {
    var masked = puzzle.exampleEn;
    final meaning = puzzle.meaning.trim();
    if (meaning.isNotEmpty) {
      final pattern = RegExp(RegExp.escape(meaning), caseSensitive: false);
      masked = masked.replaceFirst(pattern, '_____');
    }
    if (masked == puzzle.exampleEn) {
      final answerPattern = RegExp(RegExp.escape(puzzle.answer), caseSensitive: false);
      masked = masked.replaceFirst(answerPattern, '_____');
    }
    return masked;
  }

  Future<HintMessage?> revealNextHint() async {
    if (!canUseHint) return null;
    hintsUsed += 1;
    await _saveDaily();

    final body = switch (hintsUsed) {
      1 => strings.contextualHint(
          category: puzzle.category,
          sentence: _maskedSentence(),
          tileCount: answerTokens.length,
        ),
      2 => strings.firstTileHint(answerTokens.first),
      _ => strings.meaningHint(puzzle.meaning),
    };

    final hint = HintMessage(
      number: hintsUsed,
      title: strings.hintTitle(hintsUsed),
      body: body,
      starsRemaining: starsAvailable,
    );
    notifyListeners();
    return hint;
  }

  Future<String?> submitGuess() async {
    if (gameOver) return null;
    lastSubmitWasInvalidWord = false;
    if (currentGuess.length != answerTokens.length) {
      return strings.tilesNeeded(answerTokens.length);
    }

    if (!isKnownValidGuess(currentGuess)) {
      invalidWordTick += 1;
      lastSubmitWasInvalidWord = true;
      notifyListeners();
      return strings.invalidWord;
    }

    final scores = scoreGuess(currentGuess, answerTokens);
    guesses = <EvaluatedGuess>[
      ...guesses,
      EvaluatedGuess(tokens: List<String>.from(currentGuess), scores: scores),
    ];
    currentGuess = <String>[];

    won = scores.every((score) => score == TileScore.correct);
    if (won || guesses.length >= maxGuesses) {
      gameOver = true;
      if (!practiceMode) {
        await _completeStats();
      }
      screen = AppScreen.result;
    }

    await _saveDaily();
    notifyListeners();
    return null;
  }

  Future<void> tryAnotherWord() async {
    practiceMode = true;
    final bounds = _practiceBounds();
    final count = bounds.$2 - bounds.$1;
    var index = bounds.$1 + (_practiceCursor % count);
    _practiceCursor += 1;

    if (puzzles[index].answer == puzzle.answer && count > 1) {
      index = bounds.$1 + (_practiceCursor % count);
      _practiceCursor += 1;
    }

    puzzle = puzzles[index];
    puzzleNumber = index + 1;
    answerTokens = tokeniseWelsh(puzzle.answer);
    currentGuess = <String>[];
    guesses = <EvaluatedGuess>[];
    gameOver = false;
    won = false;
    hintsUsed = 0;
    invalidWordTick = 0;
    lastSubmitWasInvalidWord = false;
    screen = AppScreen.game;
    notifyListeners();
  }

  (int, int) _practiceBounds() {
    if (stats.wins < 10) return (0, puzzles.length < 24 ? puzzles.length : 24);
    if (stats.wins < 25) {
      final start = puzzles.length < 24 ? 0 : 24;
      final end = puzzles.length < 48 ? puzzles.length : 48;
      return (start, end > start ? end : puzzles.length);
    }
    final start = puzzles.length < 48 ? 0 : 48;
    return (start, puzzles.length);
  }

  Future<void> _restoreDailyPuzzle() async {
    practiceMode = false;
    puzzleNumber = _dailyPuzzleNumber;
    puzzle = _dailyPuzzle;
    answerTokens = tokeniseWelsh(puzzle.answer);
    currentGuess = <String>[];
    guesses = <EvaluatedGuess>[];
    gameOver = false;
    won = false;
    hintsUsed = 0;
    invalidWordTick = 0;
    lastSubmitWasInvalidWord = false;

    final saved = await _store.loadDaily(todayKey);
    if (saved != null && saved.answer == puzzle.answer) {
      currentGuess = List<String>.from(saved.currentGuess);
      guesses = List<EvaluatedGuess>.from(saved.guesses);
      gameOver = saved.gameOver;
      won = saved.won;
      hintsUsed = saved.hintsUsed;
    }
  }

  Future<void> _saveDaily() async {
    if (!isReady || practiceMode) return;
    await _store.saveDaily(
      todayKey,
      DailyState(
        answer: puzzle.answer,
        currentGuess: currentGuess,
        guesses: guesses,
        gameOver: gameOver,
        won: won,
        hintsUsed: hintsUsed,
      ),
    );
  }

  Future<void> _completeStats() async {
    if (stats.lastCompletedDate == todayKey) return;
    stats.played += 1;
    if (won) {
      stats.wins += 1;
      stats.totalStars += resultStars;
      final gap = stats.lastWinDate == null ? null : daysBetween(stats.lastWinDate!, todayKey);
      stats.streak = gap == 1 ? stats.streak + 1 : 1;
      if (stats.streak > stats.best) stats.best = stats.streak;
      stats.lastWinDate = todayKey;
      if (guesses.isNotEmpty && guesses.length <= 6) {
        stats.distribution[guesses.length - 1] += 1;
      }
    } else {
      stats.streak = 0;
    }
    stats.lastCompletedDate = todayKey;
    await _store.saveStats(stats);
  }

  String get homeButtonLabel {
    if (gameOver) return strings.viewResult;
    if (guesses.isNotEmpty || currentGuess.isNotEmpty) return strings.continuePlaying;
    return strings.playToday;
  }

  String shareText() {
    final rows = guesses.map((guess) {
      return guess.scores.map((score) {
        switch (score) {
          case TileScore.correct:
            return '🟩';
          case TileScore.present:
            return '🟨';
          case TileScore.absent:
            return '⬛';
        }
      }).join();
    }).join('\n');
    final result = won ? '${guesses.length}/$maxGuesses' : 'X/$maxGuesses';
    final stars = starText(resultStars);
    final puzzleLabel = practiceMode ? strings.practiceShare : '#$puzzleNumber';
    return 'DYFALA! $puzzleLabel $result  $stars\n'
        '$rows\n'
        '${strings.hintsShare(hintsUsed)}\n'
        '${strings.shareFooter}';
  }

  Duration get untilTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }
}
