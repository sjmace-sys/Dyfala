from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text(encoding='utf-8')
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: expected one match, found {count}')
    file.write_text(text.replace(old, new, 1), encoding='utf-8')


# Home: redraw the third sign as part of the signpost family rather than a pasted card.
home = 'lib/screens/home_screen.dart'
replace_once(
    home,
    """              Positioned(
                left: -6,
                top: 914,
                width: 430,
                height: 96,
                child: Transform.rotate(
                  angle: -.032,
                  alignment: Alignment.centerLeft,
                  child: ClipPath(
                    clipper: const _SignArrowClipper(),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFD45B),
                            Color(0xFFFFBC33),
                          ],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const Positioned(
                            left: 12,
                            right: 66,
                            top: 20,
                            child: Divider(
                              height: 1,
                              thickness: 2,
                              color: Color(0x22A06B18),
                            ),
                          ),
                          const Positioned(
                            left: 20,
                            right: 76,
                            bottom: 18,
                            child: Divider(
                              height: 1,
                              thickness: 2,
                              color: Color(0x18A06B18),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 48),
                              child: Text(
                                label,
                                style: GoogleFonts.fredoka(
                                  color: DyfalaPalette.navy,
                                  fontSize: 42,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),""",
    """              Positioned(
                left: -2,
                top: 918,
                width: 395,
                height: 80,
                child: Transform.rotate(
                  angle: -.018,
                  alignment: Alignment.centerLeft,
                  child: ClipPath(
                    clipper: const _SignArrowClipper(),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC342),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 31, right: 54),
                          child: Text(
                            label,
                            style: GoogleFonts.fredoka(
                              color: DyfalaPalette.navy,
                              fontSize: 35,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),""",
)

# Result: use the clean scenic background so the home-screen Dyfala mark cannot ghost through.
result = 'lib/screens/result_screen.dart'
replace_once(
    result,
    """  String _backgroundAsset() {
    return widget.controller.uiLanguage.name == 'welsh'
        ? 'assets/approved/home-cy.png'
        : 'assets/approved/home-en.png';
  }""",
    """  String _backgroundAsset() {
    return 'assets/approved/home-background-v10.png';
  }""",
)

# Share card: use the canvas more deliberately, enlarge the result grid and make the branding readable in previews.
share = 'lib/share/share_image.dart'
replacements = [
    ("const Rect.fromLTWH(190, 48, 700, 145)", "const Rect.fromLTWH(145, 38, 790, 150)"),
    ("""    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(382, 171, 316, 15),
        const Radius.circular(99),
      ),
      Paint()..color = DyfalaPalette.yellow,
    );

""", ""),
    ("y: 202,", "y: 184,"),
    ("size: 27,", "size: 28,"),
    ("const y = 290.0;", "const y = 276.0;"),
    ("y: 368,", "y: 360,"),
    ("size: 48,", "size: 46,"),
    ("y: 423,", "y: 414,"),
    ("const maxGridHeight = 400.0;", "const maxGridHeight = 480.0;"),
    ("final top = 470 + (maxGridHeight - gridHeight) / 2;", "final top = 448 + (maxGridHeight - gridHeight) / 2;"),
    ("y: 855,", "y: 946,"),
    ("const Rect.fromLTWH(105, 910, 870, 92)", "const Rect.fromLTWH(90, 992, 900, 78)"),
    ("const Rect.fromLTWH(155, 934, 260, 38)", "const Rect.fromLTWH(132, 1014, 248, 36)"),
    ("const Rect.fromLTWH(438, 924, 460, 62)", "const Rect.fromLTWH(388, 1008, 555, 48)"),
    ("""    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(580, 975, 175, 8),
        const Radius.circular(99),
      ),
      Paint()..color = DyfalaPalette.yellow,
    );

""", ""),
    ("const Rect.fromLTWH(80, 1040, 920, 92)", "const Rect.fromLTWH(80, 1090, 920, 70)"),
    ("y: 1068,", "y: 1108,"),
    ("size: 31,", "size: 29,"),
]
for old, new in replacements:
    replace_once(share, old, new)

print('Build 69 visual patch applied')
