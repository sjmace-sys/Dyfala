import '../data/puzzles.dart';
import '../data/valid_guesses.dart';
import '../models/puzzle.dart';

const welshDigraphs = <String>['CH', 'DD', 'FF', 'NG', 'LL', 'PH', 'RH', 'TH'];
const maxGuesses = 6;
const epochDateKey = '2026-09-13';

enum TileScore { correct, present, absent }

int starsForResult({required bool won, required int hintsUsed}) {
  if (!won) return 0;
  final stars = 3 - hintsUsed;
  return stars.clamp(0, 3).toInt();
}

String starText(int stars) {
  final safe = stars.clamp(0, 3).toInt();
  return '${List<String>.filled(safe, '⭐').join()}${List<String>.filled(3 - safe, '☆').join()}';
}

class EvaluatedGuess {
  const EvaluatedGuess({required this.tokens, required this.scores});

  final List<String> tokens;
  final List<TileScore> scores;

  Map<String, dynamic> toJson() => {
        'tokens': tokens,
        'scores': scores.map((score) => score.name).toList(),
      };

  factory EvaluatedGuess.fromJson(Map<String, dynamic> json) {
    final rawTokens = (json['tokens'] as List<dynamic>? ?? const []);
    final rawScores = (json['scores'] as List<dynamic>? ?? const []);
    return EvaluatedGuess(
      tokens: rawTokens.map((value) => value.toString()).toList(),
      scores: rawScores.map((value) {
        return TileScore.values.firstWhere(
          (score) => score.name == value.toString(),
          orElse: () => TileScore.absent,
        );
      }).toList(),
    );
  }
}

List<String> tokeniseWelsh(String input) {
  final source = input
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-ZÂÊÎÔÛŴŶ]'), '');
  final tokens = <String>[];
  var index = 0;
  while (index < source.length) {
    final two = index + 1 < source.length ? source.substring(index, index + 2) : '';
    if (welshDigraphs.contains(two)) {
      tokens.add(two);
      index += 2;
    } else {
      tokens.add(source.substring(index, index + 1));
      index += 1;
    }
  }
  return tokens;
}

List<TileScore> scoreGuess(List<String> guess, List<String> answer) {
  final result = List<TileScore>.filled(guess.length, TileScore.absent);
  final remaining = <String, int>{};

  for (var index = 0; index < answer.length; index++) {
    if (index < guess.length && guess[index] == answer[index]) {
      result[index] = TileScore.correct;
    } else {
      final token = answer[index];
      remaining[token] = (remaining[token] ?? 0) + 1;
    }
  }

  for (var index = 0; index < guess.length; index++) {
    if (result[index] == TileScore.correct) continue;
    final token = guess[index];
    final count = remaining[token] ?? 0;
    if (count > 0) {
      result[index] = TileScore.present;
      remaining[token] = count - 1;
    }
  }
  return result;
}

String localDateKey([DateTime? date]) {
  final value = date ?? DateTime.now();
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime parseDateKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

int daysBetween(String first, String second) {
  return parseDateKey(second).difference(parseDateKey(first)).inDays;
}

int puzzleNumberForDate(String dateKey) {
  final value = daysBetween(epochDateKey, dateKey) + 1;
  return value < 1 ? 1 : value;
}

Puzzle puzzleForDate(String dateKey) {
  final offset = daysBetween(epochDateKey, dateKey);
  final index = ((offset % puzzles.length) + puzzles.length) % puzzles.length;
  return puzzles[index];
}

bool isKnownValidGuess(List<String> tokens) {
  return validGuessWords.contains(tokens.join());
}

Map<String, TileScore> keyboardState(List<EvaluatedGuess> guesses) {
  const priority = {
    TileScore.present: 1,
    TileScore.correct: 2,
  };
  final states = <String, TileScore>{};
  for (final guess in guesses) {
    for (var i = 0; i < guess.tokens.length && i < guess.scores.length; i++) {
      final token = guess.tokens[i];
      final next = guess.scores[i];
      if (next == TileScore.absent) continue;
      final current = states[token];
      if (current == null || priority[next]! > priority[current]!) {
        states[token] = next;
      }
    }
  }
  return states;
}
