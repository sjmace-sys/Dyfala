import 'package:dyfala/game/game_engine.dart';
import 'package:dyfala/localisation/app_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Welsh tokenisation', () {
    test('digraphs count as one tile', () {
      expect(tokeniseWelsh('FFRIND'), ['FF', 'R', 'I', 'N', 'D']);
      expect(tokeniseWelsh('LLYFR'), ['LL', 'Y', 'F', 'R']);
      expect(tokeniseWelsh('NEWYDD'), ['N', 'E', 'W', 'Y', 'DD']);
    });
  });

  group('Guess scoring', () {
    test('exact answer is all green', () {
      final answer = tokeniseWelsh('CYMRU');
      final result = scoreGuess(tokeniseWelsh('CYMRU'), answer);
      expect(result.every((score) => score == TileScore.correct), isTrue);
    });

    test('duplicate letters are allocated once', () {
      final result = scoreGuess(
        ['A', 'A', 'A', 'B', 'C'],
        ['A', 'D', 'E', 'F', 'G'],
      );
      expect(result, [
        TileScore.correct,
        TileScore.absent,
        TileScore.absent,
        TileScore.absent,
        TileScore.absent,
      ]);
    });
  });

  group('Bilingual copy', () {
    test('English is the learner-first default copy', () {
      const strings = AppStrings(UiLanguage.english);
      expect(strings.playToday, 'Play today');
      expect(strings.helpTitle, 'How to play');
    });

    test('Welsh copy is available through the toggle', () {
      const strings = AppStrings(UiLanguage.welsh);
      expect(strings.playToday, 'Chwarae heddiw');
      expect(strings.helpTitle, 'Sut mae chwarae?');
    });
  });

  test('launch date is puzzle one', () {
    expect(puzzleNumberForDate('2026-09-13'), 1);
    expect(puzzleForDate('2026-09-13').answer, 'CYMRU');
  });

  group('Learner hint stars', () {
    test('stars reduce as hints are used', () {
      expect(starsForResult(won: true, hintsUsed: 0), 3);
      expect(starsForResult(won: true, hintsUsed: 1), 2);
      expect(starsForResult(won: true, hintsUsed: 2), 1);
      expect(starsForResult(won: true, hintsUsed: 3), 0);
    });

    test('a loss earns no stars', () {
      expect(starsForResult(won: false, hintsUsed: 0), 0);
    });
  });


  group('V18 learner feedback', () {
    test('absent letters are not greyed out on the keyboard', () {
      final states = keyboardState([
        const EvaluatedGuess(
          tokens: ['C', 'A', 'T'],
          scores: [TileScore.correct, TileScore.present, TileScore.absent],
        ),
      ]);
      expect(states['C'], TileScore.correct);
      expect(states['A'], TileScore.present);
      expect(states.containsKey('T'), isFalse);
    });

    test('lexicon rejects an unknown Welsh entry', () {
      expect(isKnownValidGuess(tokeniseWelsh('XXXXX')), isFalse);
      expect(isKnownValidGuess(tokeniseWelsh('CYMRU')), isTrue);
    });
  });
}
