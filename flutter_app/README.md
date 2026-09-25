# Dyfala! Flutter app — native v0.1

This is the Android-first Flutter migration of the Dyfala! daily Welsh word game.

## What has moved across from the HTML prototype

- Daily puzzle selection (epoch: 13 September 2026)
- 68 curated starter answers with Welsh/English learning copy
- 172-word beta valid-guess set
- Welsh digraph tiles: CH, DD, FF, NG, LL, PH, RH, TH
- Duplicate-aware Wordle-style scoring
- Six guesses
- Daily progress persistence
- Played / win rate / streak / best statistics
- Result sharing text (clipboard in this first native shell)
- Beta behaviour that records unknown guesses locally rather than falsely rejecting Welsh

## Design architecture

The visuals are deliberately easy to change. The main tokens live in:

- `lib/theme/dyfala_theme.dart` — palette, radii and type scale
- `lib/widgets/welsh_landscape.dart` — native vector Welsh landscape
- `lib/widgets/tile_board.dart` — board treatment
- `lib/widgets/welsh_keyboard.dart` — digraph/QWERTY keyboard
- `lib/screens/` — Home, Game and Result composition

This is intentional: the visual design is **not locked yet**.

## Running/building

A normal Flutter environment is required. If this folder has not yet had platform scaffolding generated on the machine, run:

```bash
flutter create . --platforms=android --org uk.co.dyfala --project-name dyfala
flutter pub get
flutter test
flutter run
```

A GitHub Actions workflow is included at `.github/workflows/android.yml`; once this project is in a GitHub repository, it can build a debug APK automatically on GitHub's runner.

## Current status

The source migration is complete for the first native shell. The build environment used to create this source pack does not contain the Flutter SDK, so an APK has **not** been compiled here yet. The game data and core algorithms were independently validated during migration, including all 68 answers being exactly five Welsh game tiles.
