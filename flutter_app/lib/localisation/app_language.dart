enum UiLanguage { english, welsh }

class AppStrings {
  const AppStrings(this.language);

  final UiLanguage language;

  bool get isWelsh => language == UiLanguage.welsh;

  String get languageCode => isWelsh ? 'CY' : 'EN';
  String get otherLanguageCode => isWelsh ? 'EN' : 'CY';

  String get learnTagline => isWelsh
      ? 'Y ffordd hwyliog o ddysgu geiriau Cymraeg.'
      : 'The fun way to learn Welsh words.';
  String get dailyTagline => isWelsh ? 'Gair newydd bob dydd' : 'A new Welsh word every day';
  String get todaysGame => isWelsh ? 'GAIR HEDDIW' : 'TODAY\'S WORD';
  String get playToday => isWelsh ? 'Chwarae heddiw' : 'Play today';
  String get continuePlaying => isWelsh ? 'Parhau i chwarae' : 'Continue playing';
  String get viewResult => isWelsh ? 'Gweld canlyniad' : 'View result';
  String get helpTitle => isWelsh ? 'Sut mae chwarae?' : 'How to play';
  String get helpIntro => isWelsh
      ? 'Dyfala’r gair Cymraeg mewn hyd at chwe ymgais. Mae pob ateb yn cynnwys pum teilsen Gymraeg.'
      : 'Guess the Welsh word in up to six tries. Every answer contains five Welsh tiles.';
  String get helpLearner => isWelsh
      ? 'Ar ôl y gêm, fe welwch ystyr Saesneg y gair ac enghraifft i’ch helpu i’w ddysgu.'
      : 'After the game, you’ll see the English meaning and an example sentence to help you learn it.';
  String get helpHints => isWelsh
      ? 'Mae tri awgrym ar gael. Mae pob awgrym yn helpu mwy, ond yn lleihau nifer y sêr sydd ar gael.'
      : 'Three hints are available. Each one helps a little more, but reduces the stars available.';
  String get helpCorrect => isWelsh ? 'Y llythyren yn y lle cywir.' : 'The letter is in the correct place.';
  String get helpPresent => isWelsh ? 'Yn y gair, ond yn y lle anghywir.' : 'It’s in the word, but in the wrong place.';
  String get helpAbsent => isWelsh ? 'Nid yw’r llythyren yn y gair.' : 'The letter isn’t in the word.';
  String get helpDigraph => isWelsh
      ? 'Mae CH, DD, FF, NG, LL, PH, RH a TH yn cyfrif fel un deilsen.'
      : 'CH, DD, FF, NG, LL, PH, RH and TH each count as one tile.';
  String get helpDaily => isWelsh
      ? 'Mae gair newydd ar gael bob dydd. Gallwch chwarae unwaith y dydd a chadw eich ystadegau.'
      : 'There’s a new word every day. Play once a day and build your stats.';
  String get close => isWelsh ? 'Iawn, deall!' : 'Got it!';

  String get played => isWelsh ? 'CHWARAE' : 'PLAYED';
  String get winRate => isWelsh ? 'ENNILL' : 'WIN %';
  String get streak => isWelsh ? 'RHESTR' : 'STREAK';
  String get best => isWelsh ? 'GORAU' : 'BEST';
  String get stars => isWelsh ? 'SÊR' : 'STARS';

  String tilesNeeded(int count) => isWelsh
      ? 'Bron â bod — llenwa bob un o’r $count teilsen yn gyntaf.'
      : 'Nearly there — fill all $count tiles first.';
  String get wellDone => isWelsh ? 'Da iawn! ⭐' : 'Nice one! ⭐';
  String get todaysAnswer => isWelsh ? 'Cynnig da — gair heddiw oedd…' : 'Good try — today’s word was…';
  String attempts(int count, int puzzle) => isWelsh
      ? 'Wedi’i ddatrys mewn $count ymgais · #$puzzle'
      : 'Solved in $count ${count == 1 ? 'try' : 'tries'} · #$puzzle';
  String tryAgainTomorrow(int puzzle) => isWelsh
      ? 'Cynnig da — gair newydd yfory · #$puzzle'
      : 'Good try — a fresh word tomorrow · #$puzzle';
  String get englishMeaning => isWelsh ? 'Mae’n golygu' : 'It means';
  String get welshExample => isWelsh ? 'Mewn brawddeg' : 'See it in a sentence';
  String get whatLearned => isWelsh ? 'Eich gair Cymraeg newydd' : 'Your new Welsh word';
  String nextWord(String clock) => isWelsh ? 'Gair newydd mewn  $clock' : 'A fresh word in  $clock';
  String get share => isWelsh ? 'Rhannu’r hwyl' : 'Share the fun';
  String get copied => isWelsh ? 'Canlyniad wedi’i gopïo' : 'Result copied';
  String get shareFooter => isWelsh ? 'Cymru yn ein geiriau' : 'Learning Welsh, one word at a time';
  String get tryAnother => isWelsh ? 'Chwarae gair arall' : 'Play another word';
  String get practiceShare => isWelsh ? 'YMARFER' : 'PRACTICE';
  String get practiceMode => isWelsh ? 'Gair ymarfer' : 'Practice word';

