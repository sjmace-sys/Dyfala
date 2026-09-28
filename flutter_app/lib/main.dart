import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'game/game_controller.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';
import 'theme/dyfala_theme.dart';
import 'widgets/welsh_landscape.dart';
import 'widgets/approved_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const DyfalaBootstrap());
}

class DyfalaBootstrap extends StatefulWidget {
  const DyfalaBootstrap({super.key});

  @override
  State<DyfalaBootstrap> createState() => _DyfalaBootstrapState();
}

class _DyfalaBootstrapState extends State<DyfalaBootstrap> {
  late final GameController controller;
  bool _assetsReady = false;
  bool _precacheStarted = false;

  @override
  void initState() {
    super.initState();
    controller = GameController()..initialise();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;

    Future.wait([
      precacheImage(const AssetImage('assets/approved/home-en.png'), context),
      precacheImage(const AssetImage('assets/approved/home-cy.png'), context),
      precacheImage(const AssetImage('assets/approved/home-logo.png'), context),
      precacheImage(const AssetImage('assets/approved/home-scene.png'), context),
    ]).whenComplete(() {
      if (mounted) setState(() => _assetsReady = true);
    });
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
          if (!controller.isReady || !_assetsReady) {
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
      backgroundColor: DyfalaPalette.cream,
      body: SafeArea(
        child: Stack(
          children: [
            const Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: .82,
                child: WelshLandscape(height: 180, showCastle: false),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ApprovedDyfalaLogo(
                      height: 82,
                      maxWidth: 300,
                    ),
                    const SizedBox(height: 22),
                    const SizedBox(
                      width: 28,
                      height: 28,
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
      ),
    );
  }
}
