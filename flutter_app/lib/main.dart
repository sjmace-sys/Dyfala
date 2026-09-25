import 'package:flutter/material.dart';

import 'game/game_controller.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';
import 'theme/dyfala_theme.dart';
import 'widgets/welsh_landscape.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DyfalaBootstrap());
}

class DyfalaBootstrap extends StatefulWidget {
  const DyfalaBootstrap({super.key});

  @override
  State<DyfalaBootstrap> createState() => _DyfalaBootstrapState();
}

class _DyfalaBootstrapState extends State<DyfalaBootstrap> {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController()..initialise();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dyfala!',
      debugShowCheckedModeBanner: false,
      theme: buildDyfalaTheme(),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.isReady) {
            return const _LoadingScreen();
          }
          switch (controller.screen) {
            case AppScreen.home:
              return HomeScreen(controller: controller);
            case AppScreen.game:
              return GameScreen(controller: controller);
            case AppScreen.result:
              return ResultScreen(controller: controller);
          }
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: DyfalaPalette.cream)),
          Positioned(
            right: -45,
            top: -55,
            child: Container(
              width: 165,
              height: 165,
              decoration: const BoxDecoration(color: DyfalaPalette.red, shape: BoxShape.circle),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(opacity: .9, child: WelshLandscape(height: 185, showCastle: false)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: DyfalaPalette.red,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Color(0x26071A27), blurRadius: 24, offset: Offset(0, 12)),
                      ],
                    ),
                    child: Image.asset('assets/icons/icon-512.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 82,
                    child: Image.asset(
                      'assets/approved/home-logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'The fun way to learn Welsh words.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DyfalaPalette.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: DyfalaPalette.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