  String get hint => isWelsh ? 'Awgrym' : 'Hint';
  String hintTitle(int number) => isWelsh ? 'Awgrym $number o 3' : 'Hint $number of 3';
  String hintButton(int nextNumber) => isWelsh ? 'Awgrym $nextNumber' : 'Hint $nextNumber';
  String get noMoreHints => isWelsh ? 'Pob awgrym wedi’i ddefnyddio' : 'All hints used';
  String starsStillAvailable(int count) => isWelsh
      ? '$count ${count == 1 ? 'seren' : 'sêr'} ar gael o hyd'
      : '$count ${count == 1 ? 'star' : 'stars'} still available';
  String hintsUsedText(int count) {
    if (count == 0) {
      return isWelsh ? 'Dim awgrymiadau — gwych!' : 'No hints needed — brilliant!';
    }
    return isWelsh
        ? '$count ${count == 1 ? 'awgrym' : 'awgrym'} wedi’i ddefnyddio'
        : '$count ${count == 1 ? 'hint' : 'hints'} used';
  }
  String hintsShare(int count) => isWelsh
      ? 'Awgrymiadau: $count'
      : 'Hints: $count';

  String categoryHint(String category) {
    final en = <String, String>{
      'animal': 'Think of an animal.',
      'body': 'This word is connected with the body.',
      'colour': 'Think of a colour.',
      'culture': 'This word is connected with Welsh life or culture.',
      'everyday': 'This is a useful everyday Welsh word.',
      'feeling': 'This word describes a feeling.',
      'food': 'Think of something connected with food or mealtimes.',
      'history': 'This word is connected with history.',
      'home': 'Think of something connected with home.',
      'learning': 'This word is connected with learning.',
      'nature': 'Think of the natural world.',
      'people': 'This word is about people.',
      'place': 'Think of a place or somewhere you could be.',
      'time': 'This word is connected with time.',
      'verb': 'This is an action word.',
      'weather': 'Think about the weather.',
      'work': 'This word is connected with work.',
    };
    final cy = <String, String>{
      'animal': 'Meddyliwch am anifail.',
      'body': 'Mae’r gair hwn yn ymwneud â’r corff.',
      'colour': 'Meddyliwch am liw.',
      'culture': 'Mae’r gair hwn yn ymwneud â bywyd neu ddiwylliant Cymru.',
      'everyday': 'Mae hwn yn air Cymraeg defnyddiol bob dydd.',
      'feeling': 'Mae’r gair hwn yn disgrifio teimlad.',
      'food': 'Meddyliwch am fwyd neu amser bwyd.',
      'history': 'Mae’r gair hwn yn ymwneud â hanes.',
      'home': 'Meddyliwch am rywbeth yn y cartref.',
      'learning': 'Mae’r gair hwn yn ymwneud â dysgu.',
      'nature': 'Meddyliwch am y byd naturiol.',
      'people': 'Mae’r gair hwn yn ymwneud â phobl.',
      'place': 'Meddyliwch am le.',
      'time': 'Mae’r gair hwn yn ymwneud ag amser.',
      'verb': 'Gair gweithredu yw hwn.',
      'weather': 'Meddyliwch am y tywydd.',
      'work': 'Mae’r gair hwn yn ymwneud â gwaith.',
    };
    return (isWelsh ? cy : en)[category] ??
        (isWelsh ? 'Awgrym bach am y gair heddiw.' : 'A small clue about today’s word.');
  }

  String firstTileHint(String tile) => isWelsh
      ? 'Mae’r gair yn dechrau gyda $tile.'
      : 'The word starts with $tile.';

  String meaningHint(String meaning) => isWelsh
      ? 'Yr ystyr Saesneg yw “$meaning”.'
      : 'The English meaning is “$meaning”.';


  String get invalidWord => isWelsh
      ? 'Hmm… dydyn ni ddim yn adnabod y gair Cymraeg hwnnw eto.'
      : 'Hmm… that one isn’t in our Welsh word list yet.';

  String get clueLead => isWelsh ? 'Awgrym gwell' : 'Better clue';

  String categoryName(String category) {
    final en = <String, String>{
      'animal': 'animal',
      'body': 'body',
      'colour': 'colour',
      'culture': 'Welsh life',
      'everyday': 'everyday Welsh',
      'feeling': 'feeling',
      'food': 'food',
      'history': 'history',
      'home': 'home',
      'learning': 'learning',
      'nature': 'nature',
      'people': 'people',
      'place': 'place',
      'time': 'time',
      'verb': 'action',
      'weather': 'weather',
      'work': 'work',
    };
    final cy = <String, String>{
      'animal': 'anifail',
      'body': 'corff',
      'colour': 'lliw',
      'culture': 'bywyd Cymreig',
      'everyday': 'Cymraeg bob dydd',
      'feeling': 'teimlad',
      'food': 'bwyd',
      'history': 'hanes',
      'home': 'cartref',
      'learning': 'dysgu',
      'nature': 'natur',
      'people': 'pobl',
      'place': 'lle',
      'time': 'amser',
      'verb': 'gweithred',
      'weather': 'tywydd',
      'work': 'gwaith',
    };
    return (isWelsh ? cy : en)[category] ?? (isWelsh ? 'gair' : 'word');
  }

  String contextualHint({required String category, required String sentence, required int tileCount}) {
    return isWelsh
        ? 'Cliw: “$sentence”'
        : 'Clue: “$sentence”';
  }

  String get levelEveryday => isWelsh ? 'Cymraeg bob dydd' : 'Everyday Welsh';
  String get levelGrowing => isWelsh ? 'Geirfa sy’n tyfu' : 'Growing vocabulary';
  String get levelChallenge => isWelsh ? 'Geiriau her' : 'Challenge words';
}
